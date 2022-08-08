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
//  DIMMetaCommand.h
//  DIMCore
//
//  Created by Albert Moky on 2019/1/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMCore/DIMCommand.h>

NS_ASSUME_NONNULL_BEGIN

/*
 *  Command message: {
 *      type : 0x88,
 *      sn   : 123,
 *
 *      cmd     : "meta", // command name
 *      ID      : "{ID}", // contact's ID
 *      meta    : {...}   // When meta is empty, means query meta for ID
 *  }
 */
@protocol DIMMetaCommand <DIMCommand>

@property (readonly, strong, nonatomic) __kindof id<MKMID> ID;
@property (readonly, strong, nonatomic, nullable) __kindof id<MKMMeta> meta;

@end

@interface DIMMetaCommand : DIMCommand <DIMMetaCommand>

- (instancetype)initWithCommandName:(NSString *)name
                                 ID:(id<MKMID>)ID
                               meta:(nullable id<MKMMeta>)meta;

- (instancetype)initWithID:(id<MKMID>)ID
                      meta:(nullable id<MKMMeta>)meta;
// query command
- (instancetype)initWithID:(id<MKMID>)ID;

@end

NS_ASSUME_NONNULL_END
