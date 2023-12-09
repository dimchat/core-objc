// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2023 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2023 Albert Moky
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
//  DIMHelpers.m
//  DIMCore
//
//  Created by Albert Moky on 2023/12/7.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DIMDocs.h"

#import "DIMHelpers.h"

@implementation DIMBroadcastHelper

+ (NSString *)groupSeed:(id<MKMID>)group {
    NSString *name = [group name];
    if (name) {
        NSUInteger len = [name length];
        if (len == 0) {
            return nil;
        } else if (len == 8) {
            NSComparisonResult res = [name caseInsensitiveCompare:@"everyone"];
            if (res == NSOrderedSame) {
                return nil;
            }
        }
    }
    return name;
}

+ (id<MKMID>)broadcastFounder:(id<MKMID>)group {
    NSString *name = [self groupSeed:group];
    if (!name) {
        // Consensus: the founder of group 'everyone@everywhere'
        //            'Albert Moky'
        return MKMIDParse(@"moky@anywhere");
    } else {
        // DISCUSS: who should be the founder of group 'xxx@everywhere'?
        //          'anyone@anywhere', or 'xxx.founder@anywhere'
        return MKMIDParse([name stringByAppendingString:@".founder@anywhere"]);
    }
}

+ (id<MKMID>)broadcastOwner:(id<MKMID>)group {
    NSString *name = [self groupSeed:group];
    if (!name) {
        // Consensus: the owner of group 'everyone@everywhere'
        //            'anyone@anywhere'
        return MKMAnyone();
    } else {
        // DISCUSS: who should be the owner of group 'xxx@everywhere'?
        //          'anyone@anywhere', or 'xxx.owner@anywhere'
        return MKMIDParse([name stringByAppendingString:@".owner@anywhere"]);
    }
}

+ (NSArray<id<MKMID>> *)broadcastMembers:(id<MKMID>)group {
    NSString *name = [self groupSeed:group];
    NSMutableArray<id<MKMID>> *mArray = [[NSMutableArray alloc] init];
    if (!name) {
        // Consensus: the member of group 'everyone@everywhere'
        //            'anyone@anywhere'
        [mArray addObject:MKMAnyone()];
    } else {
        // DISCUSS: who should be the member of group 'xxx@everywhere'?
        //          'anyone@anywhere', or 'xxx.member@anywhere'
        id<MKMID> owner = MKMIDParse([name stringByAppendingString:@".owner@anywhere"]);
        id<MKMID> member = MKMIDParse([name stringByAppendingString:@".member@anywhere"]);
        [mArray addObject:owner];
        [mArray addObject:member];
    }
    return mArray;
}

@end

@implementation DIMMetaHelper

+ (BOOL)checkMeta:(id<MKMMeta>)meta {
    id<MKMVerifyKey> key = meta.publicKey;
    // NSAssert(key, @"meta.key should not be empty: %@", meta);
    NSString *seed = meta.seed;
    NSData *fingerprint = meta.fingerprint;
    BOOL noSeed = [seed length] == 0;
    BOOL noSig = [fingerprint length] == 0;
    // check meta version
    if (!MKMMeta_HasSeed(meta.type)) {
        // this meta has no seed, so no fingerprint too
        return noSeed && noSig;
    } else if (noSeed || noSig) {
        // seed and fingerprint should not be empty
        return NO;
    }
    // verify fingerprint
    return [key verify:MKMUTF8Encode(seed) withSignature:fingerprint];
}

+ (BOOL)meta:(id<MKMMeta>)meta matchIdentifier:(id<MKMID>)ID {
    // check ID.name
    NSString *seed = meta.seed;
    NSString *name = ID.name;
    if ([name length] == 0) {
        if ([seed length] > 0) {
            return NO;
        }
    } else if (![name isEqualToString:seed]) {
        return NO;
    }
    // check ID.address
    id<MKMAddress> old = ID.address;
    id<MKMAddress> gen = MKMAddressGenerate(old.type, meta);
    return [old isEqual:gen];
}

+ (BOOL)meta:(id<MKMMeta>)meta matchPublicKeyu:(id<MKMVerifyKey>)PK {
    if ([meta.publicKey isEqual:PK]) {
        return YES;
    }
    // check with seed & fingerprint
    if (MKMMeta_HasSeed(meta.type)) {
        // check whether keys equal by verifying signature
        return [PK verify:MKMUTF8Encode(meta.seed)
            withSignature:meta.fingerprint];
    }
    // NOTICE: ID with BTC/ETH address has no username, so
    //         just compare the key.data to check matching
    return NO;
}

@end

@implementation DIMDocumentHelper

+ (BOOL)time:(nullable NSDate *)thisTime isBefore:(nullable NSDate *)oldTime {
    if (thisTime && oldTime) {
        // check 'isBefore()'
        return [thisTime timeIntervalSince1970] < [oldTime timeIntervalSince1970];
        //return [thisTime compare:oldTime] < 0;
    } else {
        return NO;
    }
}

+ (BOOL)isExpired:(id<MKMDocument>)thisDoc compareTo:(id<MKMDocument>)oldDoc {
    return [self time:thisDoc.time isBefore:oldDoc.time];
}

+ (nullable id<MKMDocument>)lastDocument:(NSArray<id<MKMDocument>> *)documents
                                 forType:(nullable NSString *)type {
    if (!type || [type isEqualToString:@"*"]) {
        type = @"";
    }
    BOOL checkType = [type length] > 0;
    id<MKMDocument> last = nil;
    NSString *docType;
    BOOL matched;
    for (id<MKMDocument> doc in documents) {
        // 1. check type
        if (checkType) {
            docType = [doc type];
            matched = [docType length] == 0 || [docType isEqualToString:type];
            if (!matched) {
                // type not matched, skip it
                continue;
            }
        }
        // 2. check time
        if (!last) {
            if ([self isExpired:doc compareTo:last]) {
                // skip expired document
                continue;
            }
        }
        // got it
        last = doc;
    }
    return last;
}

+ (nullable id<MKMVisa>)lastVisa:(NSArray<id<MKMDocument>> *)documents {
    id<MKMVisa> last;
    bool matched;
    for (id doc in documents) {
        // 1. check type
        matched = [doc conformsToProtocol:@protocol(MKMVisa)];
        if (!matched) {
            // type not matched, skip it
            continue;
        }
        // 2. check time
        if (!last) {
            if ([self isExpired:doc compareTo:last]) {
                // skip expired document
                continue;
            }
        }
        // got it
        last = doc;
    }
    return last;
}

+ (nullable id<MKMBulletin>)lastBulletin:(NSArray<id<MKMDocument>> *)documents {
    id<MKMBulletin> last;
    bool matched;
    for (id doc in documents) {
        // 1. check type
        matched = [doc conformsToProtocol:@protocol(MKMBulletin)];
        if (!matched) {
            // type not matched, skip it
            continue;
        }
        // 2. check time
        if (!last) {
            if ([self isExpired:doc compareTo:last]) {
                // skip expired document
                continue;
            }
        }
        // got it
        last = doc;
    }
    return last;
}

@end
