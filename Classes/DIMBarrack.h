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
//  DIMBarrack.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DIMEntityDelegate <NSObject>

/**
 *  Create ID with string
 *
 * @param string - ID string
 * @return ID
 */
- (nullable DIMID *)IDWithString:(NSString *)string;

/**
 *  Create user with ID
 *
 * @param ID - user ID
 * @return user
 */
- (nullable __kindof DIMUser *)userWithID:(DIMID *)ID;

/**
 *  Create group with ID
 *
 * @param ID - group ID
 * @return group
 */
- (nullable __kindof DIMGroup *)groupWithID:(DIMID *)ID;

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

- (BOOL)cacheID:(DIMID *)ID;
- (BOOL)cacheUser:(DIMUser *)user;
- (BOOL)cacheGroup:(DIMGroup *)group;

- (nullable DIMID *)createID:(NSString *)string;
- (nullable DIMUser *)createUser:(DIMID *)ID;
- (nullable DIMGroup *)createGroup:(DIMID *)ID;

/**
 * Call it when received 'UIApplicationDidReceiveMemoryWarningNotification',
 * this will remove 50% of cached objects
 *
 * @return number of survivors
 */
- (NSInteger)reduceMemory;

@end

NS_ASSUME_NONNULL_END
