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
//  DIMVisa.m
//  DIMCore
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMVisa.h"

@interface DIMVisa () {
    
    // public key to encrypt message
    id<MKEncryptKey> _key;
    
    // avatar URL
    id<MKPortableNetworkFile> _image;
}

@end

@implementation DIMVisa

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _key = nil;
        _image = nil;
    }
    return self;
}

- (instancetype)initWithType:(NSString *)type
                        data:(NSString *)json
                   signature:(id<MKTransportableData>)CT {
    if (self = [super initWithType:type data:json signature:CT]) {
        // lazy
        _key = nil;
        _image = nil;
    }
    return self;
}

- (instancetype)initWithType:(NSString *)type {
    if (self = [super initWithType:type]) {
        // lazy
        _key = nil;
        _image = nil;
    }
    return self;
}

- (instancetype)init {
    return [self initWithType:MKMDocumentType_Visa];
}

- (instancetype)initWithData:(NSString *)json
                   signature:(id<MKTransportableData>)CT {
    return [self initWithType:MKMDocumentType_Visa data:json signature:CT];
}

// Override
- (NSString *)name {
    id nickname = [self propertyForKey:@"name"];
    return MKConvertString(nickname, nil);
}

// Override
- (void)setName:(NSString *)nickname {
    [self setProperty:nickname forKey:@"name"];
}

// Override
- (nullable id<MKEncryptKey>)publicKey {
    id<MKEncryptKey> visaKey = _key;
    if (!visaKey) {
        id dict = [self propertyForKey:@"key"];
        id pubKey = MKPublicKeyParse(dict);
        if ([pubKey conformsToProtocol:@protocol(MKEncryptKey)]) {
            visaKey = pubKey;
            _key = visaKey;
        } else {
            NSAssert(!dict, @"visa key error: %@", dict);
        }
    }
    return visaKey;
}

// Override
- (void)setPublicKey:(id<MKEncryptKey>)key {
    [self setProperty:[key dictionary] forKey:@"key"];
    _key = key;
}

// Override
- (id<MKPortableNetworkFile>)avatar {
    id<MKPortableNetworkFile> img = _image;
    if (!img) {
        id uri = [self propertyForKey:@"avatar"];
        img = MKPortableNetworkFileParse(uri);
        _image = img;
    }
    return img;
}

// Override
- (void)setAvatar:(id<MKPortableNetworkFile>)img {
    if ([img count] == 0) {
        [self setProperty:nil forKey:@"avatar"];
    } else {
        [self setProperty:img.object forKey:@"avatar"];
    }
    _image = img;
}

@end
