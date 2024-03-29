// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2021 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2021 Albert Moky
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
//  DIMTransferContent.h
//  DIMCore
//
//  Created by Albert Moky on 2021/4/15.
//  Copyright © 2021 DIM Group. All rights reserved.
//

#import <DIMCore/DIMMoneyContent.h>

NS_ASSUME_NONNULL_BEGIN

/*
 *  Transfer money message: {
 *      type : 0x41,
 *      sn   : 123,
 *
 *      currency : "RMB",    // USD, USDT, ...
 *      amount   : 100.00,
 *      remitter : "{FROM}", // sender ID
 *      remittee : "{TO}"    // receiver ID
 *  }
 */
@protocol DKDTransferContent <DKDMoneyContent>

@property (strong, nonatomic, nullable) id<MKMID> remitter;
@property (strong, nonatomic, nullable) id<MKMID> remittee;

@end

@interface DIMTransferContent : DIMMoneyContent <DKDTransferContent>

@end

#ifdef __cplusplus
extern "C" {
#endif

DIMTransferContent *DIMTransferContentCreate(NSString *currency, float value);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
