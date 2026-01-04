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
    id<MKTransportableData> _attachment;
    
    // download from CDN
    NSURL *_remoteURL;
    
    // key to decrypt data downloaded from CDN
    id<MKDecryptKey> _password;
}

@end

@implementation DIMBaseFileWrapper

/* designated initializer */
- (instancetype)initWithDictionary:(DIMNetworkFormatDataType *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy load
        _attachment = nil;
        _remoteURL = nil;
        _password = nil;
    }
    return self;
}

#pragma mark file data

// Override
- (id<MKTransportableData>)data {
    id<MKTransportableData> ted = _attachment;
    if (!ted) {
        id base64 = [self objectForKey:@"data"];
        _attachment = ted = MKTransportableDataParse(base64);
    }
    return ted;
}

// Override
- (void)setData:(id<MKTransportableData>)ted {
    if (!ted) {
        [self removeObjectForKey:@"data"];
    } else {
        [self setObject:ted.object forKey:@"data"];
    }
    _attachment = ted;
}

// Override
- (void)setBinary:(NSData *)data {
    id<MKTransportableData> ted;
    if ([data length] == 0) {
        ted = nil;
        [self removeObjectForKey:@"data"];
    } else {
        ted = MKTransportableDataCreate(data, nil);
        [self setObject:ted.object forKey:@"data"];
    }
    _attachment = ted;
}

#pragma mark file name

// Override
- (NSString *)filename {
    return [self stringForKey:@"filename"];
}

// Override
- (void)setFilename:(NSString *)filename {
    if ([filename length] == 0) {
        [self removeObjectForKey:@"filename"];
    } else {
        [self setObject:filename forKey:@"filename"];
    }
}

#pragma mark download URL

// Override
- (NSURL *)URL {
    NSURL *remote = _remoteURL;
    if (!remote) {
        NSString *locator = [self stringForKey:@"URL"];
        if ([locator length] > 0) {
            _remoteURL = remote = [[NSURL alloc] initWithString:locator];
        }
    }
    return remote;
}

// Override
- (void)setURL:(NSURL *)remote {
    if (!remote) {
        [self removeObjectForKey:@"URL"];
    } else {
        [self setObject:remote.absoluteString forKey:@"URL"];
    }
    _remoteURL = remote;
}

#pragma mark decrypt key

// Override
- (id<MKDecryptKey>)password {
    id<MKDecryptKey> key = _password;
    if (!key) {
        id dict = [self objectForKey:@"key"];
        if ([dict isKindOfClass:[NSMutableDictionary class]]) {
            key = MKSymmetricKeyParse(dict);
        } else if ([dict isKindOfClass:[NSDictionary class]]) {
            key = MKSymmetricKeyParse(dict);
            [self setObject:key.dictionary forKey:@"key"];
        } else {
            NSAssert(dict == nil, @"decrypt key error: %@, %@", dict, self);
        }
        _password = key;
    }
    return key;
}

// Override
- (void)setPassword:(id<MKDecryptKey>)key {
    [self setDictionary:key forKey:@"key"];
    _password = key;
}

@end
