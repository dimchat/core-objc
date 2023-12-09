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
//  DIMBaseDataWrapper.h
//  DIMCore
//
//  Created by Albert Moky on 2023/12/7.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <MingKeMing/MingKeMing.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Transportable Data MixIn: {
 *
 *      algorithm : "base64",
 *      data      : "...",     // base64_encode(data)
 *      ...
 *  }
 *
 *  data format:
 *      0. "{BASE64_ENCODE}"
 *      1. "base64,{BASE64_ENCODE}"
 *      2. "data:image/png;base64,{BASE64_ENCODE}"
 */
@interface DIMBaseDataWrapper : MKMDictionary

//- (BOOL)isEmpty;

/**
 *  toString()
 */
- (NSString *)encode;

/**
 *  Encode with 'Content-Type'
 *
 *  toString()
 */
- (NSString *)encode:(NSString *)mimeType;

/**
 *  encode algorithm
 */
@property (strong, nonatomic) NSString *algorithm;

/**
 *  binary data
 */
@property (strong, atomic, nullable) NSData *data;

@end

NS_ASSUME_NONNULL_END
