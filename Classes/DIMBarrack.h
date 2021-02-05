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

#import <DaoKeDao/DaoKeDao.h>

#import <DIMCore/DIMUser.h>
#import <DIMCore/DIMGroup.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DIMEntityDelegate <NSObject>

/**
 *  Select local user for receiver
 *
 * @param receiver - user/group ID
 * @return local user
 */
- (nullable DIMUser *)selectLocalUserWithID:(id<MKMID>)receiver;

/**
 *  Create user with ID
 *
 * @param ID - user ID
 * @return user
 */
- (nullable __kindof DIMUser *)userWithID:(id<MKMID>)ID;

/**
 *  Create group with ID
 *
 * @param ID - group ID
 * @return group
 */
- (nullable __kindof DIMGroup *)groupWithID:(id<MKMID>)ID;

@end

/**
 *  Entity pool to manage User/Contace/Group/Member instances
 *
 *      1st, get instance here to avoid create same instance,
 *      2nd, if they were updated, we can refresh them immediately here
 */
@interface DIMBarrack : NSObject <DIMEntityDelegate,
                                  DIMUserDataSource,
                                  DIMGroupDataSource>

/**
 *  Get all local users (for decrypting received message)
 *
 * @return users with private key
 */
@property (readonly, strong, nonatomic, nullable) NSArray<DIMUser *> *localUsers;

/**
 * Call it when received 'UIApplicationDidReceiveMemoryWarningNotification',
 * this will remove 50% of cached objects
 *
 * @return number of survivors
 */
- (NSInteger)reduceMemory;

// override to create user
- (nullable DIMUser *)createUser:(id<MKMID>)ID;
// override to create group
- (nullable DIMGroup *)createGroup:(id<MKMID>)ID;

// broadcast group
- (nullable id<MKMID>)founderOfBroadcastGroup:(id<MKMID>)group;
- (nullable id<MKMID>)ownerOfBroadcastGroup:(id<MKMID>)group;
- (nullable NSArray<id<MKMID>> *)membersOfBroadcastGroup:(id<MKMID>)group;

@end

NS_ASSUME_NONNULL_END
