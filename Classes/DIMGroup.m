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
//  DIMGroup.m
//  DIMCore
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMGroup.h"

@interface DIMGroup () {
    
    id<MKMID> _founder;
}

@property (strong, nonatomic) id<MKMID> founder;

@end

@implementation DIMGroup

/* designated initializer */
- (instancetype)initWithID:(id<MKMID>)ID {
    if (self = [super initWithID:ID]) {
        _founder = nil;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMGroup *group = [super copyWithZone:zone];
    if (group) {
        group.founder = _founder;
    }
    return group;
}

- (NSString *)debugDescription {
    NSString *desc = [super debugDescription];
    NSDictionary *dict = MKMJSONDecode(desc);
    NSMutableDictionary *info;
    if ([dict isKindOfClass:[NSMutableDictionary class]]) {
        info = (NSMutableDictionary *)dict;
    } else {
        info = [dict mutableCopy];
    }
    [info setObject:@(self.members.count) forKey:@"members"];
    return MKMJSONEncode(info);
}

- (nullable id<MKMBulletin>)bulletin {
    id<MKMDocument> doc = [self documentWithType:MKMDocument_Bulletin];
    if ([doc conformsToProtocol:@protocol(MKMBulletin)]) {
        return (id<MKMBulletin>)doc;
    }
    NSAssert(!doc, @"bulletin document error: %@", doc);
    return nil;
}

- (id<MKMID>)founder {
    if (!_founder) {
        id<DIMGroupDataSource> delegate = (id<DIMGroupDataSource>)[self dataSource];
        NSAssert(delegate, @"group data source not set yet");
        _founder = [delegate founderOfGroup:self.ID];
    }
    return _founder;
}

- (id<MKMID>)owner {
    id<DIMGroupDataSource> delegate = (id<DIMGroupDataSource>)[self dataSource];
    NSAssert(delegate, @"group data source not set yet");
    return [delegate ownerOfGroup:self.ID];
}

- (NSArray<id<MKMID>> *)members {
    id<DIMGroupDataSource> delegate = (id<DIMGroupDataSource>)[self dataSource];
    NSAssert(delegate, @"group data source not set yet");
    return [delegate membersOfGroup:self.ID];
}

- (NSArray<id<MKMID>> *)assistants {
    id<DIMGroupDataSource> delegate = (id<DIMGroupDataSource>)[self dataSource];
    NSAssert(delegate, @"group data source not set yet");
    return [delegate assistantsOfGroup:self.ID];
}

@end
