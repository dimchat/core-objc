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

#import <DIMCore/DIMHistoryCommand.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DIMGroupCommand <DIMHistoryCommand>

// Group ID for group message already defined in DKDContent
//@property (strong, nonatomic, nullable) id<MKMID> group;

@property (readonly, strong, nonatomic, nullable) id<MKMID> member;
@property (readonly, strong, nonatomic, nullable) NSArray<id<MKMID>> *members;

@end

@interface DIMGroupCommand : DIMHistoryCommand <DIMGroupCommand>

/*
 *  Group history command: {
 *      type : 0x89,
 *      sn   : 123,
 *
 *      cmd     : "join",      // or quit
 *      group   : "{GROUP_ID}",
 *  }
 */
- (instancetype)initWithCommandName:(NSString *)cmd
                              group:(id<MKMID>)groupID;

/*
 *  Group history command: {
 *      type : 0x89,
 *      sn   : 123,
 *
 *      cmd     : "invite",      // or expel
 *      group   : "{GROUP_ID}",
 *      member  : "{MEMBER_ID}",
 *  }
 */
- (instancetype)initWithCommandName:(NSString *)cmd
                              group:(id<MKMID>)groupID
                             member:(id<MKMID>)memberID;

/*
 *  Group history command: {
 *      type : 0x89,
 *      sn   : 123,
 *
 *      cmd     : "invite",      // or expel
 *      group   : "{GROUP_ID}",
 *      members : ["{MEMBER_ID}", ],
 *  }
 */
- (instancetype)initWithCommandName:(NSString *)cmd
                              group:(id<MKMID>)groupID
                            members:(NSArray<id<MKMID>> *)list;

@end

#pragma mark - Invite group command

@protocol DIMInviteCommand <DIMGroupCommand> @end

@interface DIMInviteCommand : DIMGroupCommand <DIMInviteCommand>

- (instancetype)initWithGroup:(id<MKMID>)groupID
                       member:(id<MKMID>)memberID;

- (instancetype)initWithGroup:(id<MKMID>)groupID
                      members:(NSArray<id<MKMID>> *)list;

@end

#pragma mark Expel group command

@protocol DIMExpelCommand <DIMGroupCommand> @end

@interface DIMExpelCommand : DIMGroupCommand <DIMExpelCommand>

- (instancetype)initWithGroup:(id<MKMID>)groupID
                       member:(id<MKMID>)memberID;

- (instancetype)initWithGroup:(id<MKMID>)groupID
                      members:(NSArray<id<MKMID>> *)list;

@end

#pragma mark Join group command

@protocol DIMJoinCommand <DIMGroupCommand> @end

@interface DIMJoinCommand : DIMGroupCommand <DIMJoinCommand>

- (instancetype)initWithGroup:(id<MKMID>)groupID;

@end

#pragma mark Quit group command

@protocol DIMQuitCommand <DIMGroupCommand> @end

@interface DIMQuitCommand : DIMGroupCommand <DIMQuitCommand>

- (instancetype)initWithGroup:(id<MKMID>)groupID;

@end

#pragma mark Reset group command

@protocol DIMResetGroupCommand <DIMGroupCommand> @end

@interface DIMResetGroupCommand : DIMGroupCommand <DIMResetGroupCommand>

- (instancetype)initWithGroup:(id<MKMID>)groupID
                      members:(NSArray<id<MKMID>> *)list;

@end

#pragma mark Query group command

@protocol DIMQueryGroupCommand <DIMGroupCommand> @end

@interface DIMQueryGroupCommand : DIMGroupCommand <DIMQueryGroupCommand>

- (instancetype)initWithGroup:(id<MKMID>)groupID;

@end

#pragma mark - Creation

@interface DIMGroupCommandFactory : DIMHistoryCommandFactory

@end

NS_ASSUME_NONNULL_END
