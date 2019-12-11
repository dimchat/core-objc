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
//  dimMacros.h
//  DIMCore
//
//  Created by Albert Moky on 2018/12/21.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#ifndef dimMacros_h
#define dimMacros_h

#import <MingKeMing/MingKeMing.h>

// Cryptography
#define DIMEncryptKey                   MKMEncryptKey
#define DIMDecryptKey                   MKMDecryptKey
#define DIMSignKey                      MKMSignKey
#define DIMVerifyKey                    MKMVerifyKey

#define DIMSymmetricKey                 MKMSymmetricKey
#define DIMPublicKey                    MKMPublicKey
#define DIMPrivateKey                   MKMPrivateKey

// Entity
#define DIMID                           MKMID
#define DIMAddress                      MKMAddress
#define DIMMeta                         MKMMeta
#define DIMProfile                      MKMProfile
#define DIMEntity                       MKMEntity
#define DIMEntityDataSource             MKMEntityDataSource

// User
#define DIMUser                         MKMUser
#define DIMUserDataSource               MKMUserDataSource

// Group
#define DIMGroup                        MKMGroup
#define DIMGroupDataSource              MKMGroupDataSource


#import <DaoKeDao/DaoKeDao.h>

// Types
#define DIMDictionary                   DKDDictionary

#define DIMEnvelope                     DKDEnvelope
#define DIMContent                      DKDContent
#define DIMForwardContent               DKDForwardContent

// Message
#define DIMMessage                      DKDMessage
#define DIMInstantMessage               DKDInstantMessage
#define DIMSecureMessage                DKDSecureMessage
#define DIMReliableMessage              DKDReliableMessage

#define DIMMessageDelegate              DKDMessageDelegate
#define DIMInstantMessageDelegate       DKDInstantMessageDelegate
#define DIMSecureMessageDelegate        DKDSecureMessageDelegate
#define DIMReliableMessageDelegate      DKDReliableMessageDelegate

#endif /* dimMacros_h */
