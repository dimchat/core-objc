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

#import <DaoKeDao/DaoKeDao.h>

NS_ASSUME_NONNULL_BEGIN

/*
 *  Message Transceiver
 *  ~~~~~~~~~~~~~~~~~~~
 *
 *  Converting message format between InstantMessage & ReliableMessage
 */
@interface DIMTransceiver : NSObject <DKDInstantMessageDelegate,
                                      DKDSecureMessageDelegate,
                                      DKDReliableMessageDelegate>

// protected
@property(nonatomic, weak, readonly) id<MKMEntityDelegate> barrack;

@end

/*
 *  Message Packer
 *  ~~~~~~~~~~~~~~
 */
@protocol DIMPacker <NSObject>

//
//  InstantMessage -> SecureMessage -> ReliableMessage -> Data
//

/**
 *  Encrypt message content
 *
 * @param iMsg - plain message
 * @return encrypted message
 */
- (nullable id<DKDSecureMessage>)encryptMessage:(id<DKDInstantMessage>)iMsg;

/**
 *  Sign content data
 *
 * @param sMsg - encrypted message
 * @return network message
 */
- (nullable id<DKDReliableMessage>)signMessage:(id<DKDSecureMessage>)sMsg;

/**
 *  Serialize network message
 *
 * @param rMsg - network message
 * @return data package
 */
- (nullable NSData *)serializeMessage:(id<DKDReliableMessage>)rMsg;

//
//  Data -> ReliableMessage -> SecureMessage -> InstantMessage
//

/**
 *  Deserialize network message
 *
 * @param data - data package
 * @return network message
 */
- (nullable id<DKDReliableMessage>)deserializeMessage:(NSData *)data;

/**
 *  Verify encrypted content data
 *
 * @param rMsg - network message
 * @return encrypted message
 */
- (nullable id<DKDSecureMessage>)verifyMessage:(id<DKDReliableMessage>)rMsg;

/**
 *  Decrypt message content
 *
 * @param sMsg - encrypted message
 * @return plain message
 */
- (nullable id<DKDInstantMessage>)decryptMessage:(id<DKDSecureMessage>)sMsg;

@end

/*
 *  Message Processor
 *  ~~~~~~~~~~~~~~~~~
 */
@protocol DIMProcessor <NSObject>

/**
 *  Process data package
 *
 * @param data - data to be processed
 * @return responses
 */
- (NSArray<NSData *> *)processPackage:(NSData *)data;

/**
 *  Process network message
 *
 * @param rMsg - message to be processed
 * @return response messages
 */
- (NSArray<id<DKDReliableMessage>> *)processReliableMessage:(id<DKDReliableMessage>)rMsg;

/**
 *  Process encrypted message
 *
 * @param sMsg - message to be processed
 * @param rMsg - message received
 * @return response messages
 */
- (NSArray<id<DKDSecureMessage>> *)processSecureMessage:(id<DKDSecureMessage>)sMsg
                             withReliableMessageMessage:(id<DKDReliableMessage>)rMsg;

/**
 *  Process plain message
 *
 * @param iMsg - message to be processed
 * @param rMsg - message received
 * @return response messages
 */
- (NSArray<id<DKDInstantMessage>> *)processInstantMessage:(id<DKDInstantMessage>)iMsg
                               withReliableMessageMessage:(id<DKDReliableMessage>)rMsg;

/**
 *  Process message content
 *
 * @param content - content to be processed
 * @param rMsg - message received
 * @return response contents
 */
- (NSArray<id<DKDContent>> *)processContent:(id<DKDContent>)content
                 withReliableMessageMessage:(id<DKDReliableMessage>)rMsg;

@end

NS_ASSUME_NONNULL_END
