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
@interface DIMTransceiver : NSObject <DKDInstantMessageDelegate, DKDReliableMessageDelegate>

/**
 *  Delegate for getting entity
 */
@property (weak, nonatomic) __kindof id<DIMEntityDelegate> barrack;

@end

/*
 *  Message Packer
 *  ~~~~~~~~~~~~~~
 */
@protocol DIMPacker <NSObject>

/**
 *  Get group ID which should be exposed to public network
 *
 * @param content - message content
 * @return exposed group ID
 */
- (nullable __kindof id<MKMID>)overtGroupForContent:(id<DKDContent>)content;

//
//  InstantMessage -> SecureMessage -> ReliableMessage -> Data
//
- (nullable __kindof id<DKDSecureMessage>)encryptMessage:(id<DKDInstantMessage>)iMsg;

- (nullable __kindof id<DKDReliableMessage>)signMessage:(id<DKDSecureMessage>)sMsg;

- (nullable NSData *)serializeMessage:(id<DKDReliableMessage>)rMsg;

//
//  Data -> ReliableMessage -> SecureMessage -> InstantMessage
//
- (nullable __kindof id<DKDReliableMessage>)deserializeMessage:(NSData *)data;

- (nullable __kindof id<DKDSecureMessage>)verifyMessage:(id<DKDReliableMessage>)rMsg;

- (nullable __kindof id<DKDInstantMessage>)decryptMessage:(id<DKDSecureMessage>)sMsg;

@end

/*
 *  Message Processor
 *  ~~~~~~~~~~~~~~~~~
 */
@protocol DIMProcessor <NSObject>

/**
 *  Process received data package
 *
 * @param data - package from network connection
 * @return responses
 */
- (NSArray<NSData *> *)processData:(NSData *)data;

// NOTICE: override to check broadcast message before calling it
// NOTICE: override to deliver to the receiver when catch exception "ReceiverError"
- (NSArray<__kindof id<DKDReliableMessage>> *)processMessage:(id<DKDReliableMessage>)rMsg;

- (NSArray<__kindof id<DKDSecureMessage>> *)processSecure:(id<DKDSecureMessage>)sMsg
                                              withMessage:(id<DKDReliableMessage>)rMsg;

// NOTICE: override to save the received instant message
- (NSArray<__kindof id<DKDInstantMessage>> *)processInstant:(id<DKDInstantMessage>)iMsg
                                                withMessage:(id<DKDReliableMessage>)rMsg;

// NOTICE: override to check group
// NOTICE: override to filter the response
- (NSArray<__kindof id<DKDContent>> *)processContent:(id<DKDContent>)content
                                         withMessage:(id<DKDReliableMessage>)rMsg;

@end

NS_ASSUME_NONNULL_END
