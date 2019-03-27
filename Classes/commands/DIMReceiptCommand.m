//
//  DIMReceiptCommand.m
//  DIMCore
//
//  Created by Albert Moky on 2019/3/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMReceiptCommand.h"

@interface DIMReceiptCommand ()

@property (strong, nonatomic) NSString *message;

@end

@implementation DIMReceiptCommand

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _message = nil;
    }
    return self;
}

- (instancetype)initWithCommand:(const NSString *)cmd {
    if (self = [super initWithCommand:cmd]) {
        // lazy
        _message = nil;
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
    }
    return self;
}

- (NSString *)message {
    if (!_message) {
        _message = [_storeDictionary objectForKey:@"message"];
    }
    return _message;
}

@end
