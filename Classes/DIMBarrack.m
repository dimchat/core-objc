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

typedef NSMutableDictionary<DIMID *, DIMUser *> UserTableM;
typedef NSMutableDictionary<DIMID *, DIMGroup *> GroupTableM;

@interface DIMBarrack () {
    
    MetaTableM *_metaTable;
    
    IDTableM *_idTable;
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
        
        _idTable = [[IDTableM alloc] init];
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
    finger = thanos(_metaTable, finger);
    finger = thanos(_idTable, finger);
    finger = thanos(_userTable, finger);
    finger = thanos(_groupTable, finger);
    return (finger & 1) + (finger >> 1);
}

- (BOOL)cacheMeta:(DIMMeta *)meta forID:(DIMID *)ID {
    NSAssert([ID isValid], @"ID error: %@", ID);
    if (![meta matchID:ID]) {
        NSAssert(false, @"meta not match ID: %@, %@", ID, meta);
        return NO;
    }
    [_metaTable setObject:meta forKey:ID.address];
    return YES;
}

- (BOOL)cacheID:(DIMID *)ID {
    if (![ID isValid]) {
        NSAssert(false, @"ID not valid: %@", ID);
        return NO;
    }
    [_idTable setObject:ID forKey:ID];
    return YES;
}

- (BOOL)cacheUser:(DIMUser *)user {
    DIMID *ID = user.ID;
    NSAssert(MKMNetwork_IsUser(ID.type), @"user ID error: %@", ID);
    if (![ID isValid]) {
        NSAssert(false, @"user ID not valid: %@", ID);
        return NO;
    }
    if (user.dataSource == nil) {
        user.dataSource = self;
    }
    [_userTable setObject:user forKey:ID];
    return YES;
}

- (BOOL)cacheGroup:(DIMGroup *)group {
    DIMID *ID = group.ID;
    NSAssert(MKMNetwork_IsGroup(ID.type), @"group ID error: %@", ID);
    if (![ID isValid]) {
        NSAssert(false, @"group ID not valid: %@", ID);
        return NO;
    }
    if (group.dataSource == nil) {
        group.dataSource = self;
    }
    [_groupTable setObject:group forKey:ID];
    return YES;
}

- (nullable DIMID *)IDWithString:(NSString *)string {
    if (!string) {
        return nil;
    }
    // get from ID cache
    DIMID *ID = [_idTable objectForKey:string];
    if (ID) {
        return ID;
    }
    // create and cache it
    ID = MKMIDFromString(string);
    if (!ID) {
        NSAssert(false, @"failed to create ID: %@", string);
        return nil;
    }
    // check and cache it
    if (![self cacheID:ID]) {
        NSAssert(false, @"failed to cache ID: %@", ID);
        return nil;
    }
    return ID;
}

- (nullable __kindof DIMUser *)userWithID:(DIMID *)ID {
    NSAssert(MKMNetwork_IsUser(ID.type), @"user ID error: %@", ID);
    // get from user cache
    return [_userTable objectForKey:ID];
}

- (nullable __kindof DIMGroup *)groupWithID:(DIMID *)ID {
    NSAssert(MKMNetwork_IsGroup(ID.type), @"group ID error: %@", ID);
    // get from group cache
    return [_groupTable objectForKey:ID];
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
    if (!meta) {
        // failed to get meta
        return nil;
    }
    // check and cache it
    if (![self cacheMeta:meta forID:ID]) {
        NSAssert(false, @"failed to cache meta: %@ -> %@", ID, meta);
        return nil;
    }
    return meta;
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

- (nullable __kindof DIMProfile *)profileForID:(DIMID *)ID {
    NSAssert(_entityDataSource, @"entity data source not set");
    return [_entityDataSource profileForID:ID];
}

#pragma mark - DIMUserDataSource

- (nullable DIMPrivateKey *)privateKeyForSignatureOfUser:(DIMID *)user {
    NSAssert(MKMNetwork_IsPerson(user.type), @"user error: %@", user);
    NSAssert(_userDataSource, @"user data source not set");
    return [_userDataSource privateKeyForSignatureOfUser:user];
}

- (nullable NSArray<DIMPrivateKey *> *)privateKeysForDecryptionOfUser:(DIMID *)user {
    NSAssert(MKMNetwork_IsPerson(user.type), @"user error: %@", user);
    NSAssert(_userDataSource, @"user data source not set");
    return [_userDataSource privateKeysForDecryptionOfUser:user];
}

- (nullable NSArray<DIMID *> *)contactsOfUser:(DIMID *)user {
    NSAssert(MKMNetwork_IsPerson(user.type), @"user error: %@", user);
    NSAssert(_userDataSource, @"user data source not set");
    return [_userDataSource contactsOfUser:user];
}

#pragma mark - DIMGroupDataSource

- (nullable DIMID *)founderOfGroup:(DIMID *)group {
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

- (nullable NSArray<DIMID *> *)membersOfGroup:(DIMID *)group {
    NSAssert(MKMNetwork_IsGroup(group.type), @"group error: %@", group);
    NSAssert(_groupDataSource, @"group data source not set");
    return [_groupDataSource membersOfGroup:group];
}

@end
