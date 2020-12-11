// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2018 Albert Moky
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

typedef NSMutableDictionary<NSString *, MKMUser *> UserTableM;
typedef NSMutableDictionary<NSString *, MKMGroup *> GroupTableM;

@interface DIMBarrack () {
    
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
        _userTable = [[UserTableM alloc] init];
        _groupTable = [[GroupTableM alloc] init];
    }
    return self;
}

- (NSInteger)reduceMemory {
    NSInteger finger = 0;
    finger = thanos(_userTable, finger);
    finger = thanos(_groupTable, finger);
    return finger >> 1;
}

- (void)cacheUser:(MKMUser *)user {
    if (user.dataSource == nil) {
        user.dataSource = self;
    }
    [_userTable setObject:user forKey:user.ID.string];
}

- (void)cacheGroup:(MKMGroup *)group {
    if (group.dataSource == nil) {
        group.dataSource = self;
    }
    [_groupTable setObject:group forKey:group.ID.string];
}

- (nullable MKMUser *)createUser:(id<MKMID>)ID {
    NSAssert(false, @"implement me!");
    return nil;
}

- (nullable MKMGroup *)createGroup:(id<MKMID>)ID {
    NSAssert(false, @"implement me!");
    return nil;
}

#pragma mark - DIMEntityDelegate

- (nullable NSArray<MKMUser *> *)localUsers {
    NSAssert(false, @"implement me!");
    return nil;
}

- (nullable MKMUser *)selectLocalUserWithID:(id<MKMID>)receiver {
    NSArray<MKMUser *> *users = self.localUsers;
    if ([users count] == 0) {
        NSAssert(false, @"local users should not be empty");
        return nil;
    } else if (MKMIDIsBroadcast(receiver)) {
        // broadcast message can decrypt by anyone, so just return current user
        return [users firstObject];
    }
    if (MKMIDIsGroup(receiver)) {
        // group message (recipient not designated)
        for (MKMUser *item in users) {
            if ([self group:receiver containsMember:item.ID]) {
                //self.currentUser = item;
                return item;
            }
        }
    } else {
        // 1. personal message
        // 2. split group message
        for (MKMUser *item in users) {
            if ([receiver isEqual:item.ID]) {
                //self.currentUser = item;
                return item;
            }
        }
    }
    NSAssert(false, @"receiver not in local users: %@, %@", receiver, users);
    return nil;
}

- (nullable __kindof MKMUser *)userWithID:(id<MKMID>)ID {
    // 1. get from user cache
    MKMUser *user = [_userTable objectForKey:ID.string];
    if (!user) {
        // 2. create user and cache it
        user = [self createUser:ID];
        if (user) {
            [self cacheUser:user];
        }
    }
    return user;
}

- (nullable __kindof MKMGroup *)groupWithID:(id<MKMID>)ID {
    // 1. get from group cache
    MKMGroup *group = [_groupTable objectForKey:ID.string];
    if (!group) {
        // 2. create group and cache it
        group = [self createGroup:ID];
        if (group) {
            [self cacheGroup:group];
        }
    }
    return group;
}

#pragma mark - MKMEntityDataSource

- (nullable id<MKMMeta>)metaForID:(id<MKMID>)ID {
    NSAssert(false, @"implement me!");
    return nil;
}

- (nullable __kindof id<MKMDocument>)documentForID:(id<MKMID>)ID
                                          withType:(nullable NSString *)type {
    NSAssert(false, @"implement me!");
    return nil;
}

#pragma mark - MKMUserDataSource

- (nullable NSArray<id<MKMID>> *)contactsOfUser:(id<MKMID>)user {
    NSAssert(false, @"implement me!");
    return nil;
}

- (NSArray<id<MKMVerifyKey>> *)publicKeysForVerification:(id<MKMID>)user {
    // return nil to use [visa.key, meta.key]
    return nil;
}

- (NSArray<id<MKMDecryptKey>> *)privateKeysForDecryption:(id<MKMID>)user {
    NSAssert(false, @"implement me!");
    return nil;
}

- (id<MKMSignKey>)privateKeyForSignature:(id<MKMID>)user {
    NSAssert(false, @"implement me!");
    return nil;
}

- (id<MKMSignKey>)privateKeyForVisaSignature:(id<MKMID>)user {
    NSAssert(false, @"implement me!");
    return nil;
}

#pragma mark - MKMGroupDataSource

- (nullable id<MKMID>)founderOfGroup:(id<MKMID>)group {
    // check each member's public key with group meta
    id<MKMMeta> gMeta = [self metaForID:group];
    if (!gMeta) {
        // FIXME: when group profile was arrived but the meta still on the way,
        //        here will cause founder not found.
        //NSAssert(false, @"failed to get group meta");
        return nil;
    }
    NSArray<id<MKMID>> *members = [self membersOfGroup:group];
    id<MKMMeta> mMeta;
    for (id<MKMID> item in members) {
        mMeta = [self metaForID:item];
        if (!mMeta) {
            // failed to get member meta
            continue;
        }
        if ([mMeta matchPublicKey:gMeta.key]) {
            // if the member's public key matches with the group's meta,
            // it means this meta was generated by the member's private key
            return item;
        }
    }
    // TODO: load founder from database
    return nil;
}

- (nullable id<MKMID>)ownerOfGroup:(id<MKMID>)group {
    // check group type
    if (group.type == MKMNetwork_Polylogue) {
        // Polylogue's owner is its founder
        return [self founderOfGroup:group];
    }
    // TODO: load owner from database
    return nil;
}

- (nullable NSArray<id<MKMID>> *)membersOfGroup:(id<MKMID>)group {
    NSAssert(false, @"implement me!");
    return nil;
}

@end

@implementation DIMBarrack (Relationship)

- (BOOL)group:(id<MKMID>)group isFounder:(id<MKMID>)member {
    // check member's public key with group's meta.key
    id<MKMMeta> gMeta = [self metaForID:group];
    NSAssert(gMeta, @"failed to get meta for group: %@", group);
    id<MKMMeta> mMeta = [self metaForID:member];
    //NSAssert(mMeta, @"failed to get meta for member: %@", member);
    return [gMeta matchPublicKey:mMeta.key];
}

- (BOOL)group:(id<MKMID>)group isOwner:(id<MKMID>)member {
    if (group.type == MKMNetwork_Polylogue) {
        return [self group:group isFounder:member];
    }
    NSAssert(false, @"only Polylogue so far: %@", group);
    return NO;
}

- (BOOL)group:(id<MKMID>)group containsMember:(id<MKMID>)member {
    NSArray<id<MKMID>> *members = [self membersOfGroup:group];
    return [members containsObject:member];
}

#pragma mark Group Assistants

- (nullable NSArray<id<MKMID>> *)assistantsOfGroup:(id<MKMID>)group {
    NSAssert(false, @"implement me!");
    return nil;
}

- (BOOL)group:(id<MKMID>)group containsAssistant:(id<MKMID>)assistant {
    NSArray<id<MKMID>> *assistants = [self assistantsOfGroup:group];
    return [assistants containsObject:assistant];
}

@end
