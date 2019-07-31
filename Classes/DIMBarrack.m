//
//  DIMBarrack.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMBarrack.h"

typedef NSMutableDictionary<NSString *, DIMID *> IDTableM;
typedef NSMutableDictionary<DIMID *, DIMMeta *> MetaTableM;

typedef NSMutableDictionary<DIMID *, DIMAccount *> AccountTableM;
typedef NSMutableDictionary<DIMID *, DIMUser *> UserTableM;
typedef NSMutableDictionary<DIMID *, DIMGroup *> GroupTableM;

@interface DIMBarrack () {
    
    IDTableM *_idTable;
    MetaTableM *_metaTable;
    
    AccountTableM *_accountTable;
    UserTableM *_userTable;
    GroupTableM *_groupTable;
}

@end

/**
 *  Remove 1/2 objects from the dictionary
 *
 * @param mDict - mutable dictionary
 */
static inline NSInteger thanos(NSMutableDictionary *mDict, NSInteger finger) {
    NSArray *keys = [mDict allKeys];
    for (id addr in keys) {
        if ((++finger & 1) == 0) {
            // let it go
            continue;
        }
        // kill it
        [mDict removeObjectForKey:addr];
    }
    return finger;
}

@implementation DIMBarrack

- (instancetype)init {
    if (self = [super init]) {
        _idTable = [[IDTableM alloc] init];
        _metaTable = [[MetaTableM alloc] init];
        
        _accountTable = [[AccountTableM alloc] init];
        _userTable = [[UserTableM alloc] init];
        _groupTable = [[GroupTableM alloc] init];
        
        // delegates
        _entityDataSource = nil;
        _userDataSource = nil;
        _groupDataSource = nil;
    }
    return self;
}

- (NSInteger)reduceMemory {
    NSInteger finger = 0;
    finger = thanos(_idTable, finger);
    finger = thanos(_metaTable, finger);
    finger = thanos(_accountTable, finger);
    finger = thanos(_userTable, finger);
    finger = thanos(_groupTable, finger);
    return (finger & 1) + (finger >> 1);
}

- (BOOL)cacheID:(MKMID *)ID {
    NSAssert([ID isValid], @"ID error: %@", ID);
    [_idTable setObject:ID forKey:ID];
    return YES;
}

- (BOOL)cacheMeta:(DIMMeta *)meta forID:(DIMID *)ID {
    if ([meta matchID:ID]) {
        [_metaTable setObject:meta forKey:ID.address];
        return YES;
    }
    return NO;
}

- (BOOL)cacheAccount:(DIMAccount *)account {
    DIMID *ID = account.ID;
    NSAssert(MKMNetwork_IsCommunicator(ID.type), @"account ID error: %@", ID);
    if ([account isKindOfClass:[DIMUser class]]) {
        // add to user table
        return [self cacheUser:(DIMUser *)account];
    }
    if ([ID isValid]) {
        if (account.dataSource == nil) {
            account.dataSource = self;
        }
        [_accountTable setObject:account forKey:ID.address];
        return YES;
    }
    return NO;
}

- (BOOL)cacheUser:(DIMUser *)user {
    DIMID *ID = user.ID;
    NSAssert(MKMNetwork_IsPerson(ID.type), @"user ID error: %@", ID);
    // erase from account table
    if ([_accountTable objectForKey:ID]) {
        [_accountTable removeObjectForKey:ID];
    }
    if ([ID isValid]) {
        if (user.dataSource == nil) {
            user.dataSource = self;
        }
        [_userTable setObject:user forKey:ID.address];
        return YES;
    }
    return NO;
}

- (BOOL)cacheGroup:(DIMGroup *)group {
    DIMID *ID = group.ID;
    NSAssert(MKMNetwork_IsGroup(ID.type), @"group ID error: %@", ID);
    if ([ID isValid]) {
        if (group.dataSource == nil) {
            group.dataSource = self;
        }
        [_groupTable setObject:group forKey:ID.address];
        return YES;
    }
    return NO;
}

- (nullable DIMID *)IDWithString:(NSString *)string {
    // get from ID cache
    DIMID *ID = [_idTable objectForKey:string];
    if (ID) {
        return ID;
    }
    // create and cache it
    ID = MKMIDFromString(string);
    if (ID) {
        [self cacheID:ID];
        return ID;
    }
    // failed to create ID
    return nil;
}

