// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2023 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2023 Albert Moky
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
//  DIMHelpers.h
//  DIMCore
//
//  Created by Albert Moky on 2023/12/7.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <MingKeMing/MingKeMing.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMBroadcastHelper : NSObject

+ (id<MKMID>)broadcastFounder:(id<MKMID>)group;

+ (id<MKMID>)broadcastOwner:(id<MKMID>)group;

+ (NSArray<id<MKMID>> *)broadcastMembers:(id<MKMID>)group;

@end

@interface DIMMetaHelper : NSObject

+ (BOOL)checkMeta:(id<MKMMeta>)info;

+ (BOOL)meta:(id<MKMMeta>)info matchIdentifier:(id<MKMID>)ID;

+ (BOOL)meta:(id<MKMMeta>)info matchPublicKeyu:(id<MKMVerifyKey>)PK;

@end

@protocol MKMVisa;
@protocol MKMBulletin;

@interface DIMDocumentHelper : NSObject

/**
 *  Check whether this time is before old time
 */
+ (BOOL)time:(nullable NSDate *)thisTime isBefore:(nullable NSDate *)oldTime;

/**
 *  Check whether this document's time is before old document's time
 */
+ (BOOL)isExpired:(id<MKMDocument>)thisDoc compareTo:(id<MKMDocument>)oldDoc;

/**
 *  Select last document matched the type
 */
+ (nullable __kindof id<MKMDocument>)lastDocument:(NSArray<id<MKMDocument>> *)documents
                                          forType:(nullable NSString *)type;

/**
 *  Select last visa document
 */
+ (nullable __kindof id<MKMVisa>)lastVisa:(NSArray<id<MKMDocument>> *)documents;

/**
 *  Select last bulletin document
 */
+ (nullable __kindof id<MKMBulletin>)lastBulletin:(NSArray<id<MKMDocument>> *)documents;

@end

NS_ASSUME_NONNULL_END
