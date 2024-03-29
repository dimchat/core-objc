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

#import "DIMFactoryManager.h"

#import "DIMCommand.h"

id<DKDCommandFactory> DIMCommandGetFactory(NSString *cmd) {
    DIMCommandFactoryManager *man = [DIMCommandFactoryManager sharedManager];
    return [man.generalFactory commandFactoryForName:cmd];
}

void DKDCommandSetFactory(NSString *cmd, id<DKDCommandFactory> factory) {
    DIMCommandFactoryManager *man = [DIMCommandFactoryManager sharedManager];
    [man.generalFactory setCommandFactory:factory forName:cmd];
}

id<DKDCommand> DKDCommandParse(id content) {
    DIMCommandFactoryManager *man = [DIMCommandFactoryManager sharedManager];
    return [man.generalFactory parseCommand:content];
}

DIMCommand *DIMCommandCreate(NSString *cmd) {
    return [[DIMCommand alloc] initWithCommandName:cmd];
}

#pragma mark - Base Command

@implementation DIMCommand

- (instancetype)initWithType:(DKDContentType)type commandName:(NSString *)cmd {
    if (self = [self initWithType:type]) {
        NSAssert(cmd.length > 0, @"command name cannot be empty");
        [self setObject:cmd forKey:@"command"];
    }
    return self;
}

- (instancetype)initWithCommandName:(NSString *)cmd {
    if (self = [self initWithType:DKDContentType_Command commandName:cmd]) {
        //
    }
    return self;
}

- (NSString *)cmd {
    DIMCommandFactoryManager *man = [DIMCommandFactoryManager sharedManager];
    return [man.generalFactory getCmd:self.dictionary defaultValue:@""];
}

@end
