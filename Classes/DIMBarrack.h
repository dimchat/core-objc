//
//  DIMBarrack.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DIMEntityDataSource <MKMEntityDataSource>

/**
 *  Save meta into local storage
 *
 * @param meta - Meta info
 * @param ID - entity ID
 * @return YES on success
 */
- (BOOL)saveMeta:(MKMMeta *)meta forID:(MKMID *)ID;

/**
 *  Save profile into local storage
 *
 * @param profile - The Additional Information
 * @return YES on success
 */
- (BOOL)saveProfile:(DIMProfile *)profile;

@end

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
                                  DIMGroupDataSource> {
    
    __weak __kindof id<DIMEntityDataSource> _entityDataSource;
    __weak __kindof id<DIMUserDataSource> _userDataSource;
    __weak __kindof id<DIMGroupDataSource> _groupDataSource;
}

@property (weak, nonatomic, nullable) id<DIMEntityDataSource> entityDataSource;
@property (weak, nonatomic, nullable) id<DIMUserDataSource> userDataSource;
@property (weak, nonatomic, nullable) id<DIMGroupDataSource> groupDataSource;

- (BOOL)cacheMeta:(DIMMeta *)meta forID:(DIMID *)ID;
- (BOOL)cacheProfile:(DIMProfile *)profile; // verify it with meta.key

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
