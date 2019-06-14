//
//  DIMBarrack.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

#define DIMFacebook()            [DIMBarrack sharedInstance]

#define DIMMetaForID(ID)         [DIMFacebook() metaForID:(ID)]
#define DIMProfileForID(ID)      [DIMFacebook() profileForID:(ID)]

#define DIMAccountWithID(ID)     [DIMFacebook() accountWithID:(ID)]
#define DIMUserWithID(ID)        [DIMFacebook() userWithID:(ID)]
#define DIMGroupWithID(ID)       [DIMFacebook() groupWithID:(ID)]

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

+ (instancetype)sharedInstance;

- (void)addAccount:(DIMAccount *)account;
- (void)addUser:(DIMUser *)user;
- (void)addGroup:(DIMGroup *)group;

- (nullable DIMAccount *)accountWithID:(const DIMID *)ID;
- (nullable DIMUser *)userWithID:(const DIMID *)ID;
- (nullable DIMGroup *)groupWithID:(const DIMID *)ID;

- (BOOL)saveMeta:(const MKMMeta *)meta forID:(const MKMID *)ID;

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

- (BOOL)saveMeta:(const MKMMeta *)meta forID:(const MKMID *)ID;

- (nullable DIMAccount *)accountWithID:(const DIMID *)ID;
- (nullable DIMUser *)userWithID:(const DIMID *)ID;
- (nullable DIMGroup *)groupWithID:(const DIMID *)ID;

@end

NS_ASSUME_NONNULL_END
