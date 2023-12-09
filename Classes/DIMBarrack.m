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

@implementation DIMBarrack

// private
- (id<MKMEncryptKey>)visaKeyForID:(id<MKMID>)user {
    id<MKMDocument> doc = [self documentForID:user type:MKMDocumentTypeVisa];
    if ([doc conformsToProtocol:@protocol(MKMVisa)]) {
        id<MKMVisa> visa = (id<MKMVisa>) doc;
        if ([visa isValid]) {
            return visa.publicKey;
        }
    }
    return nil;
}

// private
- (id<MKMVerifyKey>)metaKeyForID:(id<MKMID>)user {
    id<MKMMeta> meta = [self metaForID:user];
    //NSAssert(meta, @"failed to get meta for ID: %@", user);
    return meta.publicKey;
}

#pragma mark MKMEntityDelegate

- (nullable id<MKMUser>)userWithID:(id<MKMID>)ID {
    NSAssert(false, @"implement me!");
    return nil;
}

- (nullable id<MKMGroup>)groupWithID:(id<MKMID>)ID {
    NSAssert(false, @"implement me!");
    return nil;
}

#pragma mark MKMEntityDataSource

- (nullable id<MKMMeta>)metaForID:(id<MKMID>)ID {
    NSAssert(false, @"implement me!");
    return nil;
}

- (nullable id<MKMDocument>)documentForID:(id<MKMID>)ID type:(nullable NSString *)type {
    NSAssert(false, @"implement me!");
    return nil;
}

#pragma mark MKMUserDataSource

- (NSArray<id<MKMID>> *)contactsOfUser:(id<MKMID>)user {
    NSAssert(false, @"implement me!");
    return nil;
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

- (NSArray<id<MKMVerifyKey>> *)publicKeysForVerification:(id<MKMID>)user {
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

#pragma mark MKMGroupDataSource

- (nullable id<MKMID>)founderOfGroup:(id<MKMID>)group {
    // check broadcast group
    if (MKMIDIsBroadcast(group)) {
        // founder of broadcast group
        return [DIMBroadcastHelper broadcastFounder:group];
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
        //if (MKMMetaMatchKey(mMeta.key, gMeta)) {
        if ([gMeta matchPublicKey:mMeta.publicKey]) {
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
        return [DIMBroadcastHelper broadcastOwner:group];
    }
    
    // check group type
    if (group.type == MKMEntityType_Group) {
        // Polylogue's owner is its founder
        return [self founderOfGroup:group];
    }
    
    // NOTICE: let sub-class to load owner from database
    return nil;
}

- (NSArray<id<MKMID>> *)membersOfGroup:(id<MKMID>)group {
    // check broadcast group
    if (MKMIDIsBroadcast(group)) {
        // members of broadcast group
        return [DIMBroadcastHelper broadcastMembers:group];
    }
    
    // NOTICE: let sub-class to load members from database
    return @[];
}

- (NSArray<id<MKMID>> *)assistantsOfGroup:(id<MKMID>)group {
    id<MKMDocument> doc = [self documentForID:group type:MKMDocumentTypeBulletin];
    if ([doc conformsToProtocol:@protocol(MKMBulletin)]) {
        if ([doc isValid]) {
            return [(id<MKMBulletin>) doc assistants];
        }
    }
    // TODO: get group bots from SP configuration
    return @[];
}

@end
