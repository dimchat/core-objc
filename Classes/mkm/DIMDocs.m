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
}

@end

@implementation DIMVisa

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _key = nil;
    }
    return self;
}

- (instancetype)initWithID:(id<MKMID>)ID data:(NSString *)json signature:(NSString *)sig {
    if (self = [super initWithID:ID data:json signature:sig]) {
        // lazy
        _key = nil;
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
    return [self initWithID:ID type:MKMDocument_Visa];
}

- (nullable id<MKMEncryptKey>)key {
    if (!_key) {
        id dict = [self propertyForKey:@"key"];
        id pubKey = MKMPublicKeyParse(dict);
        if ([pubKey conformsToProtocol:@protocol(MKMEncryptKey)]) {
            _key = pubKey;
        }
    }
    return _key;
}

- (void)setKey:(id<MKMEncryptKey>)key {
    [self setProperty:[key dictionary] forKey:@"key"];
    _key = key;
}

- (nullable NSString *)avatar {
    return [self propertyForKey:@"avatar"];
}

- (void)setAvatar:(NSString *)avatar {
    [self setProperty:avatar forKey:@"avatar"];
}

@end

#pragma mark -

@interface DIMBulletin () {
    
    // Bot ID list as group assistants
    NSArray<id<MKMID>> *_assistants;
}

@end

@implementation DIMBulletin

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _assistants = nil;
    }
    return self;
}

- (instancetype)initWithID:(id<MKMID>)ID data:(NSString *)json signature:(NSString *)sig {
    if (self = [super initWithID:ID data:json signature:sig]) {
        // lazy
        _assistants = nil;
    }
    return self;
}

- (instancetype)initWithID:(id<MKMID>)ID type:(NSString *)type {
    if (self = [super initWithID:ID type:type]) {
        // lazy
        _assistants = nil;
    }
    return self;
}

- (instancetype)initWithID:(id<MKMID>)ID {
    return [self initWithID:ID type:MKMDocument_Bulletin];
}

- (nullable NSArray<id<MKMID>> *)assistants {
    if (!_assistants) {
        NSArray *array = [self propertyForKey:@"assistants"];
        if (array.count > 0) {
            _assistants = MKMIDConvert(array);
        }
    }
    return _assistants;
}

- (void)setAssistants:(NSArray<id<MKMID>> *)assistants {
    [self setProperty:assistants forKey:@"assistants"];
    _assistants = assistants;
}

@end
