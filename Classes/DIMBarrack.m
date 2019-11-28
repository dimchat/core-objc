// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// =============================================================================
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
    
    IDTableM *_idTable;
    MetaTableM *_metaTable;
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
        _idTable = [[IDTableM alloc] init];
        _metaTable = [[MetaTableM alloc] init];
        _userTable = [[UserTableM alloc] init];
        _groupTable = [[GroupTableM alloc] init];
    }
    return self;
}

- (NSInteger)reduceMemory {
    NSInteger finger = 0;
    finger = thanos(_idTable, finger);
    finger = thanos(_metaTable, finger);
    finger = thanos(_userTable, finger);
    finger = thanos(_groupTable, finger);
    return finger >> 1;
}

- (BOOL)cacheMeta:(DIMMeta *)meta forID:(DIMID *)ID {
    NSAssert([meta matchID:ID], @"meta not match ID: %@, %@", ID, meta);
    [_metaTable setObject:meta forKey:ID];
    return YES;
}

- (BOOL)cacheID:(DIMID *)ID {
    NSAssert([ID isValid], @"ID not valid: %@", ID);
    [_idTable setObject:ID forKey:ID];
    return YES;
}

- (BOOL)cacheUser:(DIMUser *)user {
    NSAssert(MKMNetwork_IsUser(user.ID.type), @"user ID error: %@", user.ID);
    if (user.dataSource == nil) {
        user.dataSource = self;
    }
    [_userTable setObject:user forKey:user.ID];
    return YES;
}

- (BOOL)cacheGroup:(DIMGroup *)group {
    NSAssert(MKMNetwork_IsGroup(group.ID.type), @"group ID error: %@", group.ID);
    if (group.dataSource == nil) {
        group.dataSource = self;
    }
    [_groupTable setObject:group forKey:group.ID];
    return YES;
}

- (DIMID *)createID:(NSString *)string {
    NSAssert(string, @"ID error");
    return MKMIDFromString(string);
}

- (DIMUser *)createUser:(DIMID *)ID {
    NSAssert(MKMNetwork_IsUser(ID.type), @"user ID error: %@", ID);
    if ([ID isBroadcast]) {
        // create user 'anyone@anywhere'
        return [[DIMUser alloc] initWithID:ID];
    }
    NSAssert([self metaForID:ID], @"failed to get meta for user: %@", ID);
    // TODO: check user type
    return [[DIMUser alloc] initWithID:ID];
}

- (DIMGroup *)createGroup:(DIMID *)ID {
    NSAssert(MKMNetwork_IsGroup(ID.type), @"group ID error: %@", ID);
    if ([ID isBroadcast]) {
        // create group 'everyone@everywhere'
        return [[DIMGroup alloc] initWithID:ID];
    }
    NSAssert([self metaForID:ID], @"failed to get meta for group: %@", ID);
    // TODO: check group type
    return [[DIMGroup alloc] initWithID:ID];
}

#pragma mark - DIMSocialNetworkDataSource

- (nullable DIMID *)IDWithString:(NSString *)string {
    if (!string) {
        return nil;
    } else if ([string isKindOfClass:[DIMID class]]) {
        return (DIMID *)string;
    }
    // 1. get from ID cache
    DIMID *ID = [_idTable objectForKey:string];
    if (ID) {
        return ID;
    }
    // 2. create and cache it
    ID = [self createID:string];
    if (ID && [self cacheID:ID]) {
        return ID;
    }
    NSAssert(false, @"failed to create ID: %@", string);
    return nil;
}

- (nullable __kindof DIMUser *)userWithID:(DIMID *)ID {
    // 1. get from user cache
    DIMUser *user = [_userTable objectForKey:ID];
    if (user) {
        return user;
    }
    // 2. create user and cache it
    user = [self createUser:ID];
    if (user && [self cacheUser:user]) {
        return user;
    }
    NSAssert(false, @"failed to create user: %@", ID);
    return nil;
}

- (nullable __kindof DIMGroup *)groupWithID:(DIMID *)ID {
    // 1. get from group cache
    DIMGroup *group = [_groupTable objectForKey:ID];
    if (group) {
        return group;
    }
    // 2. create group and cache it
    group = [self createGroup:ID];
    if (group && [self cacheGroup:group]) {
        return group;
    }
    NSAssert(false, @"failed to create group: %@", ID);
    return nil;
}

