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

#import "DIMGroupCommand.h"

@implementation DIMGroupCommand

- (instancetype)initWithCommand:(NSString *)cmd
                          group:(id<MKMID>)groupID {
    
    if (self = [self initWithHistoryCommand:cmd]) {
        // Group ID
        if (groupID) {
            [self setObject:groupID forKey:@"group"];
        }
    }
    return self;
}

- (instancetype)initWithCommand:(NSString *)cmd
                          group:(id<MKMID>)groupID
                         member:(id<MKMID>)memberID {
    
    if (self = [self initWithHistoryCommand:cmd]) {
        // Group ID
        if (groupID) {
            [self setObject:groupID forKey:@"group"];
        }
        // Member ID
        if (memberID) {
            [self setObject:memberID forKey:@"member"];
        }
    }
    return self;
}

- (instancetype)initWithCommand:(NSString *)cmd
                          group:(id<MKMID>)groupID
                        members:(NSArray<id<MKMID>> *)list {
    
    if (self = [self initWithHistoryCommand:cmd]) {
        // Group ID
        if (groupID) {
            [self setObject:groupID forKey:@"group"];
        }
        // Members
        if (list.count > 0) {
            [self setObject:MKMIDRevert(list) forKey:@"members"];
        }
    }
    return self;
}

- (nullable id<MKMID>)member {
    return MKMIDFromString([self objectForKey:@"member"]);
}

- (nullable NSArray<id<MKMID>> *)members {
    NSArray *array = [self objectForKey:@"members"];
    if (array.count == 0) {
        return nil;
    }
    return MKMIDConvert(array);
}

@end

#pragma mark -

@implementation DIMInviteCommand

- (instancetype)initWithGroup:(id<MKMID>)groupID member:(id<MKMID>)memberID {
    return [self initWithCommand:DIMGroupCommand_Invite group:groupID member:memberID];
}

- (instancetype)initWithGroup:(id<MKMID>)groupID members:(NSArray<id<MKMID>> *)list {
    return [self initWithCommand:DIMGroupCommand_Invite group:groupID members:list];
}

@end

@implementation DIMExpelCommand

- (instancetype)initWithGroup:(id<MKMID>)groupID member:(id<MKMID>)memberID {
    return [self initWithCommand:DIMGroupCommand_Expel group:groupID member:memberID];
}

- (instancetype)initWithGroup:(id<MKMID>)groupID members:(NSArray<id<MKMID>> *)list {
    return [self initWithCommand:DIMGroupCommand_Expel group:groupID members:list];
}

@end

@implementation DIMJoinCommand

- (instancetype)initWithGroup:(id<MKMID>)groupID {
    return [self initWithCommand:DIMGroupCommand_Join group:groupID];
}

@end

@implementation DIMQuitCommand

- (instancetype)initWithGroup:(id<MKMID>)groupID {
    return [self initWithCommand:DIMGroupCommand_Quit group:groupID];
}

@end

#pragma mark -

@implementation DIMResetGroupCommand

- (instancetype)initWithGroup:(id<MKMID>)groupID members:(NSArray<id<MKMID>> *)list {
    return [self initWithCommand:DIMGroupCommand_Reset group:groupID members:list];
}

@end

@implementation DIMQueryGroupCommand

- (instancetype)initWithGroup:(id<MKMID>)groupID {
    return [self initWithCommand:DIMGroupCommand_Query group:groupID];
}

@end

#pragma mark - Creation

@implementation DIMGroupCommandFactory

- (nullable id<DIMCommand>)parseCommand:(NSDictionary *)cmd {
    if (self.block == NULL) {
        return [[DIMGroupCommand alloc] initWithDictionary:cmd];
    }
    return self.block(cmd);
}

- (nullable id<DKDContent>)parseContent:(NSDictionary *)content {
    // get factory by command name
    NSString *command = DIMCommandGetName(content);
    id<DIMCommandFactory> parser = DIMCommandGetFactory(command);
    if (!parser) {
        parser = self;
    }
    return [parser parseCommand:content];
}

@end
