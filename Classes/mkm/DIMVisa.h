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
//  DIMVisa.h
//  DIMCore
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <MingKeMing/Format.h>
#import <MingKeMing/Crypto.h>

#import <DIMCore/DIMDocument.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  User Document
 *  ~~~~~~~~~~~~~
 *  This interface is defined for authorizing other apps to login,
 *  which can generate a temporary asymmetric key pair for messaging.
 */
@protocol MKMVisa <MKMDocument>

// Public Key for encryption
// ~~~~~~~~~~~~~~~~~~~~~~~~~
// For safety considerations, the visa.key which used to encrypt message data
// should be different with meta.key
@property (strong, nonatomic, nullable) __kindof id<MKEncryptKey> publicKey;

// Avatar URL
@property (strong, nonatomic, nullable) id<MKPortableNetworkFile> avatar;

@end

#pragma mark -

@interface DIMVisa : DIMDocument <MKMVisa>

- (instancetype)initWithIdentifier:(id<MKMID>)did;

@end

NS_ASSUME_NONNULL_END
