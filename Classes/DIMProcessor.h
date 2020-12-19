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

#import "DIMPacker.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Message Processor
 *  ~~~~~~~~~~~~~~~~~
 */
@interface DIMProcessor : NSObject

@property (readonly, weak, nonatomic) id<DIMEntityDelegate> barrack;
@property (readonly, weak, nonatomic) id<DKDMessageDelegate> transceiver;
@property (readonly, weak, nonatomic) DIMPacker *packer;

- (instancetype)initWithEntityDelegate:(id<DIMEntityDelegate>)barrack
                       messageDelegate:(id<DKDMessageDelegate>)transceiver
                                packer:(DIMPacker *)messagePacker;

/**
 *  Process received data package
 *
 * @param data - package from network connection
 * @return response to sender
 */
- (nullable NSData *)processData:(NSData *)data;

// TODO: override to check broadcast message before calling it
// TODO: override to deliver to the receiver when catch exception "ReceiverError"
- (nullable id<DKDReliableMessage>)processMessage:(id<DKDReliableMessage>)rMsg;

- (nullable id<DKDSecureMessage>)processSecure:(id<DKDSecureMessage>)sMsg
                                   withMessage:(id<DKDReliableMessage>)rMsg;

// TODO: override to save the received instant message
- (nullable id<DKDInstantMessage>)processInstant:(id<DKDInstantMessage>)iMsg
                                     withMessage:(id<DKDReliableMessage>)rMsg;

// TODO: override to check group
// TODO: override to filter the response
- (nullable id<DKDContent>)processContent:(id<DKDContent>)content
                              withMessage:(id<DKDReliableMessage>)rMsg;

@end

NS_ASSUME_NONNULL_END
