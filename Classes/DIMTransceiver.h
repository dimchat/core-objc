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
//  DIMTransceiver.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/7.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DIMSocialNetworkDataSource;
@protocol DIMCipherKeyDataSource;

@interface DIMTransceiver : NSObject <DIMInstantMessageDelegate,
                                      DIMSecureMessageDelegate,
                                      DIMReliableMessageDelegate> {
                                          
    __weak id<DIMSocialNetworkDataSource> _barrack;
    __weak id<DIMCipherKeyDataSource> _keyCache;
}

@property (weak, nonatomic) id<DIMSocialNetworkDataSource> barrack;
@property (weak, nonatomic) id<DIMCipherKeyDataSource> keyCache;

@end

@interface DIMTransceiver (Serialization)

/**
 *  De/serialize message content
 */
- (nullable NSData *)message:(DIMInstantMessage *)iMsg
            serializeContent:(DIMContent *)content;
- (nullable DIMContent *)message:(DIMSecureMessage *)sMsg
              deserializeContent:(NSData *)data;

/**
 *  De/serialize symmetric key
 */
- (nullable NSData *)message:(DIMInstantMessage *)iMsg
                serializeKey:(DIMSymmetricKey *)password;
- (nullable DIMSymmetricKey *)message:(DIMSecureMessage *)sMsg
                       deserializeKey:(NSData *)data;

/**
 *  De/serialize message
 */
- (nullable NSData *)serializeMessage:(DIMReliableMessage *)rMsg;
- (nullable DIMReliableMessage *)deserializeMessage:(NSData *)data;

@end

@interface DIMTransceiver (Transform)

- (nullable DIMSecureMessage *)encryptMessage:(DIMInstantMessage *)iMsg;

- (nullable DIMReliableMessage *)signMessage:(DIMSecureMessage *)sMsg;

- (nullable DIMSecureMessage *)verifyMessage:(DIMReliableMessage *)rMsg;

- (nullable DIMInstantMessage *)decryptMessage:(DIMSecureMessage *)sMsg;

@end

NS_ASSUME_NONNULL_END
