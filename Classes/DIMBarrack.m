//
//  DIMBarrack.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMBarrack.h"

typedef NSMutableDictionary<DIMAddress *, DIMMeta *> MetaTableM;

typedef NSMutableDictionary<DIMAddress *, DIMAccount *> AccountTableM;
typedef NSMutableDictionary<DIMAddress *, DIMUser *> UserTableM;
typedef NSMutableDictionary<DIMAddress *, DIMGroup *> GroupTableM;

@interface DIMBarrack () {
    
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
        _metaTable = [[MetaTableM alloc] init];
        
        _accountTable = [[AccountTableM alloc] init];
        _userTable = [[UserTableM alloc] init];
        _groupTable = [[GroupTableM alloc] init];
        
        // delegates
        _entityDataSource = nil;
        _userDataSource = nil;
        _groupDataSource = nil;
        
        _delegate = nil;
    }
    return self;
}

- (NSInteger)reduceMemory {
    NSInteger finger = 0;
    finger = thanos(_metaTable, finger);
    finger = thanos(_accountTable, finger);
    finger = thanos(_userTable, finger);
    finger = thanos(_groupTable, finger);
    return (finger & 1) + (finger >> 1);
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
    if ([_accountTable objectForKey:ID.address]) {
        [_accountTable removeObjectForKey:ID.address];
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

#pragma mark DIMBarrackDelegate

- (nullable DIMAccount *)accountWithID:(DIMID *)ID {
    NSAssert(MKMNetwork_IsCommunicator(ID.type), @"account ID error: %@", ID);
    DIMAccount *account;
    
    // (a) get from account cache
    account = [_accountTable objectForKey:ID.address];
    if (account) {
        return account;
    }
    // (b) get from user cache
    account = [_userTable objectForKey:ID.address];
    if (account) {
        return account;
    }
    
    // (c) get from delegate
    account = [_delegate accountWithID:ID];
    if (account) {
        [self cacheAccount:account];
        return account;
    }
    
    // failed to get account
    return nil;
}

- (nullable DIMUser *)userWithID:(DIMID *)ID {
    NSAssert(MKMNetwork_IsPerson(ID.type), @"user ID error: %@", ID);
    DIMUser *user;
    
    // (a) get from user cache
    user = [_userTable objectForKey:ID.address];
    if (user) {
        return user;
    }
    
    // (b) get from delegate
    user = [_delegate userWithID:ID];
    if (user) {
        [self cacheUser:user];
        return user;
    }
    
    // failed to get user
    return nil;
}

- (nullable DIMGroup *)groupWithID:(DIMID *)ID {
    NSAssert(MKMNetwork_IsGroup(ID.type), @"group ID error: %@", ID);
    DIMGroup *group;
    
    // (a) get from group cache
    group = [_groupTable objectForKey:ID.address];
    if (group) {
        return group;
    }
    
    // (b) get from delegate
    group = [_delegate groupWithID:ID];
    if (group) {
        [self cacheGroup:group];
        return group;
    }
    
    // failed to get group
    return nil;
}

#pragma mark - DIMEntityDataSource

- (nullable DIMMeta *)metaForID:(DIMID *)ID {
    // (a) get from meta cache
    DIMMeta *meta = [_metaTable objectForKey:ID.address];
    if (meta) {
        return meta;
    }
    // (b) get from entity data source
    NSAssert(_entityDataSource, @"entity data source not set");
    meta = [_entityDataSource metaForID:ID];
    // (c) check and cache it
    if ([self cacheMeta:meta forID:ID]) {
        return meta;
    } else {
        NSAssert(!meta, @"meta error: %@ -> %@", ID, meta);
        return nil;
    }
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
    // 1. get from data source
    DIMID *founder = [_groupDataSource founderOfGroup:group];
    if (founder) {
        return founder;
    }
    // 2. check each member's public key with group meta
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
