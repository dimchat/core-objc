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

static NSMutableDictionary<NSString *, id<DIMCommandFactory>> *s_factories = nil;

id<DIMCommandFactory> DIMCommandGetFactory(NSString *name) {
    return [s_factories objectForKey:name];
}

void DIMCommandSetFactory(NSString *name, id<DIMCommandFactory> factory) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //if (!s_factories) {
            s_factories = [[NSMutableDictionary alloc] init];
        //}
    });
    [s_factories setObject:factory forKey:name];
}

NSString *DIMCommandGetName(NSDictionary *cmd) {
    return [cmd objectForKey:@"command"];
}

#pragma mark - Base Command

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

- (NSString *)command {
    if (!_command) {
        _command = DIMCommandGetName(self.dictionary);
    }
    return _command;
}

@end

#pragma mark -

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

- (nullable id<DIMCommand>)parseCommand:(NSDictionary *)cmd {
    if (self.block == NULL) {
        return [[DIMCommand alloc] initWithDictionary:cmd];
    }
    return self.block(cmd);
}

- (nullable id<DKDContent>)parseContent:(NSDictionary *)content {
    // get factory by command name
    NSString *command = DIMCommandGetName(content);
    id<DIMCommandFactory> factory = DIMCommandGetFactory(command);
    if (!factory) {
        // check for group commands
        if (DKDContentGetGroup(content)) {
            factory = DIMCommandGetFactory(@"group");
        }
        if (!factory) {
            factory = self;
        }
    }
    return [factory parseCommand:content];
}

@end

void DIMRegisterCommandFactories(void) {

    // Meta Command
    DIMCommandFactoryRegisterClass(DIMCommand_Meta, DIMMetaCommand);

    // Document Command
    DIMCommandFactoryRegisterClass(DIMCommand_Document, DIMDocumentCommand);

    // Group Commands
    DIMCommandFactoryRegister(@"group", [[DIMGroupCommandFactory alloc] init]);
    DIMCommandFactoryRegisterClass(DIMGroupCommand_Invite, DIMInviteCommand);
    DIMCommandFactoryRegisterClass(DIMGroupCommand_Expel, DIMExpelCommand);
    DIMCommandFactoryRegisterClass(DIMGroupCommand_Join, DIMJoinCommand);
    DIMCommandFactoryRegisterClass(DIMGroupCommand_Quit, DIMQuitCommand);
    DIMCommandFactoryRegisterClass(DIMGroupCommand_Query, DIMQueryGroupCommand);
    DIMCommandFactoryRegisterClass(DIMGroupCommand_Reset, DIMResetGroupCommand);
}
