//
//  DIMTransceiver+Transform.m
//  DIMCore
//
//  Created by Albert Moky on 2019/3/15.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "DKDInstantMessage+Extension.h"

#import "DIMContentType.h"
#import "DIMForwardContent.h"

#import "DIMBarrack.h"
#import "DIMKeyStore.h"

#import "DIMTransceiver+Transform.h"

@implementation DIMTransceiver (Transform)

- (DIMSymmetricKey *)_passwordFrom:(DIMID *)sender to:(DIMID *)receiver {
    // 1. get old key from store
    DIMSymmetricKey *reusedKey;
    reusedKey = [_cipherKeyDataSource cipherKeyFrom:sender to:receiver];
    // 2. get new key from delegate
    DIMSymmetricKey *newKey;
    newKey = [_cipherKeyDataSource reuseCipherKey:reusedKey from:sender to:receiver];
    if (!newKey) {
        if (!reusedKey) {
            // 3. create a new key
            newKey = MKMSymmetricKeyWithAlgorithm(SCAlgorithmAES);
        } else {
            newKey = reusedKey;
        }
    }
    // 4. update new key into the key store
    if (![newKey isEqual:reusedKey]) {
        [_cipherKeyDataSource cacheCipherKey:newKey from:sender to:receiver];
    }
    return newKey;
}

- (nullable DIMReliableMessage *)encryptAndSignMessage:(DIMInstantMessage *)iMsg {
    if (iMsg.delegate == nil) {
        iMsg.delegate = self;
    }
    NSAssert(iMsg.content, @"content cannot be empty");
    
    DIMSymmetricKey *scKey = nil;
    DIMSecureMessage *sMsg = nil;
    
    // 1. encrypt 'content' to 'data' for receiver
    DIMID *sender = MKMIDFromString(iMsg.envelope.sender);
    DIMID *receiver = MKMIDFromString(iMsg.envelope.receiver);
    DIMID *group = MKMIDFromString(iMsg.content.group);
    if (group) {
        // if 'group' exists and the 'receiver' is a group ID,
        // they must be equal
        NSAssert(MKMNetwork_IsCommunicator(receiver.type) || [receiver isEqual:group],
                 @"receiver error: %@", receiver);
    } else if (MKMNetwork_IsGroup(receiver.type)) {
        group = receiver;
    }
    
    if (group) {
        // group message
        NSArray *members;
        if (MKMNetwork_IsCommunicator(receiver.type)) {
            // split group message
            members = @[receiver];
        } else {
            members = [_barrackDelegate groupWithID:group].members;
            // FIXME: new group's member list may be empty
            //NSAssert(members.count > 0, @"group members cannot be empty");
        }
        scKey = [self _passwordFrom:sender to:group];
        NSAssert(scKey != nil, @"failed to generate key for group: %@", group);
        sMsg = [iMsg encryptWithKey:scKey forMembers:members];
    } else {
        // personal message
        NSAssert(iMsg.content.group == nil, @"content error: %@", iMsg);
        scKey = [self _passwordFrom:sender to:receiver];
        NSAssert(scKey != nil, @"failed to generate key for contact: %@", receiver);
        sMsg = [iMsg encryptWithKey:scKey];
    }
    if (sMsg.delegate == nil) {
        sMsg.delegate = self;
    }
    
    // 2. sign 'data' by sender
    NSAssert(sMsg.data, @"data cannot be empty");
    return [sMsg sign];
}

