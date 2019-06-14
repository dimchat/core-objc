//
//  DIMBarrack.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"
#import "NSDictionary+Binary.h"

#import "DIMBarrack.h"

static inline NSString *document_directory(void) {
    NSArray *paths;
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                NSUserDomainMask, YES);
    return paths.firstObject;
}

static inline void make_dirs(NSString *dir) {
    // check base directory exists
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:dir isDirectory:nil]) {
        NSError *error = nil;
        // make sure directory exists
        [fm createDirectoryAtPath:dir withIntermediateDirectories:YES
                       attributes:nil error:&error];
        assert(!error);
    }
}

static inline BOOL file_exists(NSString *path) {
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm fileExistsAtPath:path];
}

// default: "Documents/.mkm"
static NSString *s_directory = nil;
static inline NSString *base_directory(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (s_directory == nil) {
            NSString *dir = document_directory();
            dir = [dir stringByAppendingPathComponent:@".mkm"];
            s_directory = dir;
        }
    });
    return s_directory;
}

/**
 Get meta filepath in Documents Directory
 
 @param ID - entity ID
 @return "Documents/.mkm/{address}/meta.plist"
 */
static inline NSString *meta_filepath(const DIMID *ID, BOOL autoCreate) {
    NSString *dir = base_directory();
    dir = [dir stringByAppendingPathComponent:(NSString *)ID.address];
    // check base directory exists
    if (autoCreate && !file_exists(dir)) {
        // make sure directory exists
        make_dirs(dir);
    }
    return [dir stringByAppendingPathComponent:@"meta.plist"];
}

#pragma mark -

typedef NSMutableDictionary<const DIMAddress *, const DIMMeta *> MetaTableM;

typedef NSMutableDictionary<const DIMAddress *, DIMAccount *> AccountTableM;
typedef NSMutableDictionary<const DIMAddress *, DIMUser *> UserTableM;
typedef NSMutableDictionary<const DIMAddress *, DIMGroup *> GroupTableM;

@interface DIMBarrack () {
    
    MetaTableM *_metaTable;
    
    AccountTableM *_accountTable;
    UserTableM *_userTable;
    GroupTableM *_groupTable;
}

// default "Documents/.mkm/{address}/meta.plist"
- (nullable const DIMMeta *)loadMetaForID:(const DIMID *)ID;

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

SingletonImplementations(DIMBarrack, sharedInstance)

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

- (void)addAccount:(DIMAccount *)account {
    if ([account isKindOfClass:[DIMUser class]]) {
        // add to user table
        [self addUser:(DIMUser *)account];
    } else if (account.ID.isValid) {
        if (account.dataSource == nil) {
            account.dataSource = self;
        }
        [_accountTable setObject:account forKey:account.ID.address];
    }
}

- (void)addUser:(DIMUser *)user {
    if (user.ID.isValid) {
        if (user.dataSource == nil) {
            user.dataSource = self;
        }
        const DIMAddress *key = user.ID.address;
        [_userTable setObject:user forKey:key];
        // erase from account table
        if ([_accountTable objectForKey:key]) {
            [_accountTable removeObjectForKey:key];
        }
    }
}

- (void)addGroup:(DIMGroup *)group {
    if (group.ID.isValid) {
        if (group.dataSource == nil) {
            group.dataSource = self;
        }
        [_groupTable setObject:group forKey:group.ID.address];
    }
}

- (nullable const DIMMeta *)loadMetaForID:(const DIMID *)ID {
    NSString *path = meta_filepath(ID, NO);
    if (file_exists(path)) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        return [[DIMMeta alloc] initWithDictionary:dict];
    }
    return nil;
}

#pragma mark DIMBarrackDelegate

- (BOOL)saveMeta:(const MKMMeta *)meta forID:(const MKMID *)ID {
    
    // (a) check meta with ID
    if ([meta matchID:ID]) {
        [_metaTable setObject:meta forKey:ID.address];
    } else {
        NSAssert(false, @"meta not match ID:%@, %@", ID, meta);
        return NO;
    }
    
    // (b) save by delegate
    if ([_delegate saveMeta:meta forID:ID]) {
        return YES;
    }
    
    // default "Documents/.mkm/{address}/meta.plist"
    NSString *path = meta_filepath(ID, YES);
    if (file_exists(path)) {
        NSLog(@"meta file already exists: %@, IGNORE!", path);
        return YES;
    }
    
    // (c) save to local storage
    return [meta writeToBinaryFile:path];
}

