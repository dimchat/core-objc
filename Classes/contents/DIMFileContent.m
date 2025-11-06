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
//  DIMFileContent.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDContentType.h"
#import "DIMBaseFileWrapper.h"

#import "DIMFileContent.h"

@interface DIMFileContent () {
    
    DIMBaseFileWrapper *_wrapper;
}

@end

@implementation DIMFileContent

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        dict = [self dictionary];
        _wrapper = [[DIMBaseFileWrapper alloc] initWithDictionary:dict];
    }
    return self;
}

- (instancetype)initWithType:(NSString *)type {
    return [self initWithType:type
                         data:nil
                     filename:nil
                          url:nil
                     password:nil];
}

/* designated initializer */
- (instancetype)initWithType:(NSString *)type
                        data:(nullable id<MKTransportableData>)file
                    filename:(nullable NSString *)name
                         url:(nullable NSURL *)remote
                    password:(nullable id<MKDecryptKey>)key {
    if (self = [super initWithType:type]) {
        NSDictionary *dict = [self dictionary];
        _wrapper = [[DIMBaseFileWrapper alloc] initWithDictionary:dict];
        if (file) {
            _wrapper.data = file;
        }
        if (name) {
            _wrapper.filename = name;
        }
        if (remote) {
            _wrapper.URL = remote;
        }
        if (key) {
            _wrapper.password = key;
        }
    }
    return self;
}

#pragma mark file data

// Override
- (NSData *)data {
    return [_wrapper.data data];
}

// Override
- (void)setData:(NSData *)data {
    [_wrapper setBinary:data];
}

// Override
- (NSString *)filename {
    return _wrapper.filename;
}

// Override
- (void)setFilename:(NSString *)filename {
    _wrapper.filename = filename;
}

// Override
- (NSURL *)URL {
    return _wrapper.URL;
}

// Override
- (void)setURL:(NSURL *)URL {
    _wrapper.URL = URL;
}

// Override
- (id<MKDecryptKey>)password {
    return _wrapper.password;
}

// Override
- (void)setPassword:(id<MKDecryptKey>)password {
    _wrapper.password = password;
}

@end

#pragma mark - Conveniences

DIMFileContent *DIMFileContentFromData(id<MKTransportableData> data,
                                       NSString *filename) {
    return [[DIMFileContent alloc] initWithType:DKDContentType_File
                                           data:data
                                       filename:filename
                                            url:nil
                                       password:nil];
}

DIMFileContent *DIMFileContentFromURL(NSURL *url,
                                      id<MKDecryptKey> password) {
    return [[DIMFileContent alloc] initWithType:DKDContentType_File
                                           data:nil
                                       filename:nil
                                            url:url
                                       password:password];
}
