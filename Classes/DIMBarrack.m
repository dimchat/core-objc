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

typedef NSMutableDictionary<const DIMAddress *, DIMAccount *> AccountTableM;
typedef NSMutableDictionary<const DIMAddress *, DIMUser *> UserTableM;

typedef NSMutableDictionary<const DIMAddress *, DIMGroup *> GroupTableM;
typedef NSMutableDictionary<const DIMAddress *, DIMMember *> MemberTableM;
typedef NSMutableDictionary<const DIMAddress *, MemberTableM *> GroupMemberTableM;

typedef NSMutableDictionary<const DIMAddress *, const DIMMeta *> MetaTableM;

@interface DIMBarrack () {
    
    AccountTableM *_accountTable;
    UserTableM *_userTable;
    
    GroupTableM *_groupTable;
    GroupMemberTableM *_groupMemberTable;
    
    MetaTableM *_metaTable;
}

// default "Documents/.mkm/{address}/meta.plist"
- (nullable const DIMMeta *)loadMetaForID:(const DIMID *)ID;

@end

/**
 Remove 1/2 objects from the dictionary
 
 @param mDict - mutable dictionary
 */
static inline void reduce_table(NSMutableDictionary *mDict) {
    NSArray *keys = [mDict allKeys];
    DIMAddress *addr;
    for (NSUInteger index = 0; index < keys.count; index += 2) {
        addr = [keys objectAtIndex:index];
        [mDict removeObjectForKey:addr];
    }
}

@implementation DIMBarrack

SingletonImplementations(DIMBarrack, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        _accountTable = [[AccountTableM alloc] init];
        _userTable = [[UserTableM alloc] init];
        
        _groupTable = [[GroupTableM alloc] init];
        _groupMemberTable = [[GroupMemberTableM alloc] init];
        
        _metaTable = [[MetaTableM alloc] init];
        
        // delegates
        _accountDelegate = nil;
        _userDataSource = nil;
        _userDelegate = nil;
        
        _groupDataSource = nil;
        _groupDelegate = nil;
        _memberDelegate = nil;
        _chatroomDataSource = nil;
        
        _entityDataSource = nil;
        _profileDataSource = nil;
    }
    return self;
}

