// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
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
//  DIMKeyCache.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DIMCipherKeyDelegate <NSObject>

/**
 *  Get cipher key for encrypt message from 'sender' to 'receiver'
 *
 * @param sender - user or contact ID
 * @param receiver - contact or user/group ID
 * @return cipher key
 */
- (nullable DIMSymmetricKey *)cipherKeyFrom:(DIMID *)sender
                                         to:(DIMID *)receiver;

/**
 *  Cache cipher key for reusing, with the direction (from 'sender' to 'receiver')
 *
 * @param key - cipher key
 * @param sender - user or contact ID
 * @param receiver - contact or user/group ID
 */
- (void)cacheCipherKey:(DIMSymmetricKey *)key
                  from:(DIMID *)sender
                    to:(DIMID *)receiver;

@end

/**
 *  Cache for Cipher Key with direction: <from, to>
 */
@interface DIMKeyCache : NSObject <DIMCipherKeyDelegate>

/**
 *  Trigger for saving cipher key map
 */
- (void)flush;

/**
 *  Callback for saving cipher key map into local storage
 *  (Override it to access database)
 *
 * @param keyMap - all cipher keys(with direction) from memory cache
 * @return YES on success
 */
- (BOOL)saveKeys:(NSDictionary *)keyMap;

/**
 *  Load cipher key map from local storage
 *  (Override it to access database)
 *
 * @return keys map
 */
- (nullable NSDictionary *)loadKeys;

/**
 *  Update cipher key map into memory cache
 *
 * @param keyMap - cipher keys(with direction) from local storage
 * @return NO on nothing changed
 */
- (BOOL)updateKeys:(NSDictionary *)keyMap;

/**
 *  Trigger for load and update cipher key map
 */
- (BOOL)reload;

@end

NS_ASSUME_NONNULL_END
