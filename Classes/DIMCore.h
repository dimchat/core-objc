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
//  DIMCore.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for DIMCore.
FOUNDATION_EXPORT double DIMCoreVersionNumber;

//! Project version string for DIMCore.
FOUNDATION_EXPORT const unsigned char DIMCoreVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <DIMCore/PublicHeader.h>

// MKM
//#import <MingKeMing/MingKeMing.h>

// DKD
//#import <DaoKeDao/DaoKeDao.h>

#if !defined(__DIM_CORE__)
#define __DIM_CORE__ 1

// Format
#import <DIMCore/DIMBaseDataWrapper.h>
#import <DIMCore/DIMBaseFileWrapper.h>

// Crypto
#import <DIMCore/DIMBaseKey.h>
#import <DIMCore/DIMSymmetricKey.h>
#import <DIMCore/DIMAsymmetricKey.h>
#import <DIMCore/DIMPrivateKey.h>
#import <DIMCore/DIMPublicKey.h>

// Account
#import <DIMCore/DIMMeta.h>
#import <DIMCore/DIMDocument.h>
#import <DIMCore/DIMVisa.h>
#import <DIMCore/DIMBulletin.h>

// Message
#import <DIMCore/DIMEnvelope.h>
#import <DIMCore/DIMMessage.h>
#import <DIMCore/DIMInstantMessage.h>
#import <DIMCore/DIMSecureMessage.h>
#import <DIMCore/DIMReliableMessage.h>

// Content
#import <DIMCore/DKDContentType.h>
#import <DIMCore/DIMContent.h>
#import <DIMCore/DIMTextContent.h>
#import <DIMCore/DIMQuoteContent.h>
#import <DIMCore/DIMFileContent.h>
#import <DIMCore/DIMImageContent.h>
#import <DIMCore/DIMAudioContent.h>
#import <DIMCore/DIMVideoContent.h>
#import <DIMCore/DIMWebpageContent.h>
#import <DIMCore/DIMNameCard.h>
#import <DIMCore/DIMMoneyContent.h>
#import <DIMCore/DIMTransferContent.h>
#import <DIMCore/DIMForwardContent.h>
#import <DIMCore/DIMArrayContent.h>
#import <DIMCore/DIMCombineContent.h>
#import <DIMCore/DIMCustomizedContent.h>

// Commands
#import <DIMCore/DKDCommand.h>
#import <DIMCore/DIMCommand.h>
#import <DIMCore/DIMMetaCommand.h>
#import <DIMCore/DIMDocumentCommand.h>
#import <DIMCore/DIMReceiptCommand.h>
#import <DIMCore/DIMHistoryCommand.h>
#import <DIMCore/DIMGroupCommand.h>

#import <DIMCore/DIMSharedExtensions.h>

#endif /* ! __DIM_CORE__ */
