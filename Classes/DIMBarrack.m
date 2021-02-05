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

@interface DIMBarrack () {
    
    NSMutableDictionary<id<MKMID>, DIMUser *> *_userTable;
    NSMutableDictionary<id<MKMID>, DIMGroup *> *_groupTable;
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
        _userTable = [[NSMutableDictionary alloc] init];
        _groupTable = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSInteger)reduceMemory {
    NSInteger finger = 0;
    finger = thanos(_userTable, finger);
    finger = thanos(_groupTable, finger);
    return finger >> 1;
}

- (void)cacheUser:(DIMUser *)user {
    if (user.dataSource == nil) {
        user.dataSource = self;
    }
    [_userTable setObject:user forKey:user.ID];
}

- (void)cacheGroup:(DIMGroup *)group {
    if (group.dataSource == nil) {
        group.dataSource = self;
    }
    [_groupTable setObject:group forKey:group.ID];
}

- (nullable DIMUser *)createUser:(id<MKMID>)ID {
    NSAssert(false, @"implement me!");
    return nil;
}

- (nullable DIMGroup *)createGroup:(id<MKMID>)ID {
    NSAssert(false, @"implement me!");
    return nil;
}

#pragma mark - DIMEntityDelegate

- (nullable NSArray<DIMUser *> *)localUsers {
    NSAssert(false, @"implement me!");
    return nil;
}

- (nullable DIMUser *)selectLocalUserWithID:(id<MKMID>)receiver {
    NSArray<DIMUser *> *users = self.localUsers;
    if ([users count] == 0) {
        NSAssert(false, @"local users should not be empty");
        return nil;
    } else if (MKMIDIsBroadcast(receiver)) {
        // broadcast message can decrypt by anyone, so just return current user
        return [users firstObject];
    }
    if (MKMIDIsGroup(receiver)) {
        // group message (recipient not designated)
        NSArray<id<MKMID>> *members = [self membersOfGroup:receiver];
        if (members.count == 0) {
            // TODO: group not ready, waiting for group info
            return nil;
        }
        for (DIMUser *item in users) {
            if ([members containsObject:item.ID]) {
                // DISCUSS: set this item to be current user?
                return item;
            }
        }
    } else {
        // 1. personal message
        // 2. split group message
        for (DIMUser *item in users) {
            if ([receiver isEqual:item.ID]) {
                // DISCUSS: set this item to be current user?
                return item;
            }
        }
    }
    NSAssert(false, @"receiver not in local users: %@, %@", receiver, users);
    return nil;
}

- (nullable __kindof DIMUser *)userWithID:(id<MKMID>)ID {
    // 1. get from user cache
    DIMUser *user = [_userTable objectForKey:ID];
    if (!user) {
        // 2. create user and cache it
        user = [self createUser:ID];
        if (user) {
            [self cacheUser:user];
        }
    }
    return user;
}

- (nullable __kindof DIMGroup *)groupWithID:(id<MKMID>)ID {
    // 1. get from group cache
    DIMGroup *group = [_groupTable objectForKey:ID];
    if (!group) {
        // 2. create group and cache it
        group = [self createGroup:ID];
        if (group) {
            [self cacheGroup:group];
        }
    }
    return group;
}

#pragma mark - DIMEntityDataSource

- (nullable id<MKMMeta>)metaForID:(id<MKMID>)ID {
    NSAssert(false, @"implement me!");
    return nil;
}

- (nullable __kindof id<MKMDocument>)documentForID:(id<MKMID>)ID
                                              type:(nullable NSString *)type {
    NSAssert(false, @"implement me!");
    return nil;
}

#pragma mark - DIMUserDataSource

- (nullable NSArray<id<MKMID>> *)contactsOfUser:(id<MKMID>)user {
    NSAssert(false, @"implement me!");
    return nil;
}

- (id<MKMEncryptKey>)visaKeyForID:(id<MKMID>)user {
    id<MKMDocument> doc = [self documentForID:user type:MKMDocument_Visa];
    if ([doc conformsToProtocol:@protocol(MKMVisa)]) {
        id<MKMVisa> visa = (id<MKMVisa>) doc;
        if ([visa isValid]) {
            return visa.key;
        }
    }
    return nil;
}

- (id<MKMVerifyKey>)metaKeyForID:(id<MKMID>)user {
    id<MKMMeta> meta = [self metaForID:user];
    NSAssert(meta, @"failed to get meta for ID: %@", user);
    return meta.key;
}

- (nullable id<MKMEncryptKey>)publicKeyForEncryption:(id<MKMID>)user {
    // 1. get key from visa
    id<MKMEncryptKey> visaKey = [self visaKeyForID:user];
    if (visaKey) {
        return visaKey;
    }
    // 2. get key from meta
    id metaKey = [self metaKeyForID:user];
    if ([metaKey conformsToProtocol:@protocol(MKMEncryptKey)]) {
        return metaKey;
    }
    //NSAssert(false, @"failed to get encrypt key for user: %@", user);
    return nil;
}

