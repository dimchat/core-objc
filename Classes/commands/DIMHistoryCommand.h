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
//  DIMHistoryCommand.h
//  DIMCore
//
//  Created by Albert Moky on 2019/1/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMCore/DIMCommand.h>

NS_ASSUME_NONNULL_BEGIN

/*
 *  History command: {
 *      type : 0x89,
 *      sn   : 123,
 *
 *      command : "...", // command name
 *      time    : 0,     // timestamp
 *      extra   : info   // command parameters
 *  }
 */
@protocol DIMHistoryCommand <DIMCommand>

@end

@interface DIMHistoryCommand : DIMCommand <DIMHistoryCommand>

- (instancetype)initWithHistoryCommand:(NSString *)cmd;

@end

#pragma mark Account history command

// account
#define DIMHistoryCommand_Register  @"register"
#define DIMHistoryCommand_Suicide   @"suicide"

#pragma mark Group history command

// group: founder/owner
#define DIMGroupCommand_Found      @"found"
#define DIMGroupCommand_Abdicate   @"abdicate"
// group: member
#define DIMGroupCommand_Invite     @"invite"
#define DIMGroupCommand_Expel      @"expel"
#define DIMGroupCommand_Join       @"join"
#define DIMGroupCommand_Quit       @"quit"
#define DIMGroupCommand_Query      @"query"
#define DIMGroupCommand_Reset      @"reset"
// group: administrator/assistant
#define DIMGroupCommand_Hire       @"hire"
#define DIMGroupCommand_Fire       @"fire"
#define DIMGroupCommand_Resign     @"resign"

#pragma mark - Creation

@interface DIMHistoryCommandFactory : DIMCommandFactory

@end

NS_ASSUME_NONNULL_END
