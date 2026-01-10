// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2018 Albert Moky
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
//  DIMAudioContent.h
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <DIMCore/DIMFileContent.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Audio File content: {
 *
 *      "type" : i2s(0x14),
 *      "sn"   : 123,
 *
 *      "data"     : "...",        // base64_encode(fileContent)
 *      "filename" : "voice.mp3",
 *
 *      "URL"      : "http://...", // download from CDN
 *      // before fileContent uploaded to a public CDN,
 *      // it should be encrypted by a symmetric key
 *      "key"      : {             // symmetric key to decrypt file content
 *          "algorithm" : "AES",   // "DES", ...
 *          "data"      : "{BASE64_ENCODE}",
 *          ...
 *      },
 *
 *      "text"     : "..."       // Automatic Speech Recognition
 *  }
 */
@protocol DKDAudioContent <DKDFileContent>

@property (strong, nonatomic, nullable) NSString *text;

@end

@interface DIMAudioContent : DIMFileContent <DKDAudioContent>

- (instancetype)initWithData:(id<MKTransportableData>)audio
                    filename:(NSString *)name;

- (instancetype)initWithURL:(NSURL *)url
                   password:(nullable id<MKDecryptKey>)key;

@end

#pragma mark - Conveniences

#ifdef __cplusplus
extern "C" {
#endif

DIMAudioContent *DIMAudioContentFromData(id<MKTransportableData> audio,
                                         NSString *filename);

DIMAudioContent *DIMAudioContentFromURL(NSURL *url,
                                        _Nullable id<MKDecryptKey> password);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
