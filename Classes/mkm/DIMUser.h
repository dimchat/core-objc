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
//  DIMUser.h
//  DIMCore
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <DIMCore/DIMEntity.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  User Data Source
 *  ~~~~~~~~~~~~~~~~
 *
 *  (Encryption/decryption)
 *  1. public key for encryption
 *     if visa.key not exists, means it is the same key with meta.key
 *  2. private keys for decryption
 *     the private keys paired with [visa.key, meta.key]
 *
 *  (Signature/Verification)
 *  3. private key for signature
 *     the private key paired with visa.key or meta.key
 *  4. public keys for verification
 *     [visa.key, meta.key]
 *
 *  (Visa Document)
 *  5. private key for visa signature
 *     the private key pared with meta.key
 *  6. public key for visa verification
 *     meta.key only
 */
@protocol MKMUserDataSource <MKMEntityDataSource>

/**
 *  Get contacts list
 *
 * @param user - user ID
 * @return contacts list (ID)
 */
- (NSArray<id<MKMID>> *)contactsOfUser:(id<MKMID>)user;

/**
 *  Get user's public key for encryption
 *  (visa.key or meta.key)
 *
 * @param user - user ID
 * @return visa.key or meta.key
 */
- (nullable id<MKMEncryptKey>)publicKeyForEncryption:(id<MKMID>)user;

/**
 *  Get user's public keys for verification
 *  [visa.key, meta.key]
 *
 * @param user - user ID
 * @return public keys
 */
- (NSArray<id<MKMVerifyKey>> *)publicKeysForVerification:(id<MKMID>)user;

/**
 *  Get user's private keys for decryption
 *  (which paired with [visa.key, meta.key])
 *
 * @param user - user ID
 * @return private keys
 */
- (NSArray<id<MKMDecryptKey>> *)privateKeysForDecryption:(id<MKMID>)user;

/**
 *  Get user's private key for signature
 *  (which paired with visa.key or meta.key)
 *
 * @param user - user ID
 * @return private key
 */
- (nullable id<MKMSignKey>)privateKeyForSignature:(id<MKMID>)user;

/**
 *  Get user's private key for signing visa
 *
 * @param user - user ID
 * @return private key
 */
- (nullable id<MKMSignKey>)privateKeyForVisaSignature:(id<MKMID>)user;

@end

@protocol MKMVisa;

/**
 *  User account for communication
 *  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *  This class is for creating user account
 *
 *  functions:
 *      (User)
 *      1. verify(data, signature) - verify (encrypted content) data and signature
 *      2. encrypt(data)           - encrypt (symmetric key) data
 *      (LocalUser)
 *      3. sign(data)    - calculate signature of (encrypted content) data
 *      4. decrypt(data) - decrypt (symmetric key) data
 */
@protocol MKMUser <MKMEntity>

// user document
@property (readonly, strong, nonatomic, nullable) __kindof id<MKMVisa> visa;

/**
 *  Verify data and signature with user's public keys
 *
 * @param data - message data
 * @param signature - message signature
 * @return true on correct
 */
- (BOOL)verify:(NSData *)data withSignature:(NSData *)signature;

/**
 *  Encrypt data, try visa.key first, if not found, use meta.key
 *
 * @param plaintext - message data
 * @return encrypted data
 */
- (NSData *)encrypt:(NSData *)plaintext;

- (BOOL)verifyVisa:(id<MKMVisa>)visa;

//@end
//
//@protocol MKMLocalUser <MKMUser>

@property (readonly, strong, nonatomic) NSArray<id<MKMID>> *contacts;

/**
 *  Sign data with user's private key
 *
 * @param data - message data
 * @return signature
 */
- (NSData *)sign:(NSData *)data;

/**
 *  Decrypt data with user's private key
 *
 * @param ciphertext - encrypted data
 * @return plain text
 */
- (nullable NSData *)decrypt:(NSData *)ciphertext;

- (nullable id<MKMVisa>)signVisa:(id<MKMVisa>)visa;

@end

/**
 *  Base User
 */
@interface DIMUser : DIMEntity <MKMUser>

@end

NS_ASSUME_NONNULL_END
