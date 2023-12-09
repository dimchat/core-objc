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

#import "DIMHelpers.h"

#import "DIMMeta.h"

@interface DIMMeta ()

@property (nonatomic) MKMMetaType type;
@property (strong, nonatomic) id<MKMVerifyKey> publicKey;
@property (strong, nonatomic, nullable) NSString *seed;

@property (strong, nonatomic, nullable) id<MKMTransportableData> ct;

// 1 for valid, -1 for invalid
@property (nonatomic) NSInteger status;

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
        _publicKey = nil;
        _seed = nil;
        _ct = nil;
        _status = 0;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithType:(MKMMetaType)version
                         key:(id<MKMVerifyKey>)publicKey
                        seed:(nullable NSString *)seed
                 fingerprint:(nullable id<MKMTransportableData>)CT {
    NSDictionary *dict;
    if (seed && CT) {
        dict = @{
            @"type": @(version),
            @"key": [publicKey dictionary],
            @"seed": seed,
            @"fingerprint": [CT object],
        };
    } else {
        dict = @{
            @"type": @(version),
            @"key": [publicKey dictionary],
        };
    }
    if (self = [super initWithDictionary:dict]) {
        _type = version;
        _publicKey = publicKey;
        _seed = seed;
        _ct = CT;
        // generated meta, or loaded from local storage,
        // no need to verify again.
        _status = 1;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMMeta *meta = [super copyWithZone:zone];
    if (meta) {
        meta.type = _type;
        meta.publicKey = _publicKey;
        meta.seed = _seed;
        meta.ct = _ct;
        meta.status = _status;
    }
    return meta;
}

- (MKMMetaType)type {
    MKMMetaType version = _type;
    if (version == 0) {
        MKMFactoryManager *man = [MKMFactoryManager sharedManager];
        version = [man.generalFactory metaType:self.dictionary
                                  defaultValue:0];
        _type = version;
    }
    return version;
}

- (id<MKMVerifyKey>)publicKey {
    if (!_publicKey) {
        id dict = [self objectForKey:@"key"];
        NSAssert(dict, @"meta key not found: %@", self);
        _publicKey = MKMPublicKeyParse(dict);
    }
    return _publicKey;
}

- (nullable NSString *)seed {
    if (!_seed && MKMMeta_HasSeed(self.type)) {
        _seed = [self stringForKey:@"seed" defaultValue:nil];
        NSAssert([_seed length] > 0, @"meta.seed should not be empty: %@", self);
    }
    return _seed;
}

- (nullable NSData *)fingerprint {
    id<MKMTransportableData> ted = _ct;
    if (!ted && MKMMeta_HasSeed(self.type)) {
        id text = [self objectForKey:@"fingerprint"];
        NSAssert(text, @"meta.fingerprint should not be empty: %@", self);
        _ct = ted = MKMTransportableDataParse(text);
        NSAssert(ted, @"meta.fingerprint error: %@", text);
    }
    return [ted data];
}

- (id<MKMAddress>)generateAddress:(MKMEntityType)network {
    NSAssert(false, @"implement me!");
    return nil;
}

#pragma mark Validation

- (BOOL)isValid {
    if (_status == 0) {
        // meta from network, try to verify
        if ([DIMMetaHelper checkMeta:self]) {
            // correct
            _status = 1;
        } else {
            // error
            _status = -1;
        }
    }
    return _status > 0;
}

- (BOOL)matchIdentifier:(id<MKMID>)ID {
    return [DIMMetaHelper meta:self matchIdentifier:ID];
}

- (BOOL)matchPublicKey:(id<MKMVerifyKey>)PK {
    return [DIMMetaHelper meta:self matchPublicKeyu:PK];
}

@end
