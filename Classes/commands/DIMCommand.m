// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2019 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// =============================================================================
//
//  DIMCommand.m
//  DIMCore
//
//  Created by Albert Moky on 2019/1/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

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

/* designated initializer */
- (instancetype)initWithType:(UInt8)type {
    if (self = [super initWithType:type]) {
        _command = nil;
    }
    return self;
}

- (instancetype)initWithCommand:(NSString *)cmd {
    NSAssert(cmd.length > 0, @"command name cannot be empty");
    if (self = [self initWithType:DKDContentType_Command]) {
        // command
        if (cmd) {
            [_storeDictionary setObject:cmd forKey:@"command"];
        }
        _command = cmd;
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
    SingletonDispatchOnce(^{
        classes = [[NSMutableDictionary alloc] init];
        //...
    });
    return classes;
}

@implementation DIMCommand (Runtime)

+ (void)registerClass:(nullable Class)cmdClass forCommand:(NSString *)cmd {
    NSAssert(![cmdClass isEqual:self], @"only subclass");
    if (cmdClass) {
        NSAssert([cmdClass isSubclassOfClass:self], @"error: %@", cmdClass);
        [command_classes() setObject:cmdClass forKey:cmd];
    } else {
        [command_classes() removeObjectForKey:cmd];
    }
}

+ (nullable Class)classForCommand:(NSString *)cmd {
    return [command_classes() objectForKey:cmd];
}

+ (nullable instancetype)getInstance:(id)content {
    if (!content) {
        return nil;
    }
    if ([content isKindOfClass:[DIMCommand class]]) {
        // return Command object directly
        return content;
    }
    NSAssert([content isKindOfClass:[NSDictionary class]], @"command error: %@", content);
    if ([self isEqual:[DIMCommand class]]) {
        // create instance by subclass with command name
        NSString *command = [content objectForKey:@"command"];
        Class clazz = [self classForCommand:command];
        if (clazz) {
            return [clazz getInstance:content];
        }
    }
    // custom command
    return [[self alloc] initWithDictionary:content];
}

@end
