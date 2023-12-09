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

#import "DIMDocs.h"
#import "DIMHelpers.h"

#import "DIMBarrack.h"

@interface DIMBarrack () {
    
    NSMutableDictionary<id<MKMID>, id<MKMUser>> *_userTable;
    NSMutableDictionary<id<MKMID>, id<MKMGroup>> *_groupTable;
}

@end

@implementation DIMBarrack

- (instancetype)init {
    if (self = [super init]) {
        _userTable = [[NSMutableDictionary alloc] init];
        _groupTable = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id<MKMVisa>)visaForID:(id<MKMID>)ID {
    NSArray<id<MKMDocument>> *docs = [self documentsForID:ID];
    return [DIMDocumentHelper lastVisa:docs];
}

- (id<MKMBulletin>)bulletinForID:(id<MKMID>)ID {
    NSArray<id<MKMDocument>> *docs = [self documentsForID:ID];
    return [DIMDocumentHelper lastBulletin:docs];
}

#pragma mark MKMEntityDelegate

- (nullable id<MKMUser>)userWithID:(id<MKMID>)ID {
    NSAssert([ID isUser], @"user ID error: %@", ID);
    // get from user cache
    id<MKMUser> user = [_userTable objectForKey:ID];
    if (!user) {
        // 2. create user and cache it
        user = [self createUser:ID];
        if (user) {
            [self cacheUser:user];
        }
    }
    return user;
}

- (nullable id<MKMGroup>)groupWithID:(id<MKMID>)ID {
    NSAssert([ID isGroup], @"group ID error: %@", ID);
    // 1. get from group cache
    id<MKMGroup> group = [_groupTable objectForKey:ID];
    if (!group) {
        // 2. create group and cache it
        group = [self createGroup:ID];
        if (group) {
            [self cacheGroup:group];
        }
    }
    return group;
}

#pragma mark MKMEntityDataSource

- (nullable id<MKMMeta>)metaForID:(id<MKMID>)ID {
    NSAssert(false, @"implement me!");
    return nil;
}

- (NSArray<id<MKMDocument>> *)documentsForID:(id<MKMID>)ID {
    NSAssert(false, @"implement me!");
    return nil;
}

#pragma mark MKMUserDataSource

- (NSArray<id<MKMID>> *)contactsOfUser:(id<MKMID>)user {
    NSAssert(false, @"implement me!");
    return nil;
}

- (nullable id<MKMEncryptKey>)publicKeyForEncryption:(id<MKMID>)user {
    NSAssert([user isUser], @"user ID error: %@", user);
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

- (NSArray<id<MKMVerifyKey>> *)publicKeysForVerification:(id<MKMID>)user {
    // NSAssert([user isUser], @"user ID error: %@", user);
    NSMutableArray<id<MKMVerifyKey>> *mArray = [[NSMutableArray alloc] init];
    // 1. get key from meta
    id<MKMVerifyKey> metaKey = [self metaKeyForID:user];
    if (metaKey) {
        // the sender may use identity key to sign message.data,
        // try to verify it with meta.key
        [mArray addObject:metaKey];
    }
    // 2. get key from visa
    id visaKey = [self visaKeyForID:user];
    if ([visaKey conformsToProtocol:@protocol(MKMVerifyKey)]) {
        // the sender may use communication key to sign message.data,
        // so try to verify it with visa.key here
        [mArray addObject:visaKey];
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

#pragma mark MKMGroupDataSource

- (nullable id<MKMID>)founderOfGroup:(id<MKMID>)group {
    NSAssert([group isGroup], @"group ID error: %@", group);
    // check broadcast group
    if (MKMIDIsBroadcast(group)) {
        // founder of broadcast group
        return [DIMBroadcastHelper broadcastFounder:group];
    }
    // get from document
    id<MKMBulletin> doc = [self bulletinForID:group];
    if (doc/* && [doc isValid]*/) {
        return [doc founder];
    }
    // TODO: load founder from database
    return nil;
}

- (nullable id<MKMID>)ownerOfGroup:(id<MKMID>)group {
    NSAssert([group isGroup], @"group ID error: %@", group);
    // check broadcast group
    if (MKMIDIsBroadcast(group)) {
        // owner of broadcast group
        return [DIMBroadcastHelper broadcastOwner:group];
    }
    // check group type
    if (group.type == MKMEntityType_Group) {
        // Polylogue's owner is its founder
        return [self founderOfGroup:group];
    }
    // TODO: load owner from database
    return nil;
}

- (NSArray<id<MKMID>> *)membersOfGroup:(id<MKMID>)group {
    NSAssert([group isGroup], @"group ID error: %@", group);
    // check broadcast group
    if (MKMIDIsBroadcast(group)) {
        // members of broadcast group
        return [DIMBroadcastHelper broadcastMembers:group];
    }
    // TODO: load members from database
    return @[];
}

- (NSArray<id<MKMID>> *)assistantsOfGroup:(id<MKMID>)group {
    NSAssert([group isGroup], @"group ID error: %@", group);
    // get from document
    id<MKMBulletin> doc = [self bulletinForID:group];
    if (doc/* && [doc isValid]*/) {
        return [doc assistants];
    }
    // TODO: get group bots from SP configuration
    return @[];
}

@end

@implementation DIMBarrack (facebook)

- (void)cacheUser:(id<MKMUser>)user {
    if (user.dataSource == nil) {
        user.dataSource = self;
    }
    [_userTable setObject:user forKey:user.ID];
}

- (void)cacheGroup:(id<MKMGroup>)group {
    if (group.dataSource == nil) {
        group.dataSource = self;
    }
    [_groupTable setObject:group forKey:group.ID];
}

- (nullable id<MKMUser>)createUser:(id<MKMID>)ID {
    NSAssert(false, @"implement me!");
    return nil;
}

- (nullable id<MKMGroup>)createGroup:(id<MKMID>)ID {
    NSAssert(false, @"implement me!");
    return nil;
}

- (id<MKMEncryptKey>)visaKeyForID:(id<MKMID>)user {
    id<MKMVisa> doc = [self visaForID:user];
    NSAssert(doc, @"failed to get visa for: %@", user);
    return [doc publicKey];
}

- (id<MKMVerifyKey>)metaKeyForID:(id<MKMID>)user {
    id<MKMMeta> meta = [self metaForID:user];
    NSAssert(meta, @"failed to get meta for: %@", user);
    return [meta publicKey];
}

@end

@implementation DIMBarrack (thanos)

- (NSInteger)reduceMemory {
    NSUInteger snap = 0;
    snap = DIMThanos(_userTable, snap);
    snap = DIMThanos(_groupTable, snap);
    return snap;
}

@end

NSUInteger DIMThanos(NSMutableDictionary *planet, NSUInteger finger) {
    NSArray *people = [planet allKeys];
    // if ++finger is odd, remove it,
    // else, let it go
    for (id key in people) {
        if ((++finger & 1) == 1) {
            // kill it
            [planet removeObjectForKey:key];
        }
        // let it go
    }
    return finger;
}
