// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
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
//  DIMUser.m
//  DIMCore
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMDocs.h"
#import "DIMHelpers.h"

#import "DIMUser.h"

@implementation DIMUser

- (nullable id<MKMVisa>)visa {
    NSArray<id<MKMDocument>> *docs = [self documents];
    return [DIMDocumentHelper lastVisa:docs];
}

- (BOOL)verifyVisa:(id<MKMVisa>)visa {
    // NOTICE: only verify visa with meta.key
    //         (if meta not exists, user won't be created)
    if (![self.ID isEqual:visa.ID]) {
        // visa ID not match
        NSAssert(false, @"visa ID not match:%@, %@", self.ID, visa.ID);
        return NO;
    }
    // if meta not exists, user won't be created
    id<MKMMeta> meta = [self meta];
    id<MKMVerifyKey> PK = [meta publicKey];
    NSAssert(PK, @"failed to get verify key for visa: %@", self.ID);
    return [visa verify:PK];
}

- (BOOL)verify:(NSData *)data withSignature:(NSData *)signature {
    id<MKMUserDataSource> barrack = [self dataSource];
    NSAssert(barrack, @"user data source not set yet");
    NSArray<id<MKMVerifyKey>> *keys = [barrack publicKeysForVerification:self.ID];
    NSAssert([keys count] > 0, @"failed to get verify keys: %@", self.ID);
    for (id<MKMVerifyKey> PK in keys) {
        if ([PK verify:data withSignature:signature]) {
            // matched!
            return YES;
        }
    }
    // signature not match
    // TODO: check whether visa is expired, query new document for this contact
    return NO;
}

- (NSData *)encrypt:(NSData *)plaintext {
    id<MKMUserDataSource> barrack = [self dataSource];
    NSAssert(barrack, @"user data source not set yet");
    // NOTICE: meta.key will never changed, so use visa.key to encrypt
    //         is the better way
    id<MKMEncryptKey> PK = [barrack publicKeyForEncryption:self.ID];
    NSAssert(PK, @"failed to get encrypt key for user: %@", self.ID);
    return [PK encrypt:plaintext params:nil];
}

#pragma mark Local User

- (NSString *)debugDescription {
    NSString *desc = [super debugDescription];
    NSDictionary *dict = MKMJSONDecode(desc);
    NSMutableDictionary *info;
    if ([dict isKindOfClass:[NSMutableDictionary class]]) {
        info = (NSMutableDictionary *)dict;
    } else {
        info = [dict mutableCopy];
    }
    [info setObject:@(self.contacts.count) forKey:@"contacts"];
    return MKMJSONEncode(info);
}

- (NSArray<id<MKMID>> *)contacts {
    id<MKMUserDataSource> barrack = [self dataSource];
    NSAssert(barrack, @"user data source not set yet");
    return [barrack contactsOfUser:self.ID];
}

- (nullable id<MKMVisa>)signVisa:(id<MKMVisa>)visa {
    if (![self.ID isEqual:visa.ID]) {
        // visa ID not match
        NSAssert(false, @"visa ID not match:%@, %@", self.ID, visa.ID);
        return nil;
    }
    id<MKMUserDataSource> barrack = [self dataSource];
    NSAssert(barrack, @"user data source not set yet");
    // NOTICE: only sign visa with the private key paired with your meta.key
    id<MKMSignKey> SK = [barrack privateKeyForVisaSignature:self.ID];
    NSAssert(SK, @"failed to get visa sign key for user: %@", self.ID);
    NSData *sig = [visa sign:SK];
    if ([sig length] == 0) {
        NSAssert(false, @"failed to sign visa: %@, %@", self.ID, visa);
        return nil;
    }
    return visa;
}

- (NSData *)sign:(NSData *)data {
    id<MKMUserDataSource> barrack = [self dataSource];
    NSAssert(barrack, @"user data source not set yet");
    id<MKMSignKey> SK = [barrack privateKeyForSignature:self.ID];
    NSAssert(SK, @"failed to get sign key for user: %@", self.ID);
    return [SK sign:data];
}

- (nullable NSData *)decrypt:(NSData *)ciphertext {
    id<MKMUserDataSource> barrack = [self dataSource];
    NSAssert(barrack, @"user data source not set yet");
    // NOTICE: if you provide a public key in visa for encryption
    //         here you should return the private key paired with visa.key
    NSArray<id<MKMDecryptKey>> *keys = [barrack privateKeysForDecryption:self.ID];
    NSAssert([keys count] > 0, @"failed to get decrypt keys for user: %@", self.ID);
    NSData *plaintext = nil;
    for (id<MKMDecryptKey> SK in keys) {
        // try decrypting it with each private key
        plaintext = [SK decrypt:ciphertext params:nil];
        if ([plaintext length] > 0) {
            // OK!
            return plaintext;
        }
    }
    // decryption failed
    // TODO: check whether my visa key is changed, push new visa to this contact
    return nil;
}

@end
