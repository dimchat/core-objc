//
//  DIMForwardContent.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/23.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMContentType.h"

#import "DIMForwardContent.h"

@implementation DIMForwardContent

- (instancetype)initWithForwardMessage:(const DKDReliableMessage *)rMsg {
    NSAssert(rMsg, @"forward message cannot be empty");
    if (self = [self initWithType:DIMContentType_Forward]) {
        // top-secret message
        if (rMsg) {
            [_storeDictionary setObject:rMsg forKey:@"forward"];
        }
    }
    return self;
}

- (DKDReliableMessage *)forwardMessage {
    NSDictionary *forward = [_storeDictionary objectForKey:@"forward"];
    DKDReliableMessage *msg = DKDReliableMessageFromDictionary(forward);
    if (msg != forward) {
        if (msg) {
            // replace the message object
            [_storeDictionary setObject:msg forKey:@"forward"];
        } else {
            NSAssert(false, @"forward message error: %@", forward);
            //[_storeDictionary removeObjectForKey:key];
        }
    }
    NSAssert(msg, @"forward message not found: %@", self);
    return msg;
}

@end
