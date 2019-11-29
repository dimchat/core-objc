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

#import "DIMHistoryCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMGroupCommand : DIMHistoryCommand

// Group ID for group message already defined in DKDContent
//@property (strong, nonatomic, nullable) DIMID *group;

@property (readonly, strong, nonatomic, nullable) NSString *member;
@property (readonly, strong, nonatomic, nullable) NSArray<NSString *> *members;

/*
 *  Group history command: {
 *      type : 0x89,
 *      sn   : 123,
 *
 *      command : "join",      // or quit
 *      group   : "{GROUP_ID}",
 *  }
 */
- (instancetype)initWithCommand:(NSString *)cmd
                          group:(DIMID *)groupID;

/*
 *  Group history command: {
 *      type : 0x89,
 *      sn   : 123,
 *
 *      command : "invite",      // or expel
 *      group   : "{GROUP_ID}",
 *      member  : "{MEMBER_ID}",
 *  }
 */
- (instancetype)initWithCommand:(NSString *)cmd
                          group:(DIMID *)groupID
                         member:(DIMID *)memberID;

/*
 *  Group history command: {
 *      type : 0x89,
 *      sn   : 123,
 *
 *      command : "invite",      // or expel
 *      group   : "{GROUP_ID}",
 *      members : ["{MEMBER_ID}", ],
 *  }
 */
- (instancetype)initWithCommand:(NSString *)cmd
                          group:(DIMID *)groupID
                        members:(NSArray<DIMID *> *)list;

@end

#pragma mark -

@interface DIMInviteCommand : DIMGroupCommand

- (instancetype)initWithGroup:(DIMID *)groupID
                       member:(DIMID *)memberID;

- (instancetype)initWithGroup:(DIMID *)groupID
                      members:(NSArray<DIMID *> *)list;

@end

@interface DIMExpelCommand : DIMGroupCommand

- (instancetype)initWithGroup:(DIMID *)groupID
                       member:(DIMID *)memberID;

- (instancetype)initWithGroup:(DIMID *)groupID
                      members:(NSArray<DIMID *> *)list;

@end

@interface DIMJoinCommand : DIMGroupCommand

- (instancetype)initWithGroup:(DIMID *)groupID;

@end

@interface DIMQuitCommand : DIMGroupCommand

- (instancetype)initWithGroup:(DIMID *)groupID;

@end

#pragma mark -

@interface DIMResetGroupCommand : DIMGroupCommand

- (instancetype)initWithGroup:(DIMID *)groupID
                      members:(NSArray<DIMID *> *)list;

@end

@interface DIMQueryGroupCommand : DIMGroupCommand

- (instancetype)initWithGroup:(DIMID *)groupID;

@end

NS_ASSUME_NONNULL_END