- (nullable NSArray<id<MKMVerifyKey>> *)publicKeysForVerification:(id<MKMID>)user {
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    // 1. get key from visa
    id visaKey = [self visaKeyForID:user];
    if ([visaKey conformsToProtocol:@protocol(MKMVerifyKey)]) {
        // the sender may use communication key to sign message.data,
        // so try to verify it with visa.key here
        [mArray addObject:visaKey];
    }
    // 2. get key from meta
    id<MKMVerifyKey> metaKey = [self metaKeyForID:user];
    if (metaKey) {
        // the sender may use identity key to sign message.data,
        // try to verify it with meta.key
        [mArray addObject:metaKey];
    }
    NSAssert(mArray.count > 0, @"failed to get verify key for user: %@", user);
    return mArray;
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

#pragma mark - DIMGroupDataSource

static inline NSString *id_name(id<MKMID> group) {
    NSString *name = [group name];
    NSUInteger len = [name length];
    if (len == 0 || (len == 8 && [name isEqualToString:@"everyone"])) {
        return nil;
    }
    return name;
}

- (nullable id<MKMID>)founderOfBroadcastGroup:(id<MKMID>)group {
    NSString *name = id_name(group);
    if (!name) {
        // Consensus: the founder of group 'everyone@everywhere'
        //            'Albert Moky'
        return MKMIDFromString(@"moky@anywhere");
    } else {
        // DISCUSS: who should be the founder of group 'xxx@everywhere'?
        //          'anyone@anywhere', or 'xxx.founder@anywhere'
        return MKMIDFromString([name stringByAppendingString:@".founder@anywhere"]);
    }
}

- (nullable id<MKMID>)ownerOfBroadcastGroup:(id<MKMID>)group {
    NSString *name = id_name(group);
    if (!name) {
        // Consensus: the owner of group 'everyone@everywhere'
        //            'anyone@anywhere'
        return MKMAnyone();
    } else {
        // DISCUSS: who should be the owner of group 'xxx@everywhere'?
        //          'anyone@anywhere', or 'xxx.owner@anywhere'
        return MKMIDFromString([name stringByAppendingString:@".owner@anywhere"]);
    }
}

- (nullable NSArray<id<MKMID>> *)membersOfBroadcastGroup:(id<MKMID>)group {
    NSMutableArray<id<MKMID>> *mArray = [[NSMutableArray alloc] init];
    NSString *name = id_name(group);
    if (!name) {
        // Consensus: the member of group 'everyone@everywhere'
        //            'anyone@anywhere'
        [mArray addObject:MKMAnyone()];
    } else {
        // DISCUSS: who should be the member of group 'xxx@everywhere'?
        //          'anyone@anywhere', or 'xxx.member@anywhere'
        id<MKMID> owner = MKMIDFromString([name stringByAppendingString:@".owner@anywhere"]);
        id<MKMID> member = MKMIDFromString([name stringByAppendingString:@".member@anywhere"]);
        [mArray addObject:owner];
        [mArray addObject:member];
    }
    return mArray;
}

- (nullable id<MKMID>)founderOfGroup:(id<MKMID>)group {
    // check broadcast group
    if (MKMIDIsBroadcast(group)) {
        // founder of broadcast group
        return [self founderOfBroadcastGroup:group];
    }
    
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
        if ([gMeta matchPublicKey:mMeta.key]) {
            // if the member's public key matches with the group's meta,
            // it means this meta was generated by the member's private key
            return item;
        }
    }
    
    // NOTICE: let sub-class to load founder from database
    return nil;
}

- (nullable id<MKMID>)ownerOfGroup:(id<MKMID>)group {
    // check broadcast group
    if (MKMIDIsBroadcast(group)) {
        // owner of broadcast group
        return [self ownerOfBroadcastGroup:group];
    }
    
    // check group type
    if (group.type == MKMNetwork_Polylogue) {
        // Polylogue's owner is its founder
        return [self founderOfGroup:group];
    }
    
    // NOTICE: let sub-class to load owner from database
    return nil;
}

- (nullable NSArray<id<MKMID>> *)membersOfGroup:(id<MKMID>)group {
    // check broadcast group
    if (MKMIDIsBroadcast(group)) {
        // members of broadcast group
        return [self membersOfBroadcastGroup:group];
    }
    
    // NOTICE: let sub-class to load members from database
    return nil;
}

- (nullable NSArray<id<MKMID>> *)assistantsOfGroup:(id<MKMID>)group {
    id<MKMDocument> doc = [self documentForID:group type:MKMDocument_Bulletin];
    if ([doc conformsToProtocol:@protocol(MKMBulletin)]) {
        if ([doc isValid]) {
            return [(id<MKMBulletin>) doc assistants];
        }
    }
    
    // NOTICE: let sub-class to get group bots from SP configuration
    return nil;
}

@end
