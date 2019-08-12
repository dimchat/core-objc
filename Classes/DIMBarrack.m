//
//  DIMBarrack.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSDate+Timestamp.h"

#import "DIMBarrack.h"

typedef NSMutableDictionary<DIMID *, DIMMeta *> MetaTableM;
typedef NSMutableDictionary<DIMID *, DIMProfile *> ProfileTableM;

typedef NSMutableDictionary<NSString *, DIMID *> IDTableM;
typedef NSMutableDictionary<DIMID *, DIMUser *> UserTableM;
typedef NSMutableDictionary<DIMID *, DIMGroup *> GroupTableM;

@interface DIMBarrack () {
    
    MetaTableM *_metaTable;
    ProfileTableM *_profileTable;
    
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
        if ((++finger & 1) == 1) {
            // kill it
            [mDict removeObjectForKey:addr];
        }
        // let it go
    }
    return finger;
}

@implementation DIMBarrack

- (instancetype)init {
    if (self = [super init]) {
        _metaTable = [[MetaTableM alloc] init];
        _profileTable = [[ProfileTableM alloc] init];
        
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
    finger = thanos(_profileTable, finger);
    finger = thanos(_idTable, finger);
    finger = thanos(_userTable, finger);
    finger = thanos(_groupTable, finger);
    return finger >> 1;
}

- (BOOL)_verifyProfile:(DIMProfile *)profile {
    if (!profile) {
        return NO;
    } else if ([profile isValid]) {
        // already verified
        return YES;
    }
    DIMID *ID = profile.ID;
    NSAssert([ID isValid], @"profile ID not valid: %@", profile);
    DIMMeta *meta = nil;
    // check signer
    if (MKMNetwork_IsUser(ID.type)) {
        // verify with user's meta.key
        meta = [self metaForID:ID];
    } else if (MKMNetwork_IsGroup(ID.type)) {
        // verify with group owner's meta.key
        DIMGroup *group = [self groupWithID:ID];
        DIMID *owner = group.owner;
        if ([owner isValid]) {
            meta = [self metaForID:owner];
        }
    }
    return [profile verify:meta.key];
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

- (BOOL)cacheProfile:(DIMProfile *)profile {
    if (![self _verifyProfile:profile]) {
        NSAssert(false, @"profile not valid: %@", profile);
        return NO;
    }
    // set last update time
    NSDate *now = [[NSDate alloc] init];
    [profile setObject:NSNumberFromDate(now) forKey:@"lastTime"];
    [_profileTable setObject:profile forKey:profile.ID];
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

#pragma mark - DIMSocialNetworkDataSource

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

- (BOOL)saveMeta:(DIMMeta *)meta forID:(DIMID *)ID {
    if (![self cacheMeta:meta forID:ID]) {
        NSAssert(false, @"meta not match ID: %@, %@", ID, meta);
        return NO;
    }
    // try saving it by delegate
    return [_entityDataSource saveMeta:meta forID:ID];
}

- (BOOL)saveProfile:(MKMProfile *)profile {
    if (![self cacheProfile:profile]) {
        NSAssert(false, @"profile invalid: %@", profile);
        return NO;
    }
    return [_entityDataSource saveProfile:profile];
}

#pragma mark - MKMEntityDataSource

- (nullable DIMMeta *)metaForID:(DIMID *)ID {
    // get from meta cache
    DIMMeta *meta = [_metaTable objectForKey:ID];
    if (meta) {
        return meta;
    }
    // get from entity data source
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

- (nullable __kindof DIMProfile *)profileForID:(DIMID *)ID {
    // get from profile cache
    DIMProfile *profile = [_profileTable objectForKey:ID];
    NSNumber *timestamp = [profile objectForKey:@"lastTime"];
    if (timestamp != nil) {
        NSDate *lastTime = NSDateFromNumber(timestamp);
        NSTimeInterval ti = [lastTime timeIntervalSinceNow];
        if (fabs(ti) < 3600) {
            // not expired yet
            return profile;
        }
        NSLog(@"profile expired: %@", lastTime);
        [_profileTable removeObjectForKey:ID];
    }
    // get from entity data source
    profile = [_entityDataSource profileForID:ID];
    // check and cache it
    if (!profile || ![self cacheProfile:profile]) {
        // place an empty profile for cache
        profile = [[DIMProfile alloc] initWithID:ID];
        // set last update time
        NSDate *now = [[NSDate alloc] init];
        [profile setObject:NSNumberFromDate(now) forKey:@"lastTime"];
        [_profileTable setObject:profile forKey:profile.ID];
        return nil;
    }
    return profile;
}

#pragma mark - MKMUserDataSource

- (nullable DIMPrivateKey *)privateKeyForSignatureOfUser:(DIMID *)user {
    NSAssert(MKMNetwork_IsPerson(user.type), @"user error: %@", user);
    return [_userDataSource privateKeyForSignatureOfUser:user];
}

- (nullable NSArray<DIMPrivateKey *> *)privateKeysForDecryptionOfUser:(DIMID *)user {
    NSAssert(MKMNetwork_IsPerson(user.type), @"user error: %@", user);
    return [_userDataSource privateKeysForDecryptionOfUser:user];
}

- (nullable NSArray<DIMID *> *)contactsOfUser:(DIMID *)user {
    NSAssert(MKMNetwork_IsPerson(user.type), @"user error: %@", user);
    return [_userDataSource contactsOfUser:user];
}

#pragma mark - MKMGroupDataSource

- (nullable DIMID *)founderOfGroup:(DIMID *)group {
    NSAssert(MKMNetwork_IsGroup(group.type), @"group error: %@", group);
    return [_groupDataSource founderOfGroup:group];
}

- (nullable DIMID *)ownerOfGroup:(DIMID *)group {
    NSAssert(MKMNetwork_IsGroup(group.type), @"group error: %@", group);
    return [_groupDataSource ownerOfGroup:group];
}

- (nullable NSArray<DIMID *> *)membersOfGroup:(DIMID *)group {
    NSAssert(MKMNetwork_IsGroup(group.type), @"group error: %@", group);
    return [_groupDataSource membersOfGroup:group];
}

@end
