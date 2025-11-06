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

#import <MingKeMing/Ext.h>

#import "DIMMeta.h"

NSString * const MKMMetaType_Default = @"1";
NSString * const MKMMetaType_MKM     = @"1";

NSString * const MKMMetaType_BTC     = @"2";
NSString * const MKMMetaType_ExBTC   = @"3";

NSString * const MKMMetaType_ETH     = @"4";
NSString * const MKMMetaType_ExETH   = @"5";

@interface DIMMeta ()

/**
 *  Meta algorithm version
 *
 *      1 = MKM : username@address (default)
 *      2 = BTC : btc_address
 *      4 = ETH : eth_address
 *      ...
 */
@property (strong, nonatomic) NSString *type;

/**
 *  Public key (used for signature)
 *
 *      RSA / ECC
 */
@property (strong, nonatomic) id<MKVerifyKey> publicKey;

/**
 *  Seed to generate fingerprint
 *
 *      Username / Group-X
 */
@property (strong, nonatomic, nullable) NSString *seed;

/**
 *  Fingerprint to verify ID and public key
 *
 *      Build: fingerprint = sign(seed, privateKey)
 *      Check: verify(seed, fingerprint, publicKey)
 */
@property (strong, nonatomic, nullable) id<MKTransportableData> ct;

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
- (instancetype)initWithType:(NSString *)type
                         key:(id<MKVerifyKey>)publicKey
                        seed:(nullable NSString *)seed
                 fingerprint:(nullable id<MKTransportableData>)CT {
    NSDictionary *dict;
    if (seed && CT) {
        dict = @{
            @"type": type,
            @"key": [publicKey dictionary],
            @"seed": seed,
            @"fingerprint": [CT object],
        };
    } else {
        dict = @{
            @"type": type,
            @"key": [publicKey dictionary],
        };
    }
    if (self = [super initWithDictionary:dict]) {
        _type = type;
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

// Override
- (NSString *)type {
    NSString *version = _type;
    if ([version length] == 0) {
        MKMSharedAccountExtensions *ext = [MKMSharedAccountExtensions sharedInstance];
        version = [ext.helper getMetaType:self.dictionary defaultValue:nil];
        _type = version;
    }
    return version;
}

// Override
- (id<MKVerifyKey>)publicKey {
    id<MKVerifyKey> key = _publicKey;
    if (!key) {
        id dict = [self objectForKey:@"key"];
        if ([dict isKindOfClass:[NSMutableDictionary class]]) {
            key = MKPublicKeyParse(dict);
        } else if ([dict isKindOfClass:[NSDictionary class]]) {
            key = MKPublicKeyParse(dict);
            [self setObject:key.dictionary forKey:@"key"];
        } else {
            NSAssert(false, @"meta key error: %@, %@", dict, self);
        }
        _publicKey = key;
    }
    return key;
}

- (BOOL)hasSeed {
    //NSString *algorithm = [self type];
    //return [algorithm isEqualToString:@"1"] || [algorithm isEqualToString:@"MKM"];
    return NO;
}

// Override
- (nullable NSString *)seed {
    NSString *name = _seed;
    if (!name && [self hasSeed]) {
        name = [self stringForKey:@"seed" defaultValue:nil];
        NSAssert([name length] > 0, @"meta.seed should not be empty: %@", [self dictionary]);
        _seed = name;
    }
    return name;
}

// Override
- (nullable NSData *)fingerprint {
    id<MKTransportableData> ted = _ct;
    if (ted == nil && [self hasSeed]) {
        id base64 = [self objectForKey:@"fingerprint"];
        NSAssert(base64, @"meta.fingerprint should not be empty: %@", [self dictionary]);
        _ct = ted = MKTransportableDataParse(base64);
        NSAssert(ted, @"meta.fingerprint error: %@", base64);
    }
    return [ted data];
}

// Override
- (id<MKMAddress>)generateAddress:(MKMEntityType)network {
    NSAssert(false, @"implement me!");
    return nil;
}

#pragma mark Validation

// Override
- (BOOL)isValid {
    if (_status == 0) {
        // meta from network, try to verify
        if ([self checkValid]) {
            // correct
            _status = 1;
        } else {
            // error
            _status = -1;
        }
    }
    return _status > 0;
}

// private
- (BOOL)checkValid {
    id<MKVerifyKey> key = [self publicKey];
     NSAssert(key, @"meta.key should not be empty: %@", [self dictionary]);
    if ([self hasSeed]) {
        // check 'seed' & 'fingerprint'
    } else if ([self objectForKey:@"seed"] || [self objectForKey:@"fingerprint"]) {
        // this meta has no seed, so
        // it should not contains 'seed' or 'fingerprint'
        return NO;
    } else {
        // this meta has no seed, so it's always valid
        // when the public key exists
        return true;
    }
    NSString *name = [self seed];
    NSData *signature = [self fingerprint];
    // check meta seed & signature
    if ([signature length] == 0 || [name length] == 0) {
        // seed and fingerprint should not be empty
        NSAssert(false, @"meta error: %@", [self dictionary]);
        return NO;
    }
    // verify fingerprint
    NSData *data = MKUTF8Encode(name);
    return [key verify:data withSignature:signature];
}

@end
