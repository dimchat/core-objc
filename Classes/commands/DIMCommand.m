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

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMCommand *cmd = [super copyWithZone:zone];
    if (cmd) {
        cmd.command = _command;
    }
    return cmd;
}

+ (NSString *)command:(NSDictionary *)cmd {
    return [cmd objectForKey:@"command"];
}

- (NSString *)command {
    if (!_command) {
        _command = [DIMCommand command:self.dictionary];
    }
    return _command;
}

@end

#pragma mark - Creation

@interface DIMCommandFactory ()

@property (nonatomic, nullable) DIMCommandParserBlock block;

@end

@implementation DIMCommandFactory

- (instancetype)init {
    if (self = [super init]) {
        self.block = NULL;
    }
    return self;
}

- (instancetype)initWithBlock:(DIMCommandParserBlock)block {
    if (self = [super init]) {
        self.block = block;
    }
    return self;
}

- (nullable __kindof DIMCommand *)parseCommand:(NSDictionary *)cmd {
    if (self.block == NULL) {
        return [[DIMCommand alloc] initWithDictionary:cmd];
    }
    return self.block(cmd);
}

- (nullable __kindof id<DKDContent>)parseContent:(NSDictionary *)content {
    // get factory by command name
    NSString *command = [DIMCommand command:content];
    id<DIMCommandFactory> factory = [DIMCommand factoryForCommand:command];
    if (!factory) {
        // check for group commands
        if ([DKDContent group:content]) {
            factory = [DIMCommand factoryForCommand:@"group"];
        }
        if (!factory) {
            factory = self;
        }
    }
    return [factory parseCommand:content];
}

@end

@implementation DIMCommand (Creation)

static NSMutableDictionary<NSString *, id<DIMCommandFactory>> *s_factories = nil;

+ (void)setFactory:(id<DIMCommandFactory>)factory forCommand:(NSString *)name {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //if (!s_factories) {
            s_factories = [[NSMutableDictionary alloc] init];
        //}
    });
    [s_factories setObject:factory forKey:name];
}

+ (id<DIMCommandFactory>)factoryForCommand:(NSString *)name {
    NSAssert(s_factories, @"command factories not set yet");
    return [s_factories objectForKey:name];
}

@end

#pragma mark - Register Parsers

@implementation DIMCommandFactory (Register)

+ (void)registerCoreFactories {
    
    // Meta Command
    DIMCommandFactoryRegisterClass(DIMCommand_Meta, DIMMetaCommand);
    
    // Document Command
    id<DIMCommandFactory> docParser = DIMCommandFactoryWithClass(DIMDocumentCommand);
    DIMCommandFactoryRegister(DIMCommand_Profile, docParser);
    DIMCommandFactoryRegister(DIMCommand_Document, docParser);
    
    // Group Commands
    id<DIMCommandFactory> grpParser = [[DIMGroupCommandFactory alloc] init];
    DIMCommandFactoryRegister(@"group", grpParser);
    DIMCommandFactoryRegisterClass(DIMGroupCommand_Invite, DIMInviteCommand);
    DIMCommandFactoryRegisterClass(DIMGroupCommand_Expel, DIMExpelCommand);
    DIMCommandFactoryRegisterClass(DIMGroupCommand_Join, DIMJoinCommand);
    DIMCommandFactoryRegisterClass(DIMGroupCommand_Quit, DIMQuitCommand);
    DIMCommandFactoryRegisterClass(DIMGroupCommand_Query, DIMQueryGroupCommand);
    DIMCommandFactoryRegisterClass(DIMGroupCommand_Reset, DIMResetGroupCommand);
}

@end
