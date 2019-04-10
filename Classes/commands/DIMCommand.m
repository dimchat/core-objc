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

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _command = nil;
    }
    return self;
}

- (instancetype)initWithType:(DIMMessageType)type {
    NSAssert(false, @"DON'T call me");
    return [self initWithCommand:@"NOOP"];
}

/* designated initializer */
- (instancetype)initWithCommand:(const NSString *)cmd {
    NSAssert(cmd.length > 0, @"command name cannot be empty");
    if (self = [super initWithType:DIMMessageType_Command]) {
        // command
        if (cmd) {
            [_storeDictionary setObject:cmd forKey:@"command"];
        }
        _command = nil; // lazy
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

#pragma mark -

@interface DIMHistoryCommand ()

@property (strong, nonatomic) NSString *command;

@end

@implementation DIMHistoryCommand

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _command = nil;
    }
    return self;
}

- (instancetype)initWithType:(DIMMessageType)type {
    NSAssert(false, @"DON'T call me");
    return [self initWithHistoryCommand:@"NOOP"];
}

- (instancetype)initWithCommand:(const NSString *)cmd {
    NSAssert(false, @"DON'T call me");
    return [self initWithHistoryCommand:@"NOOP"];
}

/* designated initializer */
- (instancetype)initWithHistoryCommand:(const NSString *)cmd {
    NSAssert(cmd.length > 0, @"command name cannot be empty");
    if (self = [super initWithType:DIMMessageType_History]) {
        // command
        if (cmd) {
            [_storeDictionary setObject:cmd forKey:@"command"];
        }
        _command = nil; // lazy
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMHistoryCommand *command = [super copyWithZone:zone];
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
