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
//  DIMTransceiver.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/7.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <DIMCore/DIMPacker.h>
#import <DIMCore/DIMProcessor.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DIMCipherKeyDelegate <NSObject>

/**
 *  Get cipher key for encrypt message from 'sender' to 'receiver'
 *
 * @param sender - user or contact ID
 * @param receiver - contact or user/group ID
 * @param create - generate when key not exists
 * @return cipher key
 */
- (nullable __kindof id<MKMSymmetricKey>)cipherKeyFrom:(id<MKMID>)sender
                                                    to:(id<MKMID>)receiver
                                              generate:(BOOL)create;

/**
 *  Cache cipher key for reusing, with the direction (from 'sender' to 'receiver')
 *
 * @param key - cipher key
 * @param sender - user or contact ID
 * @param receiver - contact or user/group ID
 */
- (void)cacheCipherKey:(id<MKMSymmetricKey>)key
                  from:(id<MKMID>)sender
                    to:(id<MKMID>)receiver;

@end

@interface DIMTransceiver : NSObject <DKDInstantMessageDelegate,
                                      DKDReliableMessageDelegate>

/**
 *  Delegate for getting entity
 */
@property (weak, nonatomic) id<DIMEntityDelegate> barrack;

/**
 *  Delegate for getting message key
 */
@property (weak, nonatomic) id<DIMCipherKeyDelegate> keyCache;

/**
 *  Delegate for parsing message
 */
@property (weak, nonatomic) id<DIMPacker> packer;

/**
 *  Delegate for processing message
 */
@property (weak, nonatomic) id<DIMProcessor> processor;

@end

#pragma mark -

@interface DIMTransceiver (EntityDelegate)

- (nullable DIMUser *)selectLocalUserWithID:(id<MKMID>)receiver;

- (nullable __kindof DIMUser *)userWithID:(id<MKMID>)ID;

- (nullable __kindof DIMGroup *)groupWithID:(id<MKMID>)ID;

@end

#pragma mark -

@interface DIMTransceiver (CipherKeyDelegate)

- (nullable __kindof id<MKMSymmetricKey>)cipherKeyFrom:(id<MKMID>)sender
                                                    to:(id<MKMID>)receiver
                                              generate:(BOOL)create;

- (void)cacheCipherKey:(id<MKMSymmetricKey>)key
                  from:(id<MKMID>)sender
                    to:(id<MKMID>)receiver;

@end

#pragma mark -

@interface DIMTransceiver (Packer)

- (nullable id<MKMID>)overtGroupForContent:(id<DKDContent>)content;

- (nullable id<DKDSecureMessage>)encryptMessage:(id<DKDInstantMessage>)iMsg;

- (nullable id<DKDReliableMessage>)signMessage:(id<DKDSecureMessage>)sMsg;

- (nullable NSData *)serializeMessage:(id<DKDReliableMessage>)rMsg;

- (nullable id<DKDReliableMessage>)deserializeMessage:(NSData *)data;

- (nullable id<DKDSecureMessage>)verifyMessage:(id<DKDReliableMessage>)rMsg;

- (nullable id<DKDInstantMessage>)decryptMessage:(id<DKDSecureMessage>)sMsg;

@end

#pragma mark -

@interface DIMTransceiver (Processor)

- (NSArray<NSData *> *)processData:(NSData *)data;

- (NSArray<id<DKDReliableMessage>> *)processMessage:(id<DKDReliableMessage>)rMsg;

- (NSArray<id<DKDSecureMessage>> *)processSecure:(id<DKDSecureMessage>)sMsg
                                     withMessage:(id<DKDReliableMessage>)rMsg;

- (NSArray<id<DKDInstantMessage>> *)processInstant:(id<DKDInstantMessage>)iMsg
                                       withMessage:(id<DKDReliableMessage>)rMsg;

- (NSArray<id<DKDContent>> *)processContent:(id<DKDContent>)content
                                withMessage:(id<DKDReliableMessage>)rMsg;

@end

NS_ASSUME_NONNULL_END
