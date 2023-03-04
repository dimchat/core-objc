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
- (nullable id<MKMUser>)userWithID:(id<MKMID>)ID;

/**
 *  Create group with ID
 *
 * @param ID - group ID
 * @return group
 */
- (nullable id<MKMGroup>)groupWithID:(id<MKMID>)ID;

@end

/**
 *  Entity pool to manage User/Contace/Group/Member instances
 *
 *      1st, get instance here to avoid create same instance,
 *      2nd, if they were updated, we can refresh them immediately here
 */
@interface DIMBarrack : NSObject <MKMEntityDelegate, MKMUserDataSource, MKMGroupDataSource>

@end

#ifdef __cplusplus
extern "C" {
#endif

id<MKMID> DIMBroadcastGroupFounder(id<MKMID> group);
id<MKMID> DIMBroadcastGroupOwner(id<MKMID> group);
NSArray<id<MKMID>> * DIMBroadcastGroupMembers(id<MKMID> group);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
