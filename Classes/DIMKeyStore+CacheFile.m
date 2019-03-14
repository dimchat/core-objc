//
//  DIMKeyStore+CacheFile.m
//  DIMCore
//
//  Created by Albert Moky on 2019/1/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSDictionary+Binary.h"

#import "DIMKeyStore+CacheFile.h"

#define DIM_KEYSTORE_ACCOUNTS_FILENAME @"keystore_accounts.plist"
#define DIM_KEYSTORE_GROUPS_FILENAME   @"keystore_groups.plist"

@interface DIMKeyStore ()

@property (strong, nonatomic) NSMutableDictionary *keysForAccounts;
@property (strong, nonatomic) NSMutableDictionary *keysFromAccounts;

@property (strong, nonatomic) NSMutableDictionary *keysForGroups;
@property (strong, nonatomic) NSMutableDictionary *tablesFromGroups;

@property (nonatomic, getter=isDirty) BOOL dirty;

@end

@implementation DIMKeyStore (CacheFile)

static NSString *s_directory = nil;

// "Library/Caches/.ks"
- (NSString *)directory {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *paths;
        paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                    NSUserDomainMask, YES);
        NSString *dir = paths.firstObject;
        s_directory = [dir stringByAppendingPathComponent:@".ks"];
    });
    return s_directory;
}

- (void)setDirectory:(NSString *)directory {
    s_directory = directory;
}

// "Library/Caches/.ks/{address}/keystore_*.plist"
- (NSString *)_pathWithID:(const DIMID *)ID filename:(NSString *)name {
    NSString *dir = self.directory;
    dir = [dir stringByAppendingPathComponent:(NSString *)ID.address];
    
    // check base directory exists
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:dir isDirectory:nil]) {
        NSError *error = nil;
        // make sure directory exists
        [fm createDirectoryAtPath:dir withIntermediateDirectories:YES
                       attributes:nil error:&error];
        assert(!error);
    }
    
    return [dir stringByAppendingPathComponent:name];
}

- (BOOL)flush {
    if (!self.dirty) {
        // nothing changed
        return NO;
    }
    const DIMID *ID = self.currentUser.ID;
    if (!ID.isValid) {
        NSAssert(self.currentUser == nil, @"Current user invalid: %@", self.currentUser);
        return NO;
    }
    
    NSString *path;
    
    // keys from contacts
    path = [self _pathWithID:ID filename:DIM_KEYSTORE_ACCOUNTS_FILENAME];
    BOOL OK1 = [self.keysFromAccounts writeToBinaryFile:path];
    
    // keys from group.members
    path = [self _pathWithID:ID filename:DIM_KEYSTORE_GROUPS_FILENAME];
    BOOL OK2 = [self.tablesFromGroups writeToBinaryFile:path];
    
    self.dirty = NO;
    return OK1 && OK2;
}

- (BOOL)reload {
    const DIMID *ID = self.currentUser.ID;
    if (!ID.isValid) {
        NSAssert(self.currentUser == nil, @"Current user invalid: %@", self.currentUser);
        return NO;
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path;
    
    NSDictionary *dict;
    id cKey;
    id obj;
    DIMAddress *address;
    DIMSymmetricKey *PW;
    
    BOOL changed = NO;
    BOOL isDirty = self.dirty; // save old flag
    
    // keys from contacts
    path = [self _pathWithID:ID filename:DIM_KEYSTORE_ACCOUNTS_FILENAME];
    if ([fm fileExistsAtPath:path]) {
        // load keys from contacts
        dict = [NSDictionary dictionaryWithContentsOfFile:path];
        for (cKey in dict) {
            // Address
            address = [DIMAddress addressWithAddress:cKey];
            NSAssert(MKMNetwork_IsCommunicator(address.network), @"account address error: %@", address);
            // key
            obj = [dict objectForKey:cKey];
            PW = [DIMSymmetricKey keyWithKey:obj];
            // update keys table
            [self.keysFromAccounts setObject:PW forKey:address];
        }
        changed = YES;
    }
    
    id gKey, mKey;
    DIMAddress *gAddr, *mAddr;
    NSMutableDictionary *gTable, *mTable;
    
    // keys from group.members
    path = [self _pathWithID:ID filename:DIM_KEYSTORE_GROUPS_FILENAME];
    if ([fm fileExistsAtPath:path]) {
        // load keys from group.members
        dict = [NSDictionary dictionaryWithContentsOfFile:path];
        for (gKey in dict) {
            // group ID.address
            gAddr = [DIMAddress addressWithAddress:gKey];
            NSAssert(MKMNetwork_IsGroup(gAddr.network), @"group address error: %@", gAddr);
            // table
            gTable = [dict objectForKey:gKey];
            for (mKey in gTable) {
                // member ID.address
                mAddr = [DIMAddress addressWithAddress:mKey];
                NSAssert(MKMNetwork_IsCommunicator(mAddr.network), @"member address error: %@", mAddr);
                // key
                obj = [gTable objectForKey:mKey];
                PW = [DIMSymmetricKey keyWithKey:obj];
                // update keys table
                mTable = [self.tablesFromGroups objectForKey:gAddr];
                if (!mTable) {
                    mTable = [[NSMutableDictionary alloc] init];
                    [self.tablesFromGroups setObject:mTable forKey:gAddr];
                }
                [mTable setObject:PW forKey:mAddr];
            }
        }
        changed = YES;
    }
    
    self.dirty = isDirty; // restore the flag
    return changed;
}

@end