#pragma mark - MKMEntityDataSource

- (nullable DIMMeta *)metaForID:(DIMID *)ID {
    NSAssert([ID isValid], @"ID not valid: %@", ID);
    return [_metaTable objectForKey:ID];
}

- (nullable __kindof DIMProfile *)profileForID:(DIMID *)ID {
    NSAssert(false, @"override me!");
    return nil;
}

#pragma mark - MKMUserDataSource

- (nullable NSArray<DIMID *> *)contactsOfUser:(DIMID *)user {
    NSAssert(false, @"override me!");
    return nil;
}

- (nullable id<MKMEncryptKey>)publicKeyForEncryption:(nonnull DIMID *)user {
    NSAssert(MKMNetwork_IsUser(user.type), @"user ID error: %@", user);
    // NOTICE: return nothing to use profile.key or meta.key
    return nil;
}

- (nullable NSArray<DIMPrivateKey *> *)privateKeysForDecryptionOfUser:(DIMID *)user {
    NSAssert(false, @"override me!");
    return nil;
}

- (nullable DIMPrivateKey *)privateKeyForSignatureOfUser:(DIMID *)user {
    NSAssert(false, @"override me!");
    return nil;
}

- (nullable NSArray<id<MKMVerifyKey>> *)publicKeysForVerification:(nonnull DIMID *)user {
    NSAssert(MKMNetwork_IsUser(user.type), @"user ID error: %@", user);
    // NOTICE: return nothing to use meta.key
    return nil;
}

#pragma mark - MKMGroupDataSource

- (nullable DIMID *)founderOfGroup:(DIMID *)group {
    NSAssert(MKMNetwork_IsGroup(group.type), @"group ID error: %@", group);
    // check for broadcast
    if ([group isBroadcast]) {
        NSString *founder;
        NSString *name = [group name];
        NSUInteger len = [name length];
        if (len == 0 || (len == 8 && [name isEqualToString:@"everyone"])) {
            // Consensus: the founder of group 'everyone@everywhere'
            //            'Albert Moky'
            founder = @"moky@anywhere";
        } else {
            // DISCUSS: who should be the founder of group 'xxx@everywhere'?
            //          'anyone@anywhere', or 'xxx.founder@anywhere'
            founder = [name stringByAppendingString:@".founder@anywhere"];
        }
        return [self IDWithString:founder];
    }
    return nil;
}

- (nullable DIMID *)ownerOfGroup:(DIMID *)group {
    NSAssert(MKMNetwork_IsGroup(group.type), @"group ID error: %@", group);
    // check for broadcast
    if ([group isBroadcast]) {
        NSString *owner;
        NSString *name = [group name];
        NSUInteger len = [name length];
        if (len == 0 || (len == 8 && [name isEqualToString:@"everyone"])) {
            // Consensus: the owner of group 'everyone@everywhere'
            //            'anyone@anywhere'
            owner = @"anyone@anywhere";
        } else {
            // DISCUSS: who should be the owner of group 'xxx@everywhere'?
            //          'anyone@anywhere', or 'xxx.owner@anywhere'
            owner = [name stringByAppendingString:@".owner@anywhere"];
        }
        return [self IDWithString:owner];
    }
    return nil;
}

- (nullable NSArray<DIMID *> *)membersOfGroup:(DIMID *)group {
    NSAssert(MKMNetwork_IsGroup(group.type), @"group ID error: %@", group);
    // check for broadcast
    if ([group isBroadcast]) {
        NSString *member;
        NSString *name = [group name];
        NSUInteger len = [name length];
        if (len == 0 || (len == 8 && [name isEqualToString:@"everyone"])) {
            // Consensus: the member of group 'everyone@everywhere'
            //            'anyone@anywhere'
            member = @"anyone@anywhere";
        } else {
            // DISCUSS: who should be the member of group 'xxx@everywhere'?
            //          'anyone@anywhere', or 'xxx.member@anywhere'
            member = [name stringByAppendingString:@".member@anywhere"];
        }
        DIMID *ID = [self IDWithString:member];
        DIMID *owner = [self ownerOfGroup:group];
        if ([ID isEqual:owner]) {
            return [[NSArray alloc] initWithObjects:owner, nil];
        } else {
            return [[NSArray alloc] initWithObjects:owner, ID, nil];
        }
    }
    return nil;
}

@end
