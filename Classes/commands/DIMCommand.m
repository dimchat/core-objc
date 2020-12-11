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

#import "DIMMetaCommand.h"
#import "DIMDocumentCommand.h"
#import "DIMGroupCommand.h"

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
- (instancetype)initWithType:(DKDContentType)type {
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
            [self setObject:cmd forKey:@"command"];
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
        _command = [self objectForKey:@"command"];
    }
    return _command;
}

@end

#pragma mark - Creation

@implementation DIMCommandParser

static NSMutableDictionary *s_command_parsers = nil;

+ (void)registerParser:(id<DKDContentParser>)parser forCommand:(NSString *)name {
    if (!s_command_parsers) {
        s_command_parsers = [[NSMutableDictionary alloc] init];
    }
    [s_command_parsers setObject:parser forKey:name];
}

- (id<DKDContentParser>)parserForCommand:(NSString *)name {
    return [s_command_parsers objectForKey:name];
}

- (nullable __kindof id<DKDContent>)parse:(NSDictionary *)cmd {
    if (self.block) {
        return [super parse:cmd];
    }
    // Registered Commands
    NSString *command = [cmd objectForKey:@"command"];
    id<DKDContentParser> parser = [self parserForCommand:command];
    if (!parser) {
        // Check for group commands
        id group = [cmd objectForKey:@"group"];
        if (group) {
            parser = [self parserForCommand:@"group"];
        }
    }
    if (parser) {
        return [parser parse:cmd];
    }
    return [[DIMCommand alloc] initWithDictionary:cmd];
}

@end
