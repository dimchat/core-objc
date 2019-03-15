//
//  DIMTransceiver+Send.m
//  DIMCore
//
//  Created by Albert Moky on 2019/3/15.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "DIMBarrack+LocalStorage.h"
#import "DIMTransceiver+Transform.h"

#import "DIMTransceiver+Send.h"

@implementation DIMTransceiver (Send)

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

- (BOOL)sendInstantMessage:(DIMInstantMessage *)iMsg
                  callback:(nullable DIMTransceiverCallback)callback
               dispersedly:(BOOL)split {
    const DIMID *receiver = [DIMID IDWithID:iMsg.envelope.receiver];
    const DIMID *groupID = [DIMID IDWithID:iMsg.content.group];
    DIMReliableMessage *rMsg = [self encryptAndSignMessage:iMsg];
    if (!rMsg) {
        NSAssert(false, @"failed to encrypt and sign message: %@", iMsg);
        return NO;
    }
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

- (BOOL)sendReliableMessage:(DIMReliableMessage *)rMsg
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

@end
