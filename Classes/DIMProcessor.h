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
//  DIMProcessor.h
//  DIMCore
//
//  Created by Albert Moky on 2020/12/8.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import <DaoKeDao/DaoKeDao.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMProcessor : NSObject

@property (weak, nonatomic) id<DKDMessageDelegate> delegate;

- (instancetype)initWithTransceiver:(id<DKDMessageDelegate>)delegate;

- (MKMUser *)selectLocalUser:(id<MKMID>)receiver;
- (NSArray<id<MKMID>> *)membersOfGroup:(id<MKMID>)group;
- (id<MKMSymmetricKey>)symmetricKeyFrom:(id<MKMID>)sender to:(id<MKMID>)receiver;

@end

@interface DIMProcessor (Transform)

- (nullable id<DKDSecureMessage>)encryptMessage:(id<DKDInstantMessage>)iMsg;

- (nullable id<DKDReliableMessage>)signMessage:(id<DKDSecureMessage>)sMsg;

- (nullable id<DKDSecureMessage>)verifyMessage:(id<DKDReliableMessage>)rMsg;

- (nullable id<DKDInstantMessage>)decryptMessage:(id<DKDSecureMessage>)sMsg;

@end

@interface DIMProcessor (Serialization)

- (nullable NSData *)serializeMessage:(id<DKDReliableMessage>)rMsg;
- (nullable id<DKDReliableMessage>)deserializeMessage:(NSData *)data;

@end

@interface DIMProcessor (Processing)

/**
 *  Process received data package
 *
 * @param data - package from network connection
 * @return response to sender
 */
- (nullable NSData *)processPackage:(NSData *)data;

// TODO: override to check broadcast message before calling it
// TODO: override to deliver to the receiver when catch exception "receiver error ..."
- (nullable id<DKDReliableMessage>)processMessage:(id<DKDReliableMessage>)rMsg;

- (nullable id<DKDContent>)processContent:(id<DKDContent>)content
                                message:(id<DKDReliableMessage>)rMsg;

@end

NS_ASSUME_NONNULL_END
