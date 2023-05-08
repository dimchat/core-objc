// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
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
//  DIMMeta.m
//  DIMCore
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMMeta.h"

@interface DIMMeta ()

@property (nonatomic) MKMMetaType type;
@property (strong, nonatomic) id<MKMVerifyKey> key;
@property (strong, nonatomic, nullable) NSString *seed;
@property (strong, nonatomic, nullable) NSData *fingerprint;

@end

@implementation DIMMeta

- (instancetype)init {
    NSAssert(false, @"DON'T call me!");
    NSDictionary *dict = nil;
    return [self initWithDictionary:dict];
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _type = 0;
        _key = nil;
        _seed = nil;
        _fingerprint = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithType:(MKMMetaType)version
                         key:(id<MKMVerifyKey>)publicKey
                        seed:(nullable NSString *)seed
                 fingerprint:(nullable NSData *)fingerprint {
    NSDictionary *dict;
    if (seed && fingerprint) {
        dict = @{
            @"type": @(version),
            @"key": [publicKey dictionary],
            @"seed": seed,
            @"fingerprint": MKMBase64Encode(fingerprint),
        };
    } else {
        dict = @{
            @"type": @(version),
            @"key": [publicKey dictionary],
        };
    }
    if (self = [super initWithDictionary:dict]) {
        _type = version;
        _key = publicKey;
        _seed = seed;
        _fingerprint = fingerprint;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMMeta *meta = [super copyWithZone:zone];
    if (meta) {
        meta.type = _type;
        meta.key = _key;
        meta.seed = _seed;
        meta.fingerprint = _fingerprint;
    }
    return meta;
}

- (MKMMetaType)type {
    MKMMetaType version = _type;
    if (version == 0) {
        MKMFactoryManager *man = [MKMFactoryManager sharedManager];
        version = [man.generalFactory metaType:self.dictionary];
        _type = version;
    }
    return version;
}

- (id<MKMVerifyKey>)key {
    if (!_key) {
        id dict = [self objectForKey:@"key"];
        NSAssert(dict, @"meta key not found: %@", self);
        _key = MKMPublicKeyParse(dict);
    }
    return _key;
}

- (nullable NSString *)seed {
    if (!_seed && MKMMeta_HasSeed(self.type)) {
        _seed = [self stringForKey:@"seed"];
        NSAssert([_seed length] > 0, @"meta.seed should not be empty: %@", self);
    }
    return _seed;
}

- (nullable NSData *)fingerprint {
    if (!_fingerprint && MKMMeta_HasSeed(self.type)) {
        NSString *b64 = [self stringForKey:@"fingerprint"];
        NSAssert(b64, @"meta.fingerprint should not be empty: %@", self);
        _fingerprint = MKMBase64Decode(b64);
        NSAssert([_fingerprint length] > 0, @"meta.fingerprint error: %@", b64);
    }
    return _fingerprint;
}

- (id<MKMAddress>)generateAddress:(MKMEntityType)network {
    NSAssert(false, @"implement me!");
    return nil;
}

@end
