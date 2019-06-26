//
//  DIMCommand.m
//  DIMCore
//
//  Created by Albert Moky on 2019/1/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMContentType.h"

#import "DIMHandshakeCommand.h"
#import "DIMBroadcastCommand.h"
#import "DIMReceiptCommand.h"
#import "DIMMetaCommand.h"
#import "DIMProfileCommand.h"

#import "DIMCommand.h"

@interface DIMCommand ()

@property (strong, nonatomic) NSString *command;

@end

@implementation DIMCommand

- (instancetype)initWithCommand:(NSString *)cmd {
    NSAssert(cmd.length > 0, @"command name cannot be empty");
    if (self = [self initWithType:DIMContentType_Command]) {
        // command
        if (cmd) {
            [_storeDictionary setObject:cmd forKey:@"command"];
        }
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _command = nil;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMCommand *cmd = [super copyWithZone:zone];
    if (cmd) {
        cmd.command = _command;
    }
    return cmd;
}

- (NSString *)command {
    if (!_command) {
        _command = [_storeDictionary objectForKey:@"command"];
    }
    return _command;
}

@end

static NSMutableDictionary<NSString *, Class> *command_classes(void) {
    static NSMutableDictionary<NSString *, Class> *classes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classes = [[NSMutableDictionary alloc] init];
        // handshake
        [classes setObject:[DIMHandshakeCommand class] forKey:DIMSystemCommand_Handshake];
        // broadcast
        [classes setObject:[DIMBroadcastCommand class] forKey:DIMSystemCommand_Broadcast];
        // receipt
        [classes setObject:[DIMReceiptCommand class] forKey:DIMSystemCommand_Receipt];
        // meta
        [classes setObject:[DIMMetaCommand class] forKey:DIMSystemCommand_Meta];
        // profile
        [classes setObject:[DIMProfileCommand class] forKey:DIMSystemCommand_Profile];
    });
    return classes;
}

@implementation DIMCommand (Runtime)

+ (void)registerClass:(nullable Class)cmdClass forCommand:(NSString *)cmd {
    NSAssert(![cmdClass isEqual:self], @"only subclass");
    NSAssert([cmdClass isSubclassOfClass:self], @"class error: %@", cmdClass);
    if (cmdClass) {
        [command_classes() setObject:cmdClass forKey:cmd];
    } else {
        [command_classes() removeObjectForKey:cmd];
    }
}

+ (nullable instancetype)getInstance:(id)content {
    if (!content) {
        return nil;
    }
    if ([content isKindOfClass:[DIMCommand class]]) {
        // return Command object directly
        return content;
    }
    NSAssert([content isKindOfClass:[NSDictionary class]],
             @"command should be a dictionary: %@", content);
    if (![self isEqual:[DIMCommand class]]) {
        // subclass
        NSAssert([self isSubclassOfClass:[DIMCommand class]], @"command class error");
        return [[self alloc] initWithDictionary:content];
    }
    // create instance by subclass with command
    NSString *command = [content objectForKey:@"command"];
    Class clazz = [command_classes() objectForKey:command];
    if (clazz) {
        return [clazz getInstance:content];
    } else {
        return [[self alloc] initWithDictionary:content];
    }
}

@end
