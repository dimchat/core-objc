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
//  DKDForwardContent.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/10/23.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMContent.h"

NS_ASSUME_NONNULL_BEGIN

/*
 *  Top-Secret message: {
 *      type : 0xFF,
 *      sn   : 456,
 *
 *      forward : {...}  // reliable (secure + certified) message
 *  }
 */
@protocol DIMForwardContent <DKDContent>

// Top-Secret message forwarded by a proxy (Service Provider)
@property (readonly, nonatomic) id<DKDReliableMessage> forwardMessage;

@end

@interface DIMForwardContent : DKDContent <DIMForwardContent>

- (instancetype)initWithForwardMessage:(id<DKDReliableMessage>)rMsg;

@end

NS_ASSUME_NONNULL_END
