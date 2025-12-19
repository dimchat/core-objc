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
//  DIMMeta.h
//  DIMCore
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <MingKeMing/Format.h>
#import <MingKeMing/Crypto.h>
#import <MingKeMing/MingKeMing.h>

NS_ASSUME_NONNULL_BEGIN

/*
 *  enum MKMMetaVersion
 *
 *  abstract Defined for algorithm that generating address.
 *
 *  discussion Generate and check ID/Address
 *
 *      MKMMetaVersion_MKM give a seed string first, and sign this seed to get
 *      fingerprint; after that, use the fingerprint to generate address.
 *      This will get a firmly relationship between (username, address and key).
 *
 *      MKMMetaVersion_BTC use the key data to generate address directly.
 *      This can build a BTC address for the entity ID (no username).
 *
 *      MKMMetaVersion_ExBTC use the key data to generate address directly, and
 *      sign the seed to get fingerprint (just for binding username and key).
 *      This can build a BTC address, and bind a username to the entity ID.
 *
 *  Bits:
 *      0000 0001 - this meta contains seed as ID.name
 *      0000 0010 - this meta generate BTC address
 *      0000 0100 - this meta generate ETH address
 *      ...
 */
FOUNDATION_EXPORT NSString * const MKMMetaType_Default; // "1"
FOUNDATION_EXPORT NSString * const MKMMetaType_MKM;     // "1": username@address

/// Bitcoin
FOUNDATION_EXPORT NSString * const MKMMetaType_BTC;   // "2": btc_address
FOUNDATION_EXPORT NSString * const MKMMetaType_ExBTC; // "3": username@btc_address (RESERVED)

/// Ethereum
FOUNDATION_EXPORT NSString * const MKMMetaType_ETH;   // "4": eth_address
FOUNDATION_EXPORT NSString * const MKMMetaType_ExETH; // "5": username@eth_address (RESERVED)

/**
 *  User/Group Meta data
 *  ~~~~~~~~~~~~~~~~~~~~
 *  This class is used to generate entity ID
 *
 *      data format: {
 *          "type"        : i2s(1),            // algorithm version
 *          "key"         : {...},             // PK = secp256k1(SK);
 *          "seed"        : "moKy",            // user/group name
 *          "fingerprint" : "{BASE64_ENCODE}"  // CT = sign(seed, SK);
 *      }
 *
 *      algorithm:
 *          fingerprint = sign(seed, SK);
 *
 *  abstract method:
 *      - Address generateAddress(int network);
 */
@interface DIMMeta : MKDictionary <MKMMeta>

// protected
@property (nonatomic, readonly) BOOL hasSeed;

/**
 *  Create meta with dictionary
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithType:(NSString *)type
                         key:(id<MKVerifyKey>)PK
                        seed:(nullable NSString *)name
                 fingerprint:(nullable id<MKTransportableData>)CT
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
