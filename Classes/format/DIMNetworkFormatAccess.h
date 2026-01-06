// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2026 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2026 Albert Moky
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
//  DIMNetworkFormatAccess.h
//  DIMCore
//
//  Created by Albert Moky on 2026/1/5.
//  Copyright © 2026 DIM Group. All rights reserved.
//

#import <MingKeMing/Format.h>
#import <MingKeMing/Crypto.h>

NS_ASSUME_NONNULL_BEGIN

#define DIMNetworkFormatDataType NSMutableDictionary<NSString *, id>

/**
 *  TransportableDataWrapper
 */
@protocol DIMTEDWrapper <NSObject>

- (BOOL)isEmpty;

/**
 *  0. "{BASE64_ENCODE}"
 *  1. "base64,{BASE64_ENCODE}"
 *
 *  toString()
 */
- (NSString *)encode;

/**
 *  Encode with 'Content-Type'
 *
 *  toString(mimeType)
 */
- (NSString *)encode:(NSString *)mimeType;

/**
 *  Encode Algorithm
 */
@property (strong, nonatomic) NSString *algorithm;

/**
 *  Binary Data
 */
@property (strong, nonatomic, nullable) NSData *data;

@end

/**
 *  PortableNetworkFileWrapper
 */
@protocol DIMPNFWrapper <NSObject>

/**
 *  Serialize data
 *
 *  toMap()
 */
@property (readonly, strong, nonatomic) DIMNetworkFormatDataType *dictionary;

// file data
@property (strong, nonatomic, nullable) id<MKTransportableData> data;

// set binary data
- (void)setBinary:(NSData *)data;

// file name
@property (strong, nonatomic, nullable) NSString *filename;

// download URL
@property (strong, nonatomic, nullable) NSURL *URL;

// decrypt key
@property (strong, nonatomic, nullable) id<MKDecryptKey> password;

@end

@interface DIMBaseNetworkFormatWrapper : NSObject

/**
 *  toMap()
 */
@property (readonly, strong, nonatomic) DIMNetworkFormatDataType *dictionary;

- (instancetype)initWithDictionary:(DIMNetworkFormatDataType *)dict
NS_DESIGNATED_INITIALIZER;

- (nullable id)objectForKey:(NSString *)key;
- (void)setObject:(id)value forKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;

- (nullable NSString *)stringForKey:(NSString *)key;

// setMap(key, value)
- (void)setDictionary:(id<MKDictionary>)mapper forKey:(NSString *)key;

@end

#pragma mark - Wrapper Factory

@protocol DIMTEDWrapperFactory <NSObject>

- (id<DIMTEDWrapper>)createTEDWrapper:(NSMutableDictionary<NSString *, id> *)map;

@end

@protocol DIMPNFWrapperFactory <NSObject>

- (id<DIMPNFWrapper>)createPNFWrapper:(NSMutableDictionary<NSString *, id> *)map;

@end

@interface DIMSharedNetworkFormatAccess : NSObject

+ (instancetype)sharedInstance;

@property (strong, nonatomic) id<DIMTEDWrapperFactory> tedWrapperFactory;

@property (strong, nonatomic) id<DIMPNFWrapperFactory> pnfWrapperFactory;

@end

NS_ASSUME_NONNULL_END
