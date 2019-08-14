//
//  DIMBarrack.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DIMSocialNetworkDataSource <DIMEntityDataSource>

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
@interface DIMBarrack : NSObject <DIMSocialNetworkDataSource,
                                  DIMUserDataSource,
                                  DIMGroupDataSource>

- (BOOL)cacheMeta:(DIMMeta *)meta forID:(DIMID *)ID;
- (BOOL)cacheID:(DIMID *)ID;
- (BOOL)cacheUser:(DIMUser *)user;
- (BOOL)cacheGroup:(DIMGroup *)group;

/**
 * Call it when received 'UIApplicationDidReceiveMemoryWarningNotification',
 * this will remove 50% of cached objects
 *
 * @return reduced object count
 */
- (NSInteger)reduceMemory;

@end

NS_ASSUME_NONNULL_END
