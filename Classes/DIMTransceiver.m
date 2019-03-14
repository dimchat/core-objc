//
//  DIMTransceiver.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/7.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"
#import "NSObject+JsON.h"

#import "DIMBarrack+LocalStorage.h"

#import "DIMInstantMessage+Transform.h"
#import "DIMSecureMessage+Transform.h"
#import "DIMReliableMessage+Transform.h"

#import "DIMTransceiver.h"

@implementation DIMTransceiver

SingletonImplementations(DIMTransceiver, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (BOOL)sendMessageContent:(const DIMMessageContent *)content
                      from:(const DIMID *)sender
                        to:(const DIMID *)receiver
                      time:(nullable const NSDate *)time
                  callback:(nullable DIMTransceiverCallback)callback {
    // make instant message
    DIMInstantMessage *iMsg;
    iMsg = [[DIMInstantMessage alloc] initWithContent:content
                                               sender:sender
                                             receiver:receiver
                                                 time:time];
    
    return [self sendInstantMessage:iMsg
                           callback:callback
                        dispersedly:YES];
}

- (BOOL)sendInstantMessage:(const DIMInstantMessage *)iMsg
                  callback:(nullable DIMTransceiverCallback)callback
               dispersedly:(BOOL)split {
    const DIMID *receiver = [DIMID IDWithID:iMsg.envelope.receiver];
    const DIMID *groupID = [DIMID IDWithID:iMsg.content.group];
    DIMReliableMessage *rMsg = [self encryptAndSignMessage:iMsg];
    if (split && groupID) {
        DIMGroup *group = DIMGroupWithID(groupID);
        NSArray *messages = [rMsg splitForGroupMembers:group.members];
        if (messages.count == 0) {
            NSLog(@"failed to split msg, send it to group: %@", receiver);
            return [self sendReliableMessage:rMsg callback:callback];
        }
        BOOL OK = YES;
        for (rMsg in messages) {
            if ([self sendReliableMessage:rMsg callback:callback]) {
                //NSLog(@"group message sent to %@", rMsg.envelope.receiver);
            } else {
                OK = NO;
            }
        }
        return OK;
    } else {
        return [self sendReliableMessage:rMsg callback:callback];
    }
}

- (BOOL)sendReliableMessage:(const DIMReliableMessage *)rMsg
                   callback:(DIMTransceiverCallback)callback {
    NSData *data = [rMsg jsonData];
    if (data) {
        NSAssert(_delegate, @"transceiver delegate not set");
        return [_delegate sendPackage:data
                    completionHandler:^(const NSError * _Nullable error) {
                        assert(!error);
                        !callback ?: callback(rMsg, error);
                    }];
    } else {
        NSAssert(false, @"message data error: %@", rMsg);
        return NO;
    }
}

#pragma mark -

- (DIMReliableMessage *)encryptAndSignContent:(const DIMMessageContent *)content
                                       sender:(const DIMID *)sender
                                     receiver:(const DIMID *)receiver
                                         time:(nullable const NSDate *)time {
    NSAssert(MKMNetwork_IsPerson(sender.type), @"sender error: %@", sender);
    NSAssert(receiver.isValid, @"receiver error: %@", receiver);
    
    // make instant message
    DIMInstantMessage *iMsg;
    iMsg = [[DIMInstantMessage alloc] initWithContent:content
                                               sender:sender
                                             receiver:receiver
                                                 time:time];
    
    // let another selector to do the continue jobs
    return [self encryptAndSignMessage:iMsg];
}

- (DIMReliableMessage *)encryptAndSignMessage:(const DIMInstantMessage *)iMsg {
    NSAssert(iMsg.content, @"content cannot be empty");
    
    // 1. encrypt 'content' to 'data'
    DIMSecureMessage *sMsg = [iMsg encrypt];
    NSAssert(sMsg.data, @"data cannot be empty");
    
    // 2. sign 'data'
    DIMReliableMessage *rMsg = [sMsg sign];
    NSAssert(rMsg.signature, @"signature cannot be empty");
    
    // OK
    return rMsg;
}

- (DIMInstantMessage *)verifyAndDecryptMessage:(const DIMReliableMessage *)rMsg
                                       forUser:(const DIMUser *)user {
    NSAssert(rMsg.signature, @"signature cannot be empty");
    const DIMID *sender = [DIMID IDWithID:rMsg.envelope.sender];
    const DIMID *receiver = [DIMID IDWithID:rMsg.envelope.receiver];

    // 0. check with the current user
    if (user) {
        if (MKMNetwork_IsPerson(receiver.type)) {
            if (![receiver isEqual:user.ID]) {
                // TODO: You can forward it to the true receiver,
                //       or just ignore it.
                NSAssert(false, @"This message is for %@, not for you!", receiver);
                return nil;
            }
        } else if (MKMNetwork_IsGroup(receiver.type)) {
            DIMGroup *group = DIMGroupWithID(receiver);
            if (![group existsMember:user.ID]) {
                // TODO: You can forward it to the true receiver,
                //       or just ignore it.
                NSAssert(false, @"This message is not for you!");
                return nil;
            }
        }
    }
    
    // [Meta Protocol] check meta in first contact message
    const DIMMeta *meta = DIMMetaForID(sender);
    if (!meta) {
        // first contact, try meta in message package
        meta = [DIMMeta metaWithMeta:rMsg.meta];
        if ([meta matchID:sender]) {
            DIMBarrack *barrack = [DIMBarrack sharedInstance];
            [barrack saveMeta:meta forEntityID:sender];
        } else {
            NSAssert(false, @"meta not found for sender: %@", sender);
            return nil;
        }
    }
    
    // 1. verify 'data' witn 'signature'
    DIMSecureMessage *sMsg = [rMsg verify];
    NSAssert(sMsg.data, @"data cannot be empty");
    
    // 1.1. trim for user
    sMsg = [sMsg trimForMember:user.ID];
    NSAssert(MKMNetwork_IsPerson(receiver.type), @"receiver error: %@", receiver);
    
    // 2. decrypt 'data' to 'content'
    DIMInstantMessage *iMsg = [sMsg decrypt];
    NSAssert(iMsg.content, @"content cannot be empty");
    
    // 3. check: top-secret message
    if (iMsg.content.type == DIMMessageType_Forward) {
        // do it again to drop the wrapper,
        // the secret inside the content is the real message
        rMsg = iMsg.content.forwardMessage;
        return [self verifyAndDecryptMessage:rMsg forUser:user];
    }
    
    // OK
    return iMsg;
}

@end
