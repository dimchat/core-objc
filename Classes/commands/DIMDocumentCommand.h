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

#import <DIMCore/DIMMetaCommand.h>

NS_ASSUME_NONNULL_BEGIN

/*
 *  Command message: {
 *      type : 0x88,
 *      sn   : 123,
 *
 *      command   : "document", // command name
 *      ID        : "{ID}",     // entity ID
 *      meta      : {...},      // only for handshaking with new friend
 *      document  : {...},      // when document is empty, means query for ID
 *      last_time : 12345       // old document time for querying
 *  }
 */
@protocol DKDDocumentCommand <DKDMetaCommand>

@property (readonly, strong, nonatomic, nullable) id<MKMDocument> document;

// Last document time for querying
@property (readonly, strong, nonatomic, nullable) NSDate *lastTime;

@end

@interface DIMDocumentCommand : DIMMetaCommand <DKDDocumentCommand>

- (instancetype)initWithID:(id<MKMID>)ID
                      meta:(nullable id<MKMMeta>)meta
                  document:(nullable id<MKMDocument>)doc;

// query document for updating with last document time
- (instancetype)initWithID:(id<MKMID>)ID
                      time:(nullable NSDate *)lastTime;

@end

#ifdef __cplusplus
extern "C" {
#endif

DIMDocumentCommand *DIMDocumentCommandResponse(id<MKMID> ID,
                                               _Nullable id<MKMMeta> meta,
                                               id<MKMDocument> doc);

DIMDocumentCommand *DIMDocumentCommandQuery(id<MKMID> ID,
                                            NSDate * _Nullable lastTime);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
