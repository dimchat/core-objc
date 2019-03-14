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

#define DIMAccountWithID(ID)     [DIMFacebook() accountWithID:(ID)]
#define DIMUserWithID(ID)        [DIMFacebook() userWithID:(ID)]

#define DIMGroupWithID(ID)       [DIMFacebook() groupWithID:(ID)]
#define DIMMemberWithID(ID, gID) [DIMFacebook() memberWithID:(ID) groupID:(gID)]

#define DIMMetaForID(ID)         [DIMFacebook() metaForID:(ID)]
#define DIMPublicKeyForID(ID)    DIMMetaForID(ID).key
#define DIMProfileForID(ID)      [DIMFacebook() profileForID:(ID)]

/**
 *  Entity pool to manage User/Contace/Group/Member instances
 *
 *      1st, get instance here to avoid create same instance,
 *      2nd, if they were updated, we can refresh them immediately here
 */
@interface DIMBarrack : NSObject <DIMMetaDataSource,
                                  DIMEntityDataSource,
                                  DIMAccountDelegate,
                                  DIMUserDataSource,
                                  DIMUserDelegate,
                                  //-
                                  DIMGroupDataSource,
                                  DIMGroupDelegate,
                                  DIMMemberDelegate,
                                  DIMChatroomDataSource,
                                  //-
                                  DIMProfileDataSource>

@property (weak, nonatomic) id<DIMMetaDataSource> metaDataSource;
@property (weak, nonatomic) id<DIMEntityDataSource> entityDataSource;
@property (weak, nonatomic) id<DIMAccountDelegate> accountDelegate;
@property (weak, nonatomic) id<DIMUserDataSource> userDataSource;
@property (weak, nonatomic) id<DIMUserDelegate> userDelegate;

@property (weak, nonatomic) id<DIMGroupDataSource> groupDataSource;
@property (weak, nonatomic) id<DIMGroupDelegate> groupDelegate;
@property (weak, nonatomic) id<DIMMemberDelegate> memberDelegate;
@property (weak, nonatomic) id<DIMChatroomDataSource> chatroomDataSource;

@property (weak, nonatomic) id<DIMProfileDataSource> profileDataSource;

+ (instancetype)sharedInstance;

- (void)addAccount:(DIMAccount *)account;
- (void)addUser:(DIMUser *)user;

- (void)addGroup:(DIMGroup *)group;
- (void)addMember:(DIMMember *)member;

- (BOOL)setMeta:(const DIMMeta *)meta forID:(const DIMID *)ID;

/**
 Call it when receive 'UIApplicationDidReceiveMemoryWarningNotification',
 this will remove 50% of unused objects from the cache
 */
- (void)reduceMemory;

@end

NS_ASSUME_NONNULL_END
