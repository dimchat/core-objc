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

NSString * const DIMGroupCommand_Found    = @"found";
NSString * const DIMGroupCommand_Abdicate = @"abdicate";

NSString * const DIMGroupCommand_Invite   = @"invite";
NSString * const DIMGroupCommand_Expel    = @"expel"; // Deprecated
NSString * const DIMGroupCommand_Join     = @"join";
NSString * const DIMGroupCommand_Quit     = @"quit";
//NSString * const DIMGroupCommand_Query  = @"query"; // Deprecated
NSString * const DIMGroupCommand_Reset    = @"reset";

NSString * const DIMGroupCommand_Hire     = @"hire";
NSString * const DIMGroupCommand_Fire     = @"fire";
NSString * const DIMGroupCommand_Resign   = @"resign";

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
                     member:(id<MKMID>)uid {
    
    if (self = [self initWithCmd:cmd]) {
        [self setString:gid forKey:@"group"];
        [self setString:uid forKey:@"member"];
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

- (nullable id<MKMID>)member {
    id user = [self objectForKey:@"member"];
    return MKMIDParse(user);
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

@implementation DIMInviteGroupCommand

- (instancetype)initWithGroup:(id<MKMID>)gid member:(id<MKMID>)uid {
    return [self initWithCmd:DIMGroupCommand_Invite group:gid member:uid];
}

- (instancetype)initWithGroup:(id<MKMID>)gid members:(NSArray<id<MKMID>> *)list {
    return [self initWithCmd:DIMGroupCommand_Invite group:gid members:list];
}

@end

@implementation DIMExpelGroupCommand

- (instancetype)initWithGroup:(id<MKMID>)gid member:(id<MKMID>)uid {
    return [self initWithCmd:DIMGroupCommand_Expel group:gid member:uid];
}

- (instancetype)initWithGroup:(id<MKMID>)gid members:(NSArray<id<MKMID>> *)list {
    return [self initWithCmd:DIMGroupCommand_Expel group:gid members:list];
}

@end

@implementation DIMJoinGroupCommand

- (instancetype)initWithGroup:(id<MKMID>)gid {
    return [self initWithCmd:DIMGroupCommand_Join group:gid];
}

@end

@implementation DIMQuitGroupCommand

- (instancetype)initWithGroup:(id<MKMID>)gid {
    return [self initWithCmd:DIMGroupCommand_Quit group:gid];
}

@end

@implementation DIMResetGroupCommand

- (instancetype)initWithGroup:(id<MKMID>)gid members:(NSArray<id<MKMID>> *)list {
    return [self initWithCmd:DIMGroupCommand_Reset group:gid members:list];
}

@end

#pragma mark - Administrators, Assistants

@implementation DIMHireGroupCommand

- (instancetype)initWithGroup:(id<MKMID>)gid
               administrators:(NSArray<id<MKMID>> *)users {
    if (self = [self initWithCmd:DIMGroupCommand_Hire group:gid]) {
        self.administrators = users;
    }
    return self;
}

- (instancetype)initWithGroup:(id<MKMID>)gid
                   assistants:(NSArray<id<MKMID>> *)bots {
    if (self = [self initWithCmd:DIMGroupCommand_Hire group:gid]) {
        self.assistants = bots;
    }
    return self;
}

- (NSArray<id<MKMID>> *)administrators {
    NSArray *array = [self objectForKey:@"administrators"];
    if (array.count == 0) {
        return nil;
    }
    return MKMIDConvert(array);
}

- (void)setAdministrators:(NSArray<id<MKMID>> *)administrators {
    NSArray *array = MKMIDRevert(administrators);
    [self setObject:array forKey:@"administrators"];
}

- (NSArray<id<MKMID>> *)assistants {
    NSArray *array = [self objectForKey:@"assistants"];
    if (array.count == 0) {
        return nil;
    }
    return MKMIDConvert(array);
}

- (void)setAssistants:(NSArray<id<MKMID>> *)assistants {
    NSArray *array = MKMIDRevert(assistants);
    [self setObject:array forKey:@"assistants"];
}

@end

@implementation DIMFireGroupCommand

- (instancetype)initWithGroup:(id<MKMID>)gid
               administrators:(NSArray<id<MKMID>> *)users {
    if (self = [self initWithCmd:DIMGroupCommand_Fire group:gid]) {
        self.administrators = users;
    }
    return self;
}

- (instancetype)initWithGroup:(id<MKMID>)gid
                   assistants:(NSArray<id<MKMID>> *)bots {
    if (self = [self initWithCmd:DIMGroupCommand_Fire group:gid]) {
        self.assistants = bots;
    }
    return self;
}

- (NSArray<id<MKMID>> *)administrators {
    NSArray *array = [self objectForKey:@"administrators"];
    if (array.count == 0) {
        return nil;
    }
    return MKMIDConvert(array);
}

- (void)setAdministrators:(NSArray<id<MKMID>> *)administrators {
    NSArray *array = MKMIDRevert(administrators);
    [self setObject:array forKey:@"administrators"];
}

- (NSArray<id<MKMID>> *)assistants {
    NSArray *array = [self objectForKey:@"assistants"];
    if (array.count == 0) {
        return nil;
    }
    return MKMIDConvert(array);
}

- (void)setAssistants:(NSArray<id<MKMID>> *)assistants {
    NSArray *array = MKMIDRevert(assistants);
    [self setObject:array forKey:@"assistants"];
}

@end

@implementation DIMResignGroupCommand

- (instancetype)initWithGroup:(id<MKMID>)gid {
    if (self = [self initWithCmd:DIMGroupCommand_Resign group:gid]) {
        //
    }
    return self;
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

#pragma mark Administrators, Assistants

DIMHireGroupCommand *DIMGroupCommandHireAdministrators(id<MKMID> group,
                                                       NSArray<id<MKMID>> *admins) {
    return [[DIMHireGroupCommand alloc] initWithGroup:group administrators:admins];
}

DIMHireGroupCommand *DIMGroupCommandHireAssistants(id<MKMID> group,
                                                   NSArray<id<MKMID>> *bots) {
    return [[DIMHireGroupCommand alloc] initWithGroup:group assistants:bots];
}

DIMFireGroupCommand *DIMGroupCommandFireAdministrators(id<MKMID> group,
                                                       NSArray<id<MKMID>> *admins) {
    return [[DIMFireGroupCommand alloc] initWithGroup:group administrators:admins];
}

DIMFireGroupCommand *DIMGroupCommandFireAssistants(id<MKMID> group,
                                                   NSArray<id<MKMID>> *bots) {
    return [[DIMFireGroupCommand alloc] initWithGroup:group assistants:bots];
}

DIMResignGroupCommand *DIMGroupCommandResign(id<MKMID> group) {
    return [[DIMResignGroupCommand alloc] initWithGroup:group];
}
