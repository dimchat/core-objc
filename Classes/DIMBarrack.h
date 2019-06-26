//
//  DIMBarrack.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DIMBarrackDelegate;

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

@property (weak, nonatomic) id<DIMBarrackDelegate> delegate;

- (void)addAccount:(DIMAccount *)account;
- (void)addUser:(DIMUser *)user;
- (void)addGroup:(DIMGroup *)group;

- (nullable DIMAccount *)accountWithID:(DIMID *)ID;
- (nullable DIMUser *)userWithID:(DIMID *)ID;
- (nullable DIMGroup *)groupWithID:(DIMID *)ID;

// default "Documents/.mkm/{address}/meta.plist"
- (nullable DIMMeta *)loadMetaForID:(DIMID *)ID;

/**
 * Call it when received 'UIApplicationDidReceiveMemoryWarningNotification',
 * this will remove 50% of cached objects
 *
 * @return reduced object count
 */
- (NSInteger)reduceMemory;

@end

#pragma mark - Barrack Delegate

@protocol DIMBarrackDelegate <NSObject>

- (nullable DIMAccount *)accountWithID:(DIMID *)ID;
- (nullable DIMUser *)userWithID:(DIMID *)ID;
- (nullable DIMGroup *)groupWithID:(DIMID *)ID;

@end

NS_ASSUME_NONNULL_END
