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
//  DIMAudioContent.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDContentType.h"

#import "DIMAudioContent.h"

@implementation DIMAudioContent

- (instancetype)initWithData:(id<MKTransportableData>)audio
                    filename:(NSString *)name {
    return [self initWithType:DKDContentType_Audio
                         data:audio
                     filename:name
                          url:nil
                     password:nil];
}

- (instancetype)initWithURL:(NSURL *)url
                   password:(nullable id<MKDecryptKey>)key {
    return [self initWithType:DKDContentType_Audio
                         data:nil
                     filename:nil
                          url:url
                     password:key];
}

// Override
- (nullable NSString *)text {
    return [self stringForKey:@"text" defaultValue:nil];
}

// Override
- (void)setText:(nullable NSString *)text {
    if (text) {
        [self setObject:text forKey:@"text"];
    } else {
        [self removeObjectForKey:@"text"];
    }
}

@end

#pragma mark - Conveniences

DIMAudioContent *DIMAudioContentFromData(id<MKTransportableData> audio,
                                         NSString *filename) {
    return [[DIMAudioContent alloc] initWithData:audio filename:filename];
}

DIMAudioContent *DIMAudioContentFromURL(NSURL *url,
                                        _Nullable id<MKDecryptKey> password) {
    return [[DIMAudioContent alloc] initWithURL:url password:password];
}
