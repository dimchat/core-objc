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
//  DIMBaseFileWrapper.m
//  DIMCore
//
//  Created by Albert Moky on 2023/12/7.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DIMBaseFileWrapper.h"

@interface DIMBaseFileWrapper () {
    
    // file data (not encrypted)
    id<MKMTransportableData> _attachment;
    
    // download from CDN
    NSURL *_remoteURL;
    
    // key to decrypt data downloaded from CDN
    id<MKMDecryptKey> _password;
}

@end

@implementation DIMBaseFileWrapper

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy load
        _attachment = nil;
        _remoteURL = nil;
        _password = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)init {
    if (self = [super init]) {
        _attachment = nil;
        _remoteURL = nil;
        _password = nil;
    }
    return self;
}

#pragma mark file data

- (id<MKMTransportableData>)data {
    id<MKMTransportableData> ted = _attachment;
    if (!ted) {
        id base64 = [self objectForKey:@"data"];
        _attachment = ted = MKMTransportableDataParse(base64);
    }
    return ted;
}

- (void)setData:(id<MKMTransportableData>)ted {
    if (!ted) {
        [self removeObjectForKey:@"data"];
    } else {
        [self setObject:ted.object forKey:@"data"];
    }
    _attachment = ted;
}

- (void)setBinary:(NSData *)data {
    id<MKMTransportableData> ted;
    if ([data length] == 0) {
        ted = nil;
        [self removeObjectForKey:@"data"];
    } else {
        ted = MKMTransportableDataCreate(data, nil);
        [self setObject:ted.object forKey:@"data"];
    }
    _attachment = ted;
}

#pragma mark file name

- (NSString *)filename {
    return [self stringForKey:@"filename" defaultValue:nil];
}

- (void)setFilename:(NSString *)filename {
    if ([filename length] == 0) {
        [self removeObjectForKey:@"filename"];
    } else {
        [self setObject:filename forKey:@"filename"];
    }
}

#pragma mark download URL

- (NSURL *)URL {
    NSURL *remote = _remoteURL;
    if (!remote) {
        NSString *locator = [self stringForKey:@"URL" defaultValue:nil];
        if ([locator length] > 0) {
            _remoteURL = remote = [[NSURL alloc] initWithString:locator];
        }
    }
    return remote;
}

- (void)setURL:(NSURL *)url {
    if (!url) {
        [self removeObjectForKey:@"URL"];
    } else {
        [self setObject:url.absoluteString forKey:@"URL"];
    }
    _remoteURL = url;
}

#pragma mark decrypt key

- (id<MKMDecryptKey>)password {
    id<MKMDecryptKey> key = _password;
    if (!key) {
        id info = [self objectForKey:@"password"];
        _password = key = MKMSymmetricKeyParse(info);
    }
    return key;
}

- (void)setPassword:(id<MKMDecryptKey>)key {
    [self setDictionary:key forKey:@"password"];
    _password = key;
}

@end
