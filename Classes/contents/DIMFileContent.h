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
//  DIMFileContent.h
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <DIMCore/DIMContent.h>

NS_ASSUME_NONNULL_BEGIN

/*
 *  File message: {
 *      type : 0x10,
 *      sn   : 123,
 *
 *      URL      : "http://",  // upload to CDN
 *      filename : "...",
 *      data     : "..."       // if (!URL) base64_encode(fileContent)
 *  }
 */
@protocol DKDFileContent <DKDContent>

// URL for download the file data from CDN
@property (strong, nonatomic, nullable) NSURL *URL;

@property (strong, nonatomic, nullable) NSData *data;
@property (strong, nonatomic, readonly) NSString *filename;

// for decrypt file data after download from CDN
@property (strong, nonatomic, nullable) id<MKMSymmetricKey> password;

@end

@interface DIMFileContent : DIMContent <DKDFileContent>

- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithType:(DKDContentType)type
                    filename:(NSString *)name
                        data:(nullable NSData *)file
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithFilename:(NSString *)name data:(nullable NSData *)file;

@end

#ifdef __cplusplus
extern "C" {
#endif

DIMFileContent *DIMFileContentCreate(NSString *filename, NSData *file);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
