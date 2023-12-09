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
//  DIMEntity.h
//  DIMCore
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <MingKeMing/MingKeMing.h>

NS_ASSUME_NONNULL_BEGIN

/**
     *  Entity Data Source
     *  ~~~~~~~~~~~~~~~~~~
     *
     *      1. meta for user, which is generated by the user's private key
     *      2. meta for group, which is generated by the founder's private key
     *      3. meta key, which can verify message sent by this user(or group founder)
     *      4. visa key, which can encrypt message for the receiver(user)
     */
@protocol MKMEntityDataSource <NSObject>

/**
 *  Get meta for entity ID
 *
 * @param ID - entity ID
 * @return Meta
 */
- (nullable id<MKMMeta>)metaForID:(id<MKMID>)ID;

/**
 *  Get documents for entity ID
 *
 * @param ID - entity ID
 * @return Document List
 */
- (NSArray<id<MKMDocument>> *)documentsForID:(id<MKMID>)ID;

@end

/**
 *  Entity (User/Group)
 *  ~~~~~~~~~~~~~~~~~~~
 *  Base class of User and Group, ...
 *
 *  properties:
 *      identifier - entity ID
 *      type       - entity type
 *      meta       - meta for generate ID
 *      document   - visa for user, or bulletin for group
 */
@protocol MKMEntity <NSObject>

@property (readonly, strong, nonatomic) id<MKMID> ID;  // name@address

@property (readonly, nonatomic) MKMEntityType type;    // Network ID

@property (weak, nonatomic, nullable) __kindof id<MKMEntityDataSource> dataSource;

@property (readonly, strong, nonatomic) id<MKMMeta> meta;
@property (readonly, strong, nonatomic) NSArray<id<MKMDocument>> *documents;

@end

/**
 *  Base Entity
 */
@interface DIMEntity : NSObject <MKMEntity, NSCopying>

- (instancetype)initWithID:(id<MKMID>)ID NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END