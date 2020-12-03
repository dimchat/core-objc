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

typedef NSMutableDictionary<NSString *, DIMUser *> UserTableM;
typedef NSMutableDictionary<NSString *, DIMGroup *> GroupTableM;

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

- (BOOL)cacheUser:(DIMUser *)user {
    if (user.dataSource == nil) {
        user.dataSource = self;
    }
    [_userTable setObject:user forKey:user.ID.string];
    return YES;
}

- (BOOL)cacheGroup:(DIMGroup *)group {
    if (group.dataSource == nil) {
        group.dataSource = self;
    }
    [_groupTable setObject:group forKey:group.ID.string];
    return YES;
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

- (nullable __kindof DIMUser *)userWithID:(id<MKMID>)ID {
    // 1. get from user cache
    DIMUser *user = [_userTable objectForKey:ID.string];
    if (user) {
        return user;
    }
    // 2. create user and cache it
    user = [self createUser:ID];
    if (user && [self cacheUser:user]) {
        return user;
    }
    //NSAssert(false, @"failed to create user: %@", ID);
    return nil;
}

- (nullable __kindof DIMGroup *)groupWithID:(id<MKMID>)ID {
    // 1. get from group cache
    DIMGroup *group = [_groupTable objectForKey:ID.string];
    if (group) {
        return group;
    }
    // 2. create group and cache it
    group = [self createGroup:ID];
    if (group && [self cacheGroup:group]) {
        return group;
    }
    //NSAssert(false, @"failed to create group: %@", ID);
    return nil;
}

#pragma mark - MKMEntityDataSource

- (nullable id<MKMMeta>)metaForID:(id<MKMID>)ID {
    NSAssert(false, @"override me!");
    return nil;
}

- (nullable __kindof id<MKMDocument>)documentForID:(id<MKMID>)ID
                                          withType:(nullable NSString *)type {
    NSAssert(false, @"override me!");
    return nil;
}

#pragma mark - MKMUserDataSource

- (nullable NSArray<id<MKMID>> *)contactsOfUser:(id<MKMID>)user {
    NSAssert(false, @"override me!");
    return nil;
}

- (NSArray<id<MKMVerifyKey>> *)publicKeysForVerification:(id<MKMID>)user {
    NSMutableArray<id<DIMVerifyKey>> *keys = [[NSMutableArray alloc] init];
    // get profile.key
    id<MKMVisa> profile = [self documentForID:user withType:MKMDocument_Visa];
    if (profile) {
        id<DIMEncryptKey> profileKey = [profile key];
        if ([profileKey conformsToProtocol:@protocol(DIMVerifyKey)]) {
            // the sender may use communication key to sign message.data,
            // so try to verify it with profile.key here
            [keys addObject:(id<DIMVerifyKey>)profileKey];
        }
    }
    // get meta.key
    id<MKMMeta> meta = [self metaForID:user];
    if (meta) {
        id<MKMVerifyKey> metaKey = [meta key];
        if (metaKey) {
            // the sender may use identity key to sign message.data,
            // try to verify it with meta.key
            [keys addObject:metaKey];
        }
    }
    return keys;
}

- (NSArray<id<MKMDecryptKey>> *)privateKeysForDecryption:(id<MKMID>)user {
    NSAssert(false, @"override me!");
    return nil;
}

- (id<MKMSignKey>)privateKeyForSignature:(id<MKMID>)user {
    NSAssert(false, @"override me!");
    return nil;
}

- (id<MKMSignKey>)privateKeyForVisaSignature:(id<MKMID>)user {
    NSAssert(false, @"override me!");
    return nil;
}

#pragma mark - MKMGroupDataSource

- (nullable id<MKMID>)founderOfGroup:(id<MKMID>)group {
    // check for broadcast
    if ([MKMID isBroadcast:group]) {
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
        return MKMIDFromString(founder);
    }
    return nil;
}

- (nullable id<MKMID>)ownerOfGroup:(id<MKMID>)group {
    // check for broadcast
    if ([MKMID isBroadcast:group]) {
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
        return MKMIDFromString(owner);
    }
    return nil;
}

- (nullable NSArray<id<MKMID>> *)membersOfGroup:(id<MKMID>)group {
    // check for broadcast
    if ([MKMID isBroadcast:group]) {
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
        id<MKMID>ID = MKMIDFromString(member);
        id<MKMID>owner = [self ownerOfGroup:group];
        if ([ID isEqual:owner]) {
            return [[NSArray alloc] initWithObjects:owner, nil];
        } else {
            return [[NSArray alloc] initWithObjects:owner, ID, nil];
        }
    }
    return nil;
}

@end
