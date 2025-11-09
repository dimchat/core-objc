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
//  DIMDocumentCommand.h
//  DIMCore
//
//  Created by Albert Moky on 2019/2/3.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <MingKeMing/MingKeMing.h>

#import <DIMCore/DIMMetaCommand.h>

NS_ASSUME_NONNULL_BEGIN

/*
 *  Command message: {
 *      type : i2s(0x88),
 *      sn   : 123,
 *
 *      command   : "documents", // command name
 *      did       : "{ID}",      // entity ID
 *      meta      : {...},       // only for handshaking with new friend
 *      documents : [...],       // when this is null, means to query
 *      last_time : 12345        // old document time for querying
 *  }
 */
@protocol DKDDocumentCommand <DKDMetaCommand>

@property (readonly, strong, nonatomic, nullable) NSArray<id<MKMDocument>> *documents;

// Last document time for querying
@property (readonly, strong, nonatomic, nullable) NSDate *lastTime;

@end

@interface DIMDocumentCommand : DIMMetaCommand <DKDDocumentCommand>

- (instancetype)initWithIdentifier:(id<MKMID>)did
                              meta:(nullable id<MKMMeta>)meta
                         documents:(NSArray<id<MKMDocument>> *)docs;

// query document for updating with last document time
- (instancetype)initWithIdentifier:(id<MKMID>)did
                          lastTime:(nullable NSDate *)time;

@end

#pragma mark - Conveniences

#ifdef __cplusplus
extern "C" {
#endif

DIMDocumentCommand *DIMDocumentCommandResponse(id<MKMID> did,
                                               _Nullable id<MKMMeta> meta,
                                               NSArray<id<MKMDocument>> *docs);

DIMDocumentCommand *DIMDocumentCommandQuery(id<MKMID> did,
                                            NSDate * _Nullable lastTime);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
