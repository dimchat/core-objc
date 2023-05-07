// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2023 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2023 Albert Moky
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
//  DIMFactoryManager.m
//  DIMCore
//
//  Created by Albert Moky on 2023/2/2.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DIMFactoryManager.h"

@implementation DIMCommandFactoryManager

static DIMCommandFactoryManager *s_manager = nil;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [super allocWithZone:zone];
        s_manager.generalFactory = [[DIMGeneralCommandFactory alloc] init];
    });
    return s_manager;
}

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[self alloc] init];
    });
    return s_manager;
}

@end

#pragma mark -

@interface DIMGeneralCommandFactory () {
    
    NSMutableDictionary<NSString *, id<DKDCommandFactory>> *_commandFactories;
}

@end

@implementation DIMGeneralCommandFactory

- (instancetype)init {
    if ([super init]) {
        _commandFactories = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark Command

- (void)setCommandFactory:(id<DKDCommandFactory>)factory forName:(NSString *)cmd {
    [_commandFactories setObject:factory forKey:cmd];
}

- (nullable id<DKDCommandFactory>)commandFactoryForName:(NSString *)cmd {
    return [_commandFactories objectForKey:cmd];
}

- (nullable NSString *)getCmd:(NSDictionary<NSString *,id> *)content {
    return [content objectForKey:@"command"];
}

- (nullable id<DKDCommand>)parseCommand:(id)content {
    if (!content) {
        return nil;
    } else if ([content conformsToProtocol:@protocol(DKDCommand)]) {
        return (id<DKDCommand>)content;
    }
    NSDictionary<NSString *, id> *info = MKMGetMap(content);
    NSAssert([info isKindOfClass:[NSDictionary class]], @"command error: %@", content);
    // get factory by command name
    NSString *cmd = [self getCmd:info];
    NSAssert(cmd, @"command name not found: %@", content);

    // get factory by command name
    id<DKDCommandFactory> factory = cmd.length == 0 ? nil : [self commandFactoryForName:cmd];
    if (!factory) {
        // unknown command name, get base command factory
        DKDFactoryManager *man = [DKDFactoryManager sharedManager];
        DKDGeneralFactory *gf = [man generalFactory];
        DKDContentType type = [gf contentType:info];
        NSAssert(type > 0, @"content type error: %@", content);
        id<DKDContentFactory> fact = [gf contentFactoryForType:type];
        if ([fact conformsToProtocol:@protocol(DKDCommandFactory)]) {
            factory = (id<DKDCommandFactory>)fact;
        } else {
            NSAssert(false, @"cannot parse command: %@", content);
        }
    }
    return [factory parseCommand:info];
}

@end
