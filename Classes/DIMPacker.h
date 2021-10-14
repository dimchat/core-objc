// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2020 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2020 Albert Moky
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
//  DIMPacker.h
//  DIMCore
//
//  Created by Albert Moky on 2020/12/19.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import <DaoKeDao/DaoKeDao.h>

NS_ASSUME_NONNULL_BEGIN

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
- (nullable id<MKMID>)overtGroupForContent:(id<DKDContent>)content;

//
//  InstantMessage -> SecureMessage -> ReliableMessage -> Data
//
- (nullable id<DKDSecureMessage>)encryptMessage:(id<DKDInstantMessage>)iMsg;

- (nullable id<DKDReliableMessage>)signMessage:(id<DKDSecureMessage>)sMsg;

- (nullable NSData *)serializeMessage:(id<DKDReliableMessage>)rMsg;

//
//  Data -> ReliableMessage -> SecureMessage -> InstantMessage
//
- (nullable id<DKDReliableMessage>)deserializeMessage:(NSData *)data;

- (nullable id<DKDSecureMessage>)verifyMessage:(id<DKDReliableMessage>)rMsg;

- (nullable id<DKDInstantMessage>)decryptMessage:(id<DKDSecureMessage>)sMsg;

@end

@class DIMTransceiver;
@protocol DIMEntityDelegate;
@protocol DIMCipherKeyDelegate;

@interface DIMPacker : NSObject <DIMPacker>

@property (readonly, weak, nonatomic) __kindof DIMTransceiver *transceiver;

- (instancetype)initWithTransceiver:(DIMTransceiver *)transceiver
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