- (void)reduceMemory {
    reduce_table(_accountTable);
    reduce_table(_userTable);
    
    reduce_table(_groupTable);
    reduce_table(_groupMemberTable);
    
    reduce_table(_metaTable);
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

- (void)addMember:(DIMMember *)member {
    const DIMID *groupID = member.groupID;
    if (groupID.isValid && member.ID.isValid) {
        if (member.dataSource == nil) {
            member.dataSource = self;
        }
        
        MemberTableM *table;
        table = [_groupMemberTable objectForKey:groupID.address];
        if (!table) {
            table = [[MemberTableM alloc] init];
            [_groupMemberTable setObject:table forKey:groupID.address];
        }
        [table setObject:member forKey:member.ID.address];
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

#pragma mark - DIMMetaDataSource

- (nullable const DIMMeta *)metaForID:(const DIMID *)ID {
    const DIMMeta *meta;
    
    // (a) get from meta cache
    meta = [_metaTable objectForKey:ID.address];
    if (meta) {
        return meta;
    }
    
    do {
        // (b) get from meta data source
        NSAssert(_metaDataSource, @"meta data source not set");
        meta = [_metaDataSource metaForID:ID];
        if (meta) {
            break;
        }
        
        // (c) get from local storage
        meta = [self loadMetaForID:ID];
        if (meta) {
            break;
        }
        
        break;
    } while (YES);
    
    // (d) cache it
    if ([meta matchID:ID]) {
        [_metaTable setObject:meta forKey:ID.address];
    } else {
        NSAssert(meta == nil, @"meta error: %@, %@", meta, ID);
        NSLog(@"meta not found: %@", ID);
    }
    return meta;
}

#pragma mark - DIMMetaDelegate

- (BOOL)saveMeta:(const MKMMeta *)meta forID:(const MKMID *)ID {
    
    // (a) check meta with ID
    if ([meta matchID:ID]) {
        [_metaTable setObject:meta forKey:ID.address];
    } else {
        NSAssert(false, @"meta not match ID:%@, %@", ID, meta);
        return NO;
    }
    
    // (b) check meta delegate
    if ([_metaDelegate respondsToSelector:@selector(saveMeta:forID:)]) {
        return [_metaDelegate saveMeta:meta forID:ID];
    }
    
    // default "Documents/.mkm/{address}/meta.plist"
    NSString *path = meta_filepath(ID, YES);
    if (file_exists(path)) {
        NSLog(@"meta file already exists: %@, IGNORE!", path);
        return YES;
    }
    return [meta writeToBinaryFile:path];
}

#pragma mark - DIMEntityDataSource

- (nullable  const DIMMeta *)metaForEntity:(const DIMEntity *)entity {
    const DIMMeta *meta;
    const DIMID *ID = entity.ID;
    
    // (a) call 'metaForID:' of meta data source
    meta = [self metaForID:ID];
    if (meta) {
        return meta;
    }
    
    // (b) check entity data source
    if (![_entityDataSource respondsToSelector:@selector(metaForEntity:)]) {
        // not implement
        return nil;
    }
    
    // (c) get from entity data source
    meta = [_entityDataSource metaForEntity:entity];
    
    // (d) cache it
    if ([meta matchID:ID]) {
        [_metaTable setObject:meta forKey:ID.address];
    } else {
        NSAssert(meta == nil, @"meta error: %@, %@", meta, ID);
        NSLog(@"meta not found: %@", ID);
    }
    return meta;
}

- (NSString *)nameOfEntity:(const DIMEntity *)entity {
    // (a) get from entity data source
    NSString *name = [_entityDataSource nameOfEntity:entity];
    if (name.length > 0) {
        return name;
    }
    
    // (b) get from profile
    DIMProfile *profile = [_profileDataSource profileForID:entity.ID];
    return profile.name;
}

#pragma mark - DIMAccountDelegate

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
    
    // (c) get from account delegate
    NSAssert(_accountDelegate, @"account delegate not set");
    account = [_accountDelegate accountWithID:ID];
    if (account) {
        [self addAccount:account];
        return account;
    }
    
    // (d) create it directly
    account = [[DIMAccount alloc] initWithID:ID];
    [self addAccount:account];
    return account;
}

#pragma mark - DIMUserDataSource

- (NSInteger)numberOfContactsInUser:(const DIMUser *)user {
    NSAssert(MKMNetwork_IsPerson(user.type), @"user error: %@", user);
    NSAssert(_userDataSource, @"user data source not set");
    return [_userDataSource numberOfContactsInUser:user];
}

- (const DIMID *)user:(const DIMUser *)user contactAtIndex:(NSInteger)index {
    NSAssert(MKMNetwork_IsPerson(user.type), @"user error: %@", user);
    NSAssert(_userDataSource, @"user data source not set");
    return [_userDataSource user:user contactAtIndex:index];
}

#pragma mark - DIMUserDelegate

- (nullable DIMUser *)userWithID:(const DIMID *)ID {
    NSAssert(MKMNetwork_IsPerson(ID.type), @"user ID error: %@", ID);
    DIMUser *user;
    
    // (a) get from user cache
    user = [_userTable objectForKey:ID.address];
    if (user) {
        return user;
    }
    
    // (b) get from user delegate
    NSAssert(_userDelegate, @"user delegate not set");
    user = [_userDelegate userWithID:ID];
    if (user) {
        [self addUser:user];
        return user;
    }
    
    // (c) create it directly
    user = [[DIMUser alloc] initWithID:ID];
    [self addUser:user];
    return user;
}

- (BOOL)user:(const DIMUser *)user addContact:(const DIMID *)contact {
    NSAssert(MKMNetwork_IsPerson(user.type), @"user error: %@", user);
    NSAssert(MKMNetwork_IsPerson(contact.type), @"contact error: %@", contact);
    NSAssert(_userDelegate, @"user delegate not set");
    return [_userDelegate user:user addContact:contact];
}

- (BOOL)user:(const DIMUser *)user removeContact:(const DIMID *)contact {
    NSAssert(MKMNetwork_IsPerson(user.type), @"user error: %@", user);
    NSAssert(MKMNetwork_IsPerson(contact.type), @"contact error: %@", contact);
    NSAssert(_userDelegate, @"user delegate not set");
    return [_userDelegate user:user removeContact:contact];
}

#pragma mark DIMGroupDataSource

- (const DIMID *)founderOfGroup:(const DIMGroup *)group {
    NSAssert(MKMNetwork_IsGroup(group.ID.type), @"group error: %@", group);
    NSAssert(_groupDataSource, @"group data source not set");
    return [_groupDataSource founderOfGroup:group];
}

- (nullable const DIMID *)ownerOfGroup:(const DIMGroup *)group {
    NSAssert(MKMNetwork_IsGroup(group.ID.type), @"group error: %@", group);
    NSAssert(_groupDataSource, @"group data source not set");
    return [_groupDataSource ownerOfGroup:group];
}

- (NSInteger)numberOfMembersInGroup:(const DIMGroup *)group {
    NSAssert(MKMNetwork_IsGroup(group.ID.type), @"group error: %@", group);
    NSAssert(_groupDataSource, @"group data source not set");
    return [_groupDataSource numberOfMembersInGroup:group];
}

- (const DIMID *)group:(const DIMGroup *)group memberAtIndex:(NSInteger)index {
    NSAssert(MKMNetwork_IsGroup(group.ID.type), @"group error: %@", group);
    NSAssert(_groupDataSource, @"group data source not set");
    return [_groupDataSource group:group memberAtIndex:index];
}

#pragma mark DIMGroupDelegate

- (nullable DIMGroup *)groupWithID:(const DIMID *)ID {
    NSAssert(MKMNetwork_IsGroup(ID.type), @"group ID error: %@", ID);
    DIMGroup *group;
    
    // (a) get from group cache
    group = [_groupTable objectForKey:ID.address];
    if (group) {
        return group;
    }
    
    // (b) get from group delegate
    NSAssert(_groupDelegate, @"group delegate not set");
    group = [_groupDelegate groupWithID:ID];
    if (group) {
        [self addGroup:group];
        return group;
    }
    
    // (c) create directly
    if (ID.type == MKMNetwork_Polylogue) {
        group = [[DIMPolylogue alloc] initWithID:ID];
    } else if (ID.type == MKMNetwork_Chatroom) {
        group = [[DIMChatroom alloc] initWithID:ID];
    } else {
        NSAssert(false, @"group ID type not support: %d", ID.type);
    }
    [self addGroup:group];
    return group;
}

- (BOOL)group:(const DIMGroup *)group addMember:(const DIMID *)member {
    NSAssert(MKMNetwork_IsGroup(group.ID.type), @"group error: %@", group);
    NSAssert(MKMNetwork_IsCommunicator(member.type), @"member error: %@", member);
    NSAssert(_groupDelegate, @"group delegate not set");
    return [_groupDelegate group:group addMember:member];
}

- (BOOL)group:(const DIMGroup *)group removeMember:(const DIMID *)member {
    NSAssert(MKMNetwork_IsGroup(group.ID.type), @"group error: %@", group);
    NSAssert(MKMNetwork_IsCommunicator(member.type), @"member error: %@", member);
    NSAssert(_groupDelegate, @"group delegate not set");
    return [_groupDelegate group:group removeMember:member];
}

#pragma mark DIMMemberDelegate

- (DIMMember *)memberWithID:(const DIMID *)ID groupID:(const DIMID *)gID {
    NSAssert(MKMNetwork_IsCommunicator(ID.type), @"member ID error: %@", ID);
    NSAssert(MKMNetwork_IsGroup(gID.type), @"group ID error: %@", gID);
    
    MemberTableM *table = [_groupMemberTable objectForKey:gID.address];
    DIMMember *member;
    
    // (a) get from group member cache
    member = [table objectForKey:ID.address];
    if (member) {
        return member;
    }
    
    // (b) get from group member delegate
    NSAssert(_memberDelegate, @"member delegate not set");
    member = [_memberDelegate memberWithID:ID groupID:gID];
    if (member) {
        [self addMember:member];
        return member;
    }
    
    // (c) create directly
    member = [[DIMMember alloc] initWithGroupID:gID accountID:ID];
    [self addMember:member];
    return member;
}
                     
#pragma mark DIMChatroomDataSource

- (NSInteger)numberOfAdminsInChatroom:(const DIMChatroom *)grp {
    NSAssert(grp.ID.type == MKMNetwork_Chatroom, @"not a chatroom: %@", grp);
    NSAssert(_chatroomDataSource, @"chatroom data source not set");
    return [_chatroomDataSource numberOfAdminsInChatroom:grp];
}

- (const DIMID *)chatroom:(const DIMChatroom *)grp adminAtIndex:(NSInteger)index {
    NSAssert(grp.ID.type == MKMNetwork_Chatroom, @"not a chatroom: %@", grp);
    NSAssert(_chatroomDataSource, @"chatroom data source not set");
    return [_chatroomDataSource chatroom:grp adminAtIndex:index];
}

#pragma mark - DIMProfileDataSource

- (DIMProfile *)profileForID:(const DIMID *)ID {
    //NSAssert(_profileDataSource, @"profile data source not set");
    DIMProfile *profile = [_profileDataSource profileForID:ID];
    //NSAssert(profile, @"failed to get profile for ID: %@", ID);
    return profile;
}

@end