- (nullable DIMAccount *)accountWithID:(DIMID *)ID {
    NSAssert(MKMNetwork_IsCommunicator(ID.type), @"account ID error: %@", ID);
    // get from account cache
    DIMAccount *account = [_accountTable objectForKey:ID];
    if (account) {
        return account;
    }
    // get from user cache
    account = [_userTable objectForKey:ID];
    if (account) {
        return account;
    }
    // failed to get account
    return nil;
}

- (nullable DIMUser *)userWithID:(DIMID *)ID {
    NSAssert(MKMNetwork_IsPerson(ID.type), @"user ID error: %@", ID);
    // get from user cache
    DIMUser *user = [_userTable objectForKey:ID];
    if (user) {
        return user;
    }
    // failed to get user
    return nil;
}

- (nullable DIMGroup *)groupWithID:(DIMID *)ID {
    NSAssert(MKMNetwork_IsGroup(ID.type), @"group ID error: %@", ID);
    // get from group cache
    DIMGroup *group = [_groupTable objectForKey:ID];
    if (group) {
        return group;
    }
    // failed to get group
    return nil;
}

#pragma mark - DIMEntityDataSource

- (nullable DIMMeta *)metaForID:(DIMID *)ID {
    // get from meta cache
    DIMMeta *meta = [_metaTable objectForKey:ID];
    if (meta) {
        return meta;
    }
    // get from entity data source
    NSAssert(_entityDataSource, @"entity data source not set");
    meta = [_entityDataSource metaForID:ID];
    // check and cache it
    if ([self cacheMeta:meta forID:ID]) {
        return meta;
    }
    // failed to get meta
    NSAssert(!meta, @"meta error: %@ -> %@", ID, meta);
    return nil;
}

- (BOOL)saveMeta:(DIMMeta *)meta forID:(DIMID *)ID {
    if (![self cacheMeta:meta forID:ID]) {
        NSAssert(false, @"meta not match ID: %@, %@", ID, meta);
        return NO;
    }
    // try saving by delegate
    NSAssert(_entityDataSource, @"entity data source not set");
    return [_entityDataSource saveMeta:meta forID:ID];
}

- (nullable DIMProfile *)profileForID:(DIMID *)ID {
    NSAssert(_entityDataSource, @"entity data source not set");
    return [_entityDataSource profileForID:ID];
}

#pragma mark - DIMUserDataSource

- (DIMPrivateKey *)privateKeyForSignatureOfUser:(DIMID *)user {
    NSAssert(MKMNetwork_IsPerson(user.type), @"user error: %@", user);
    NSAssert(_userDataSource, @"user data source not set");
    return [_userDataSource privateKeyForSignatureOfUser:user];
}

- (NSArray<DIMPrivateKey *> *)privateKeysForDecryptionOfUser:(DIMID *)user {
    NSAssert(MKMNetwork_IsPerson(user.type), @"user error: %@", user);
    NSAssert(_userDataSource, @"user data source not set");
    return [_userDataSource privateKeysForDecryptionOfUser:user];
}

- (NSArray<DIMID *> *)contactsOfUser:(DIMID *)user {
    NSAssert(MKMNetwork_IsPerson(user.type), @"user error: %@", user);
    NSAssert(_userDataSource, @"user data source not set");
    return [_userDataSource contactsOfUser:user];
}

#pragma mark - DIMGroupDataSource

- (DIMID *)founderOfGroup:(DIMID *)group {
    NSAssert(MKMNetwork_IsGroup(group.type), @"group error: %@", group);
    NSAssert(_groupDataSource, @"group data source not set");
    // get from data source
    DIMID *founder = [_groupDataSource founderOfGroup:group];
    if (founder) {
        return founder;
    }
    // check each member's public key with group meta
    DIMMeta *groupMeta = [self metaForID:group];
    NSArray<DIMID *> *members = [self membersOfGroup:group];
    DIMMeta *meta;
    for (DIMID *member in members) {
        meta = [self metaForID:member];
        if ([groupMeta matchPublicKey:meta.key]) {
            return member;
        }
    }
    return nil;
}

- (nullable DIMID *)ownerOfGroup:(DIMID *)group {
    NSAssert(MKMNetwork_IsGroup(group.type), @"group error: %@", group);
    NSAssert(_groupDataSource, @"group data source not set");
    return [_groupDataSource ownerOfGroup:group];
}

- (NSArray<DIMID *> *)membersOfGroup:(DIMID *)group {
    NSAssert(MKMNetwork_IsGroup(group.type), @"group error: %@", group);
    NSAssert(_groupDataSource, @"group data source not set");
    return [_groupDataSource membersOfGroup:group];
}

@end
