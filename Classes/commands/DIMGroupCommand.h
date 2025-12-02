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
//  DIMGroupCommand.h
//  DIMCore
//
//  Created by Albert Moky on 2019/2/3.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <MingKeMing/MingKeMing.h>

#import <DIMCore/DIMHistoryCommand.h>

NS_ASSUME_NONNULL_BEGIN

//-------- group command names begin --------
/// group: founder/owner
FOUNDATION_EXPORT NSString * const DKDGroupCommand_Found;    // "found"
FOUNDATION_EXPORT NSString * const DKDGroupCommand_Abdicate; // "abdicate"
/// group: member
FOUNDATION_EXPORT NSString * const DKDGroupCommand_Invite;   // "invite"
FOUNDATION_EXPORT NSString * const DKDGroupCommand_Expel;    // Deprecated (use "reset" instead)
FOUNDATION_EXPORT NSString * const DKDGroupCommand_Join;     // "join"
FOUNDATION_EXPORT NSString * const DKDGroupCommand_Quit;     // "quit"
//FOUNDATION_EXPORT NSString * const DKDGroupCommand_Query;  // Deprecated
FOUNDATION_EXPORT NSString * const DKDGroupCommand_Reset;    // "reset"
/// group: administrator/assistant
FOUNDATION_EXPORT NSString * const DKDGroupCommand_Hire;     // "hire"
FOUNDATION_EXPORT NSString * const DKDGroupCommand_Fire;     // "fire"
FOUNDATION_EXPORT NSString * const DKDGroupCommand_Resign;   // "resign"
//-------- group command names end --------

/*
 *  Group history command: {
 *      type : i2s(0x89),
 *      sn   : 123,
 *
 *      command : "reset",   // "invite", "quit", "query", ...
 *      time    : 123.456,   // command timestamp
 *
 *      group   : "{GROUP_ID}",
 *      member  : "{MEMBER_ID}",
 *      members : ["{MEMBER_ID}",]
 *  }
 */
@protocol DKDGroupCommand <DKDHistoryCommand>

// Group ID for group message already defined in DKDContent
//@property (strong, nonatomic, nullable) id<MKMID> group;

@property (readonly, strong, nonatomic, nullable) id<MKMID> member;
@property (readonly, strong, nonatomic, nullable) NSArray<id<MKMID>> *members;

@end

@interface DIMGroupCommand : DIMHistoryCommand <DKDGroupCommand>

- (instancetype)initWithCmd:(NSString *)name
                      group:(id<MKMID>)gid;

- (instancetype)initWithCmd:(NSString *)name
                      group:(id<MKMID>)gid
                     member:(id<MKMID>)uid;

- (instancetype)initWithCmd:(NSString *)name
                      group:(id<MKMID>)gid
                    members:(NSArray<id<MKMID>> *)list;

@end

#pragma mark - Invite group command

@protocol DKDInviteGroupCommand <DKDGroupCommand> @end

@interface DIMInviteGroupCommand : DIMGroupCommand <DKDInviteGroupCommand>

- (instancetype)initWithGroup:(id<MKMID>)gid
                       member:(id<MKMID>)uid;

- (instancetype)initWithGroup:(id<MKMID>)gid
                      members:(NSArray<id<MKMID>> *)list;

@end

#pragma mark Expel group command - Deprecated

// Deprecated (use 'reset' instead)
@protocol DKDExpelGroupCommand <DKDGroupCommand> @end

@interface DIMExpelGroupCommand : DIMGroupCommand <DKDExpelGroupCommand>

- (instancetype)initWithGroup:(id<MKMID>)gid
                       member:(id<MKMID>)uid;

- (instancetype)initWithGroup:(id<MKMID>)gid
                      members:(NSArray<id<MKMID>> *)list;

@end

#pragma mark Join group command

@protocol DKDJoinGroupCommand <DKDGroupCommand> @end

@interface DIMJoinGroupCommand : DIMGroupCommand <DKDJoinGroupCommand>

- (instancetype)initWithGroup:(id<MKMID>)gid;

@end

#pragma mark Quit group command

@protocol DKDQuitGroupCommand <DKDGroupCommand> @end

@interface DIMQuitGroupCommand : DIMGroupCommand <DKDQuitGroupCommand>

- (instancetype)initWithGroup:(id<MKMID>)gid;

@end

#pragma mark Reset group command

@protocol DKDResetGroupCommand <DKDGroupCommand> @end

@interface DIMResetGroupCommand : DIMGroupCommand <DKDResetGroupCommand>

- (instancetype)initWithGroup:(id<MKMID>)gid
                      members:(NSArray<id<MKMID>> *)list;

@end

#pragma mark - Conveniences

#ifdef __cplusplus
extern "C" {
#endif

DIMGroupCommand *DIMGroupCommandCreate(NSString *cmd,
                                       id<MKMID> group,
                                       NSArray<id<MKMID>> *members);

DIMInviteGroupCommand *DIMGroupCommandInvite(id<MKMID> group,
                                             NSArray<id<MKMID>> *members);

DIMExpelGroupCommand *DIMGroupCommandExpel(id<MKMID> group,
                                           NSArray<id<MKMID>> *members);

DIMJoinGroupCommand *DIMGroupCommandJoin(id<MKMID> group);

DIMQuitGroupCommand *DIMGroupCommandQuit(id<MKMID> group);

DIMResetGroupCommand *DIMGroupCommandReset(id<MKMID> group,
                                           NSArray<id<MKMID>> *members);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
