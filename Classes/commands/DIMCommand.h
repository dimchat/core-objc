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
//  DIMCommand.h
//  DIMCore
//
//  Created by Albert Moky on 2019/1/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DaoKeDao/DaoKeDao.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMCommand : DKDContent

@property (readonly, strong, nonatomic) NSString *command;

/*
 *  Command message: {
 *      type : 0x88,
 *      sn   : 123,
 *
 *      command : "...", // command name
 *      extra   : info   // command parameters
 *  }
 */
- (instancetype)initWithCommand:(NSString *)cmd;

@end

#pragma mark System Command

// message
#define DIMCommand_Receipt   @"receipt"
// network
#define DIMCommand_Handshake @"handshake"
#define DIMCommand_Login     @"login"

// facebook
#define DIMCommand_Meta      @"meta"
#define DIMCommand_Profile   @"profile"

#pragma mark - Creation

#define DKDContentParserRegisterCall(type, clazz)                              \
            DKDContentParserRegisterBlock((type),                              \
                ^id<DKDContent>(NSDictionary *dict) {                          \
                    return [clazz parse:dict];                                 \
                })                                                             \
                          /* EOF 'DKDContentParserRegisterCall(type, parser)' */

#define DIMCommandParserRegisterBlock(name, block)                             \
            [DIMCommand registerParser:(block) forCommand:(name)]              \
                         /* EOF 'DKDCommandParserRegisterBlock(type, parser)' */

#define DIMCommandParserRegister(name, clazz)                                  \
            DIMCommandParserRegisterBlock((name),                              \
                ^id<DKDContent>(NSDictionary *dict) {                          \
                    return [[clazz alloc] initWithDictionary:dict];            \
                })                                                             \
                              /* EOF 'DKDCommandParserRegister(type, parser)' */

@interface DIMCommand (Creation)

+ (void)registerParser:(DKDContentParser)parser forCommand:(NSString *)name;

+ (nullable __kindof DIMCommand *)parse:(NSDictionary *)cmd;

@end

NS_ASSUME_NONNULL_END
