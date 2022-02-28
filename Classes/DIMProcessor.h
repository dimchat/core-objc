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
- (NSArray<id<DKDReliableMessage>> *)processMessage:(id<DKDReliableMessage>)rMsg;

- (NSArray<id<DKDSecureMessage>> *)processSecure:(id<DKDSecureMessage>)sMsg
                                     withMessage:(id<DKDReliableMessage>)rMsg;

// NOTICE: override to save the received instant message
- (NSArray<id<DKDInstantMessage>> *)processInstant:(id<DKDInstantMessage>)iMsg
                                       withMessage:(id<DKDReliableMessage>)rMsg;

// NOTICE: override to check group
// NOTICE: override to filter the response
- (NSArray<id<DKDContent>> *)processContent:(id<DKDContent>)content
                                withMessage:(id<DKDReliableMessage>)rMsg;

@end

@class DIMTransceiver;
@protocol DIMEntityDelegate;
@protocol DIMMessagePacker;

@interface DIMProcessor : NSObject <DIMProcessor>

@property (readonly, weak, nonatomic) __kindof DIMTransceiver *transceiver;

- (instancetype)initWithTransceiver:(DIMTransceiver *)transceiver
NS_DESIGNATED_INITIALIZER;

@end

#ifdef __cplusplus
extern "C" {
#endif

/**
 *  Register Core Content/Command Factories
 */
void DIMRegisterCoreFactories(void);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
