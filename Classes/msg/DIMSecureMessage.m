// license: https://mit-license.org
//
//  Dao-Ke-Dao: Universal Message Module
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
//  DIMSecureMessage.m
//  DIMCore
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <MingKeMing/Format.h>

#import "DIMReliableMessage.h"

#import "DIMSecureMessage.h"

@interface DIMSecureMessage ()

@property (strong, nonatomic) NSData *data;

@property (strong, nonatomic, nullable) id<MKTransportableData> encKey;
@property (strong, nonatomic, nullable) NSDictionary *encryptedKeys;

@end

@implementation DIMSecureMessage

- (instancetype)initWithEnvelope:(id<DKDEnvelope>)env {
    NSAssert(false, @"DON'T call me");
    return [self initWithDictionary:env.dictionary];
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _data = nil;
        _encKey = nil;
        _encryptedKeys = nil;
    }
    
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMSecureMessage *sMsg = [super copyWithZone:zone];
    if (sMsg) {
        sMsg.data = _data;
        sMsg.encKey = _encKey;
        sMsg.encryptedKeys = _encryptedKeys;
    }
    return sMsg;
}

- (NSData *)data {
    if (!_data) {
        id text = [self objectForKey:@"data"];
        if (!text) {
            NSAssert(false, @"content data cannot be empty");
        } else if (![DIMMessage isBroadcast:self]) {
            // message content had been encrypted by a symmetric key,
            // so the data should be encoded here (with algorithm 'base64' as default).
            _data = MKTransportableDataDecode(text);
        } else if ([text isKindOfClass:[NSString class]]) {
            // broadcast message content will not be encrypted (just encoded to JsON),
            // so return the string data directly
            _data = MKUTF8Encode(text);  // JsON
        } else {
            NSAssert(false, @"content data error: %@", text);
        }
    }
    return _data;
}

- (NSData *)encryptedKey {
    id<MKTransportableData> ted = _encKey;
    if (!ted) {
        id base64 = [self objectForKey:@"key"];
        if (!base64) {
            // check 'keys'
            NSDictionary *keys = self.encryptedKeys;
            if (keys) {
                NSString *member = [self.receiver string];
                base64 = [keys objectForKey:member];
            }
        }
        _encKey = ted = MKTransportableDataParse(base64);
    }
    return [ted data];
}

- (NSDictionary *)encryptedKeys {
    if (!_encryptedKeys) {
        id keys = [self objectForKey:@"keys"];
        if ([keys isKindOfClass:[NSDictionary class]]) {
            _encryptedKeys = keys;
        } else {
            NSAssert(keys == nil, @"message keys error: %@", keys);
        }
    }
    return _encryptedKeys;
}

@end
