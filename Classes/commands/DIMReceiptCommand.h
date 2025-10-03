// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2023 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2023 Albert Moky
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
//  DIMReceiptCommand.h
//  DIMCore
//
//  Created by Albert Moky on 2023/12/7.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <DIMCore/DIMCommand.h>

NS_ASSUME_NONNULL_BEGIN

/*
 *  Command message: {
 *      type : i2s(0x88),
 *      sn   : 456,
 *
 *      command : "receipt",
 *      text    : "...",  // text message
 *      origin  : {       // original message envelope
 *          sender    : "...",
 *          receiver  : "...",
 *          time      : 0,
 *
 *          sn        : 123,
 *          signature : "..."
 *      }
 *  }
 */
@protocol DKDReceiptCommand <DKDCommand>

@property (readonly, strong, nonatomic) NSString *text;

@property (readonly, strong, nonatomic, nullable) id<DKDEnvelope> originalEnvelope;
@property (readonly, nonatomic) DKDSerialNumber originalSerialNumber;
@property (readonly, strong, nonatomic, nullable) NSString *originalSignature;

@end

@interface DIMReceiptCommand : DIMCommand <DKDReceiptCommand>

- (instancetype)initWithText:(NSString *)text origin:(nullable NSDictionary *)env;

@end

#pragma mark - Conveniences

#ifdef __cplusplus
extern "C" {
#endif

/**
 *  Create base receipt command with text & original message info
 */
DIMReceiptCommand *DIMReceiptCommandCreate(NSString *text,
                                           _Nullable id<DKDEnvelope> head,
                                           _Nullable id<DKDContent> body);

NSMutableDictionary<NSString *, id> *DIMReceiptCommandPurify(id<DKDEnvelope> env);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