- (nullable DIMInstantMessage *)verifyAndDecryptMessage:(DIMReliableMessage *)rMsg
                                                  users:(NSArray<DIMUser *> *)users {
    if (rMsg.delegate == nil) {
        rMsg.delegate = self;
    }
    NSAssert(rMsg.signature, @"signature cannot be empty");
    DIMID *sender = MKMIDFromString(rMsg.envelope.sender);
    DIMID *receiver = MKMIDFromString(rMsg.envelope.receiver);
    
    // [Meta Protocol] check meta in first contact message
    DIMMeta *meta = [_entityDataSource metaForID:sender];
    if (!meta) {
        // first contact, try meta in message package
        meta = MKMMetaFromDictionary(rMsg.meta);
        if ([meta matchID:sender]) {
            [_entityDataSource saveMeta:meta forID:sender];
        } else {
            NSAssert(false, @"meta error: %@, %@", sender, meta);
            return nil;
        }
    }
    
    // check recipient
    DIMID *groupID = MKMIDFromString(rMsg.group);
    DIMUser *user = nil;
    if (MKMNetwork_IsGroup(receiver.type)) {
        NSAssert(!groupID || [groupID isEqual:receiver], @"group error: %@ != %@", receiver, groupID);
        groupID = receiver;
        // FIXME: maybe other user?
        user = users.firstObject;
        receiver = user.ID;
    } else {
        for (DIMUser *item in users) {
            if ([item.ID isEqual:receiver]) {
                user = item;
                NSLog(@"got new message for: %@", item.ID);
                break;
            }
        }
    }
    if (!user) {
        NSAssert(false, @"!!! wrong recipient: %@", receiver);
        return nil;
    }
    
    // 1. verify 'data' with 'signature'
    DIMSecureMessage *sMsg = [rMsg verify];
    if (sMsg.delegate == nil) {
        sMsg.delegate = self;
    }
    NSAssert(sMsg.data, @"data cannot be empty");
    
    // 2. decrypt 'data' to 'content'
    DIMInstantMessage *iMsg = nil;
    if (groupID) {
        // group message
        sMsg = [sMsg trimForMember:user.ID];
        if (sMsg.delegate == nil) {
            sMsg.delegate = self;
        }
        iMsg = [sMsg decryptForMember:receiver];
    } else {
        // personal message
        iMsg = [sMsg decrypt];
    }
    if (iMsg.delegate == nil) {
        iMsg.delegate = self;
    }
    NSAssert(iMsg.content, @"content cannot be empty");
    
    // 3. check: top-secret message
    if (iMsg.content.type == DIMContentType_Forward) {
        // do it again to drop the wrapper,
        // the secret inside the content is the real message
        DIMForwardContent *content = (DIMForwardContent *)iMsg.content;
        rMsg = content.forwardMessage;
        
        return [self verifyAndDecryptMessage:rMsg users:users];
    }
    
    // OK
    return iMsg;
}

@end

@implementation DIMTransceiver (Send)

- (BOOL)sendInstantMessage:(DIMInstantMessage *)iMsg
                  callback:(nullable DIMTransceiverCallback)callback
               dispersedly:(BOOL)split {
    // transforming
    DIMID *receiver = MKMIDFromString(iMsg.envelope.receiver);
    DIMID *groupID = MKMIDFromString(iMsg.content.group);
    DIMReliableMessage *rMsg = [self encryptAndSignMessage:iMsg];
    if (!rMsg) {
        NSAssert(false, @"failed to encrypt and sign message: %@", iMsg);
        iMsg.state = DIMMessageState_Error;
        iMsg.error = @"Encryption failed.";
        return NO;
    }
    
    // trying to send out
    BOOL OK = YES;
    if (split && MKMNetwork_IsGroup(receiver.type)) {
        NSAssert([receiver isEqual:groupID], @"group ID error: %@", iMsg);
        DIMGroup *group = [_barrackDelegate groupWithID:groupID];
        NSArray *messages = [rMsg splitForMembers:group.members];
        if (messages.count == 0) {
            NSLog(@"failed to split msg, send it to group: %@", receiver);
            OK = [self sendReliableMessage:rMsg callback:callback];
        } else {
            for (rMsg in messages) {
                if ([self sendReliableMessage:rMsg callback:callback]) {
                    //NSLog(@"group message sent to %@", rMsg.envelope.receiver);
                } else {
                    OK = NO;
                }
            }
        }
    } else {
        OK = [self sendReliableMessage:rMsg callback:callback];
    }
    
    // sending status
    if (OK) {
        iMsg.state = DIMMessageState_Sending;
    } else {
        NSLog(@"cannot send message now, put in waiting queue: %@", iMsg);
        iMsg.state = DIMMessageState_Waiting;
    }
    return OK;
}

- (BOOL)sendReliableMessage:(DIMReliableMessage *)rMsg
                   callback:(DIMTransceiverCallback)callback {
    NSData *data = [rMsg jsonData];
    if (data) {
        NSAssert(_delegate, @"transceiver delegate not set");
        return [_delegate sendPackage:data
                    completionHandler:^(NSError * _Nullable error) {
                        !callback ?: callback(rMsg, error);
                    }];
    } else {
        NSAssert(false, @"message data error: %@", rMsg);
        return NO;
    }
}

@end
