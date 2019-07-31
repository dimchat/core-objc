//
//  DIMBarrack.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Entity pool to manage User/Contace/Group/Member instances
 *
 *      1st, get instance here to avoid create same instance,
 *      2nd, if they were updated, we can refresh them immediately here
 */
@interface DIMBarrack : NSObject <DIMEntityDataSource,
                                  DIMUserDataSource,
                                  DIMGroupDataSource>

@property (weak, nonatomic) id<DIMEntityDataSource> entityDataSource;
@property (weak, nonatomic) id<DIMUserDataSource> userDataSource;
@property (weak, nonatomic) id<DIMGroupDataSource> groupDataSource;

- (BOOL)cacheID:(DIMID *)ID;
- (BOOL)cacheMeta:(DIMMeta *)meta forID:(DIMID *)ID;

- (BOOL)cacheAccount:(DIMAccount *)account;
- (BOOL)cacheUser:(DIMUser *)user;
- (BOOL)cacheGroup:(DIMGroup *)group;

/**
 *  Create ID with string
 *
 * @param string - ID string
 * @return ID
 */
- (nullable DIMID *)IDWithString:(NSString *)string;
/**
 *  Create account with ID
 *
 * @param ID - account ID
 * @return account
 */
- (nullable DIMAccount *)accountWithID:(DIMID *)ID;

/**
 *  Create user with ID
 *
 * @param ID - user ID
 * @return user
 */
- (nullable DIMUser *)userWithID:(DIMID *)ID;

/**
 *  Create group with ID
 *
 * @param ID - group ID
 * @return group
 */
- (nullable DIMGroup *)groupWithID:(DIMID *)ID;

/**
 * Call it when received 'UIApplicationDidReceiveMemoryWarningNotification',
 * this will remove 50% of cached objects
 *
 * @return reduced object count
 */
- (NSInteger)reduceMemory;

@end

NS_ASSUME_NONNULL_END
