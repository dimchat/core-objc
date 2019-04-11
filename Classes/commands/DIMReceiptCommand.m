//
//  DIMReceiptCommand.m
//  DIMCore
//
//  Created by Albert Moky on 2019/3/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSDate+Timestamp.h"
#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "DIMReceiptCommand.h"

@interface DIMReceiptCommand () {
    
    DIMEnvelope *_envelope;
    NSData *_signature;
}

@property (strong, nonatomic) NSString *message;

@end

@implementation DIMReceiptCommand

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _message = nil;
        _envelope = nil;
        _signature = nil;
    }
    return self;
}

- (instancetype)initWithCommand:(const NSString *)cmd {
    if (self = [super initWithCommand:cmd]) {
        // lazy
        _message = nil;
        _envelope = nil;
        _signature = nil;
    }
    return self;
}

- (instancetype)initWithMessage:(const NSString *)message {
    if (self = [self initWithCommand:DKDSystemCommand_Receipt]) {
        // message
        if (message) {
            [_storeDictionary setObject:message forKey:@"message"];
        }
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMReceiptCommand *command = [super copyWithZone:zone];
    if (command) {
        command.message = _message;
        command.envelope = _envelope;
        command.signature = _signature;
    }
    return self;
}

- (NSString *)message {
    if (!_message) {
        _message = [_storeDictionary objectForKey:@"message"];
    }
    return _message;
}

- (DIMEnvelope *)envelope {
    if (!_envelope) {
        NSString *sender = [_storeDictionary objectForKey:@"sender"];
        NSString *receiver = [_storeDictionary objectForKey:@"receiver"];
        if (sender != nil && receiver != nil) {
            NSNumber *number = [_storeDictionary objectForKey:@"time"];
            NSDate *time = NSDateFromNumber(number);
            
            _envelope = [[DIMEnvelope alloc] initWithSender:sender
                                                   receiver:receiver
                                                       time:time];
        }
    }
    return _envelope;
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
    if (!_signature) {
        NSString *CT = [_storeDictionary objectForKey:@"signature"];
        _signature = [CT base64Decode];
    }
    return _signature;
}

- (void)setSignature:(NSData *)signature {
    if (signature) {
        [_storeDictionary setObject:[signature base64Encode] forKey:@"signature"];
    } else {
        [_storeDictionary removeObjectForKey:@"signature"];
    }
}

@end
