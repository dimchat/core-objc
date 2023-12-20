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
//  DIMBarrack.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <DIMCore/DIMUser.h>
#import <DIMCore/DIMGroup.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKMEntityDelegate <NSObject>

/**
 *  Create user with ID
 *
 * @param ID - user ID
 * @return user
 */
- (nullable __kindof id<MKMUser>)userWithID:(id<MKMID>)ID;

/**
 *  Create group with ID
 *
 * @param ID - group ID
 * @return group
 */
- (nullable __kindof id<MKMGroup>)groupWithID:(id<MKMID>)ID;

@end

/**
 *  Entity Database
 *  ~~~~~~~~~~~~~~~
 *  Entity pool to manage User/Contact/Group/Member instances
 *  Manage meta/document for all entities
 *
 *      1st, get instance here to avoid create same instance,
 *      2nd, if they were updated, we can refresh them immediately here
 */
@interface DIMBarrack : NSObject <MKMEntityDelegate, MKMUserDataSource, MKMGroupDataSource>

- (nullable __kindof id<MKMVisa>)visaForID:(id<MKMID>)ID;

- (nullable __kindof id<MKMBulletin>)bulletinForID:(id<MKMID>)ID;

@end

// protected
@interface DIMBarrack (facebook)

- (void)cacheUser:(id<MKMUser>)user;

- (void)cacheGroup:(id<MKMGroup>)group;

/**
 *  Create user when visa.key exists
 *
 * @param ID - user ID
 * @return user, null on not ready
 */
- (nullable __kindof id<MKMUser>)createUser:(id<MKMID>)ID;

/**
 *  Create group when members exist
 *
 * @param ID - group ID
 * @return group, null on not ready
 */
- (nullable __kindof id<MKMGroup>)createGroup:(id<MKMID>)ID;

- (nullable __kindof id<MKMEncryptKey>)visaKeyForID:(id<MKMID>)user;

- (nullable __kindof id<MKMVerifyKey>)metaKeyForID:(id<MKMID>)user;

@end

@interface DIMBarrack (thanos)

/**
 * Call it when received 'UIApplicationDidReceiveMemoryWarningNotification',
 * this will remove 50% of cached objects
 *
 * @return number of survivors
 */
- (NSInteger)reduceMemory;

@end

#ifdef __cplusplus
extern "C" {
#endif

// Thanos can kill half lives of a world with a snap of the finger
NSUInteger DIMThanos(NSMutableDictionary *planet, NSUInteger finger);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
