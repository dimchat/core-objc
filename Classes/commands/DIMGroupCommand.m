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
//  DIMGroupCommand.m
//  DIMCore
//
//  Created by Albert Moky on 2019/2/3.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "DIMGroupCommand.h"

@implementation DIMGroupCommand

- (instancetype)initWithCommand:(NSString *)cmd
                          group:(DIMID *)groupID {
    
    if (self = [self initWithHistoryCommand:cmd]) {
        // Group ID
        if (groupID) {
            [_storeDictionary setObject:groupID forKey:@"group"];
        }
    }
    return self;
}

- (instancetype)initWithCommand:(NSString *)cmd
                          group:(DIMID *)groupID
                         member:(DIMID *)memberID {
    
    if (self = [self initWithHistoryCommand:cmd]) {
        // Group ID
        if (groupID) {
            [_storeDictionary setObject:groupID forKey:@"group"];
        }
        // Member ID
        if (memberID) {
            [_storeDictionary setObject:memberID forKey:@"member"];
        }
    }
    return self;
}

- (instancetype)initWithCommand:(NSString *)cmd
                          group:(DIMID *)groupID
                        members:(NSArray<DIMID *> *)list {
    
    if (self = [self initWithHistoryCommand:cmd]) {
        // Group ID
        if (groupID) {
            [_storeDictionary setObject:groupID forKey:@"group"];
        }
        // Members
        if (list.count > 0) {
            [_storeDictionary setObject:list forKey:@"members"];
        }
    }
    return self;
}

- (nullable NSString *)member {
    return [_storeDictionary objectForKey:@"member"];
}

- (NSArray<NSString *> *)members {
    return [_storeDictionary objectForKey:@"members"];
}

@end

@implementation DIMGroupCommand (Runtime)

+ (nullable Class)classForGroupCommand:(NSString *)cmd {
    // NOTICE: here combine all group commands into common command pool
    return [super classForCommand:cmd];
}

+ (nullable instancetype)getInstance:(id)content {
    if (!content) {
        return nil;
    }
    if ([content isKindOfClass:[DIMGroupCommand class]]) {
        // return GroupCommand object directly
        return content;
    }
    NSAssert([content isKindOfClass:[NSDictionary class]], @"group command error: %@", content);
    if ([self isEqual:[DIMGroupCommand class]]) {
        // create instance by subclass with group command name
        NSString *command = [content objectForKey:@"command"];
        Class clazz = [self classForGroupCommand:command];
        if (clazz) {
            return [clazz getInstance:content];
        }
    }
    // custom group command
    return [[self alloc] initWithDictionary:content];
}

@end

#pragma mark -

@implementation DIMInviteCommand

- (instancetype)initWithGroup:(DIMID *)groupID
                       member:(DIMID *)memberID {
    
    return [super initWithCommand:DIMGroupCommand_Invite
                            group:groupID
                           member:memberID];
}

- (instancetype)initWithGroup:(DIMID *)groupID
                      members:(NSArray<DIMID *> *)list {
    
    return [super initWithCommand:DIMGroupCommand_Invite
                            group:groupID
                          members:list];
}

@end

@implementation DIMExpelCommand

- (instancetype)initWithGroup:(DIMID *)groupID
                       member:(DIMID *)memberID {
    
    return [super initWithCommand:DIMGroupCommand_Expel
                            group:groupID
                           member:memberID];
}

- (instancetype)initWithGroup:(DIMID *)groupID
                      members:(NSArray<DIMID *> *)list {
    
    return [super initWithCommand:DIMGroupCommand_Expel
                            group:groupID
                          members:list];
}

@end

@implementation DIMJoinCommand

- (instancetype)initWithGroup:(DIMID *)groupID {
    
    return [super initWithCommand:DIMGroupCommand_Join group:groupID];
}

@end

@implementation DIMQuitCommand

- (instancetype)initWithGroup:(DIMID *)groupID {
    
    return [super initWithCommand:DIMGroupCommand_Quit group:groupID];
}

@end

#pragma mark -

@implementation DIMResetGroupCommand

- (instancetype)initWithGroup:(DIMID *)groupID
                      members:(NSArray<DIMID *> *)list {
    
    return [super initWithCommand:DIMGroupCommand_Reset group:groupID members:list];
}

@end

@implementation DIMQueryGroupCommand

- (instancetype)initWithGroup:(DIMID *)groupID {
    
    return [super initWithCommand:DIMGroupCommand_Query group:groupID];
}

@end
