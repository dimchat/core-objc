//
//  DIMCommand.m
//  DIMCore
//
//  Created by Albert Moky on 2019/1/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMCommand.h"

@interface DIMCommand ()

@property (strong, nonatomic) NSString *command;

@end

@implementation DIMCommand

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _command = nil;
    }
    return self;
}

- (instancetype)initWithType:(DKDMessageType)type {
    NSAssert(false, @"DON'T call me");
    return [self initWithCommand:@"NOOP"];
}

/* designated initializer */
- (instancetype)initWithCommand:(NSString *)cmd {
    NSAssert(cmd, @"command name cannot be empty");
    if (self = [super initWithType:DKDMessageType_Command]) {
        // command
        if (cmd) {
            [_storeDictionary setObject:cmd forKey:@"command"];
        }
        _command = cmd;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMCommand *command = [super copyWithZone:zone];
    if (command) {
        command.command = _command;
    }
    return command;
}

- (NSString *)command {
    if (!_command) {
        _command = [_storeDictionary objectForKey:@"command"];
    }
    return _command;
}

@end
