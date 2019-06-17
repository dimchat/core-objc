//
//  DIMReceiptCommand.m
//  DIMCore
//
//  Created by Albert Moky on 2019/3/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+Compare.h"
#import "NSDate+Timestamp.h"
#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "DIMReceiptCommand.h"

@implementation DIMCommand (Receipt)

- (nullable DIMEnvelope *)envelope {
    NSString *sender = [_storeDictionary objectForKey:@"sender"];
    NSString *receiver = [_storeDictionary objectForKey:@"receiver"];
    if (sender && receiver) {
        NSNumber *number = [_storeDictionary objectForKey:@"time"];
        NSDate *time = NSDateFromNumber(number);
        
        return [[DIMEnvelope alloc] initWithSender:sender
                                          receiver:receiver
                                              time:time];
    } else {
        return nil;
    }
}

- (void)setEnvelope:(DIMEnvelope *)envelope {
    if (envelope) {
        const NSString *sender = envelope.sender;
        const NSString *receiver = envelope.receiver;
        NSDate *time = envelope.time;
        NSNumber *timestamp = NSNumberFromDate(time);
        
        [_storeDictionary setObject:sender forKey:@"sender"];
        [_storeDictionary setObject:receiver forKey:@"receiver"];
        [_storeDictionary setObject:timestamp forKey:@"time"];
    } else {
        [_storeDictionary removeObjectForKey:@"sender"];
        [_storeDictionary removeObjectForKey:@"receiver"];
        [_storeDictionary removeObjectForKey:@"time"];
    }
}

- (NSData *)signature {
    NSString *CT = [_storeDictionary objectForKey:@"signature"];
    return [CT base64Decode];
}

- (void)setSignature:(NSData *)signature {
    if (signature) {
        [_storeDictionary setObject:[signature base64Encode] forKey:@"signature"];
    } else {
        [_storeDictionary removeObjectForKey:@"signature"];
    }
}

@end

@implementation DIMReceiptCommand

- (instancetype)initWithMessage:(const NSString *)message {
    if (self = [self initWithCommand:DIMSystemCommand_Receipt]) {
        // message
        if (message) {
            [_storeDictionary setObject:message forKey:@"message"];
        }
    }
    return self;
}

@end