- (nullable DIMAccount *)accountWithID:(const DIMID *)ID {
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
        [self addAccount:account];
        return account;
    }
    
    // (d) create it directly
    account = [[DIMAccount alloc] initWithID:ID];
    [self addAccount:account];
    return account;
}

- (nullable DIMUser *)userWithID:(const DIMID *)ID {
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
        [self addUser:user];
        return user;
    }
    
    // (c) create it directly
    user = [[DIMUser alloc] initWithID:ID];
    [self addUser:user];
    return user;
}

- (nullable DIMGroup *)groupWithID:(const DIMID *)ID {
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
        [self addGroup:group];
        return group;
    }
    
    // (c) create directly
    group = [[DIMGroup alloc] initWithID:ID];
    [self addGroup:group];
    return group;
}

#pragma mark - DIMEntityDataSource

- (nullable const DIMMeta *)metaForID:(const DIMID *)ID {
    const DIMMeta *meta;
    
    // (a) get from meta cache
    meta = [_metaTable objectForKey:ID.address];
    if (meta) {
        return meta;
    }
    
    // (b) get from entity data source
    meta = [_entityDataSource metaForID:ID];
    if ([meta matchID:ID]) {
        [_metaTable setObject:meta forKey:ID.address];
        return meta;
    }
    
    // (c) get from local storage
    meta = [self loadMetaForID:ID];
    if (meta) {
        [_metaTable setObject:meta forKey:ID.address];
    }
    //NSAssert(meta, @"failed to get meta for ID: %@", ID);
    return meta;
}

- (DIMProfile *)profileForID:(const DIMID *)ID {
    DIMProfile *profile = [_entityDataSource profileForID:ID];
    //NSAssert(profile, @"failed to get profile for ID: %@", ID);
    return profile;
}

#pragma mark - DIMUserDataSource

- (DIMPrivateKey *)privateKeyForSignatureOfUser:(const DIMID *)user {
    NSAssert(MKMNetwork_IsPerson(user.type), @"user error: %@", user);
    NSAssert(_userDataSource, @"user data source not set");
    return [_userDataSource privateKeyForSignatureOfUser:user];
}

- (NSArray<DIMPrivateKey *> *)privateKeysForDecryptionOfUser:(const DIMID *)user {
    NSAssert(MKMNetwork_IsPerson(user.type), @"user error: %@", user);
    NSAssert(_userDataSource, @"user data source not set");
    return [_userDataSource privateKeysForDecryptionOfUser:user];
}

- (NSArray<const DIMID *> *)contactsOfUser:(const DIMID *)user {
    NSAssert(MKMNetwork_IsPerson(user.type), @"user error: %@", user);
    NSAssert(_userDataSource, @"user data source not set");
    return [_userDataSource contactsOfUser:user];
}

#pragma mark - DIMGroupDataSource

- (const DIMID *)founderOfGroup:(const DIMID *)group {
    NSAssert(MKMNetwork_IsGroup(group.type), @"group error: %@", group);
    NSAssert(_groupDataSource, @"group data source not set");
    return [_groupDataSource founderOfGroup:group];
}

- (nullable const DIMID *)ownerOfGroup:(const DIMID *)group {
    NSAssert(MKMNetwork_IsGroup(group.type), @"group error: %@", group);
    NSAssert(_groupDataSource, @"group data source not set");
    return [_groupDataSource ownerOfGroup:group];
}

- (NSArray<const DIMID *> *)membersOfGroup:(const DIMID *)group {
    NSAssert(MKMNetwork_IsGroup(group.type), @"group error: %@", group);
    NSAssert(_groupDataSource, @"group data source not set");
    return [_groupDataSource membersOfGroup:group];
}

@end
