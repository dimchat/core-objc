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
//  DIMBaseFileWrapper.h
//  DIMCore
//
//  Created by Albert Moky on 2023/12/7.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <MingKeMing/Format.h>
#import <MingKeMing/Crypto.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  File Content MixIn: {
 *
 *      data     : "...",        // base64_encode(fileContent)
 *      filename : "photo.png",
 *
 *      URL      : "http://...", // download from CDN
 *      // before fileContent uploaded to a public CDN,
 *      // it should be encrypted by a symmetric key
 *      key      : {             // symmetric key to decrypt file content
 *          algorithm : "AES",   // "DES", ...
 *          data      : "{BASE64_ENCODE}",
 *          ...
 *      }
 *  }
 */
@interface DIMBaseFileWrapper : MKDictionary

// file data
@property (strong, nonatomic, nullable) id<MKTransportableData> data;

// set binary data
- (void)setBinary:(NSData *)data;

// file name
@property (strong, nonatomic, nullable) NSString *filename;

// download URL
@property (strong, nonatomic, nullable) NSURL *URL;

// decrypt key
@property (strong, nonatomic, nullable) id<MKDecryptKey> password;

@end

NS_ASSUME_NONNULL_END
