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

NSString * const DKDGroupCommand_Found    = @"found";
NSString * const DKDGroupCommand_Abdicate = @"abdicate";

NSString * const DKDGroupCommand_Invite   = @"invite";
NSString * const DKDGroupCommand_Expel    = @"expel"; // Deprecated
NSString * const DKDGroupCommand_Join     = @"join";
NSString * const DKDGroupCommand_Quit     = @"quit";
//NSString * const DKDGroupCommand_Query  = @"query"; // Deprecated
NSString * const DKDGroupCommand_Reset    = @"reset";

NSString * const DKDGroupCommand_Hire     = @"hire";
NSString * const DKDGroupCommand_Fire     = @"fire";
NSString * const DKDGroupCommand_Resign   = @"resign";

#pragma mark -

@implementation DIMGroupCommand

- (instancetype)initWithCmd:(NSString *)cmd
                      group:(id<MKMID>)gid {
    if (self = [self initWithCmd:cmd]) {
        [self setString:gid forKey:@"group"];
    }
    return self;
}

- (instancetype)initWithCmd:(NSString *)cmd
                      group:(id<MKMID>)gid
                    members:(NSArray<id<MKMID>> *)list {
    if (self = [self initWithCmd:cmd]) {
        [self setString:gid forKey:@"group"];
        [self setObject:MKMIDRevert(list) forKey:@"members"];
    }
    return self;
}

// Override
- (nullable NSArray<id<MKMID>> *)members {
    NSArray *array = [self objectForKey:@"members"];
    if (array) {
        return MKMIDConvert(array);
    }
    // get from 'member'
    id<MKMID> single = MKMIDParse([self objectForKey:@"member"]);
    if (single) {
        return @[single];
    }
    NSAssert(false, @"failed to get group members");
    return nil;
}

// Override
- (void)setMembers:(NSArray<id<MKMID>> *)members {
    if (members) {
        [self setObject:MKMIDRevert(members) forKey:@"members"];
    } else {
        [self removeObjectForKey:@"members"];
    }
    [self removeObjectForKey:@"member"];
}

@end

#pragma mark -

@implementation DIMInviteGroupCommand

- (instancetype)initWithGroup:(id<MKMID>)gid members:(NSArray<id<MKMID>> *)list {
    return [self initWithCmd:DKDGroupCommand_Invite group:gid members:list];
}

@end

@implementation DIMExpelGroupCommand

- (instancetype)initWithGroup:(id<MKMID>)gid members:(NSArray<id<MKMID>> *)list {
    return [self initWithCmd:DKDGroupCommand_Expel group:gid members:list];
}

@end

@implementation DIMJoinGroupCommand

- (instancetype)initWithGroup:(id<MKMID>)gid {
    return [self initWithCmd:DKDGroupCommand_Join group:gid];
}

@end

@implementation DIMQuitGroupCommand

- (instancetype)initWithGroup:(id<MKMID>)gid {
    return [self initWithCmd:DKDGroupCommand_Quit group:gid];
}

@end

@implementation DIMResetGroupCommand

- (instancetype)initWithGroup:(id<MKMID>)gid members:(NSArray<id<MKMID>> *)list {
    return [self initWithCmd:DKDGroupCommand_Reset group:gid members:list];
}

@end

#pragma mark - Conveniences

DIMGroupCommand *DIMGroupCommandCreate(NSString *cmd,
                                       id<MKMID> group,
                                       NSArray<id<MKMID>> *members) {
    return [[DIMGroupCommand alloc] initWithCmd:cmd group:group members:members];
}

DIMInviteGroupCommand *DIMGroupCommandInvite(id<MKMID> group,
                                             NSArray<id<MKMID>> *members) {
    return [[DIMInviteGroupCommand alloc] initWithGroup:group members:members];
}

DIMExpelGroupCommand *DIMGroupCommandExpel(id<MKMID> group,
                                           NSArray<id<MKMID>> *members) {
    return [[DIMExpelGroupCommand alloc] initWithGroup:group members:members];
}

DIMJoinGroupCommand *DIMGroupCommandJoin(id<MKMID> group) {
    return [[DIMJoinGroupCommand alloc] initWithGroup:group];
}

DIMQuitGroupCommand *DIMGroupCommandQuit(id<MKMID> group) {
    return [[DIMQuitGroupCommand alloc] initWithGroup:group];
}

DIMResetGroupCommand *DIMGroupCommandReset(id<MKMID> group,
                                           NSArray<id<MKMID>> *members) {
    return [[DIMResetGroupCommand alloc] initWithGroup:group members:members];
}
