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
//  DIMGroup.h
//  DIMCore
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <DIMCore/DIMEntity.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DIMGroupDataSource <DIMEntityDataSource>

/**
 *  Get group founder
 *
 * @param group - group ID
 * @return fonder ID
 */
- (nullable __kindof id<MKMID>)founderOfGroup:(id<MKMID>)group;

/**
 *  Get group owner
 *
 * @param group - group ID
 * @return owner ID
 */
- (nullable __kindof id<MKMID>)ownerOfGroup:(id<MKMID>)group;

/**
 *  Get group members list
 *
 * @param group - group ID
 * @return members list (ID)
 */
- (nullable NSArray<__kindof id<MKMID>> *)membersOfGroup:(id<MKMID>)group;

/**
 *  Get assistants for this group
 *
 * @param group - group ID
 * @return robot ID list
 */
- (nullable NSArray<__kindof id<MKMID>> *)assistantsOfGroup:(id<MKMID>)group;

@end

@protocol DIMGroup <DIMEntity>

@property (readonly, strong, nonatomic, nullable) __kindof id<MKMBulletin> bulletin;

@property (readonly, strong, nonatomic) __kindof id<MKMID> founder;
@property (readonly, strong, nonatomic) __kindof id<MKMID> owner;

// NOTICE: the owner must be a member
//         (usually the first one)
@property (readonly, copy, nonatomic) NSArray<__kindof id<MKMID>> *members;

@property (readonly, copy, nonatomic) NSArray<__kindof id<MKMID>> *assistants;

@end

@interface DIMGroup : DIMEntity <DIMGroup>

@end

NS_ASSUME_NONNULL_END
