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
//  MKMDocs.m
//  DIMCore
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMDocs.h"

@interface DIMVisa () {
    
    // public key to encrypt message
    id<MKMEncryptKey> _key;
    
    // avatar URL
    id<MKMPortableNetworkFile> _pnf;
}

@end

@implementation DIMVisa

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _key = nil;
        _pnf = nil;
    }
    return self;
}

- (instancetype)initWithID:(id<MKMID>)ID
                      data:(NSString *)json
                 signature:(id<MKMTransportableData>)CT {
    if (self = [super initWithID:ID data:json signature:CT]) {
        // lazy
        _key = nil;
        _pnf = nil;
    }
    return self;
}

- (instancetype)initWithID:(id<MKMID>)ID type:(NSString *)type {
    if (self = [super initWithID:ID type:type]) {
        // lazy
        _key = nil;
    }
    return self;
}

- (instancetype)initWithID:(id<MKMID>)ID {
    return [self initWithID:ID type:MKMDocumentTypeVisa];
}

- (nullable id<MKMEncryptKey>)publicKey {
    if (!_key) {
        id dict = [self propertyForKey:@"key"];
        id pubKey = MKMPublicKeyParse(dict);
        if ([pubKey conformsToProtocol:@protocol(MKMEncryptKey)]) {
            _key = pubKey;
        } else {
            NSAssert(!dict, @"visa key error: %@", dict);
        }
    }
    return _key;
}

- (void)setPublicKey:(id<MKMEncryptKey>)key {
    [self setProperty:[key dictionary] forKey:@"key"];
    _key = key;
}

- (id<MKMPortableNetworkFile>)avatar {
    if (!_pnf) {
        id url = [self propertyForKey:@"avatar"];
        if ([url length] == 0) {
            // ignore empty URL
        } else {
            _pnf = MKMPortableNetworkFileParse(url);
        }
    }
    return _pnf;
}

- (void)setAvatar:(id<MKMPortableNetworkFile>)avatar {
    [self setProperty:avatar.object forKey:@"avatar"];
    _pnf = avatar;
}

@end

#pragma mark -

@interface DIMBulletin () {
    
    // Bot ID list as group assistants
    NSArray<id<MKMID>> *_bots;
}

@end

@implementation DIMBulletin

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _bots = nil;
    }
    return self;
}

- (instancetype)initWithID:(id<MKMID>)ID
                      data:(NSString *)json
                 signature:(id<MKMTransportableData>)CT {
    if (self = [super initWithID:ID data:json signature:CT]) {
        // lazy
        _bots = nil;
    }
    return self;
}

- (instancetype)initWithID:(id<MKMID>)ID type:(NSString *)type {
    if (self = [super initWithID:ID type:type]) {
        // lazy
        _bots = nil;
    }
    return self;
}

- (instancetype)initWithID:(id<MKMID>)ID {
    return [self initWithID:ID type:MKMDocumentTypeBulletin];
}

- (nullable id<MKMID>)founder {
    return MKMIDParse([self objectForKey:@"founder"]);
}

- (nullable NSArray<id<MKMID>> *)assistants {
    if (!_bots) {
        NSArray *array = [self propertyForKey:@"assistants"];
        if (array.count > 0) {
            _bots = MKMIDConvert(array);
        }
    }
    return _bots;
}

- (void)setAssistants:(NSArray<id<MKMID>> *)assistants {
    NSAssert([assistants count] > 0, @"bots empty");
    [self setProperty:MKMIDRevert(assistants) forKey:@"assistants"];
    _bots = assistants;
}

@end
