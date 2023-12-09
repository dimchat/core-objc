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
//  DIMBaseKey.m
//  DIMCore
//
//  Created by Albert Moky on 2023/12/7.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DIMBaseKey.h"

@implementation DIMBaseKey

- (NSString *)algorithm {
    return DIMCryptoGetKeyAlgorithm([self dictionary]);
}

- (NSData *)data {
    NSAssert(false, @"implement me!");
    return nil;
}

@end


NSString *DIMCryptoGetKeyAlgorithm(NSDictionary *key) {
    MKMKeyFactoryManager *man = [MKMKeyFactoryManager sharedManager];
    return [man.generalFactory algorithm:key defaultValue:@""];
}

BOOL DIMCryptoMatchEncryptKey(id<MKMEncryptKey> pKey, id<MKMDecryptKey> sKey) {
    MKMKeyFactoryManager *man = [MKMKeyFactoryManager sharedManager];
    return [man.generalFactory encryptKey:pKey matchDecryptKey:sKey];
}

BOOL DIMCryptoMatchSignKey(id<MKMSignKey> sKey, id<MKMVerifyKey> pKey) {
    MKMKeyFactoryManager *man = [MKMKeyFactoryManager sharedManager];
    return [man.generalFactory signKey:sKey matchVerifyKey:pKey];
}

BOOL DIMSymmetricKeysEqual(id<MKMSymmetricKey> a, id<MKMSymmetricKey> b) {
    if (a == b) {
        // same object
        return YES;
    }
    // compare with encryption
    return DIMCryptoMatchEncryptKey(a, b);
}

BOOL DIMPrivateKeysEqual(id<MKMPrivateKey> a, id<MKMPrivateKey> b) {
    if (a == b) {
        // same object
        return YES;
    }
    return DIMCryptoMatchSignKey(a, b.publicKey);
}
