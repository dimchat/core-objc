// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2019 by Moky <albert.moky@gmail.com>
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
//  DIMDocumentCommand.m
//  DIMCore
//
//  Created by Albert Moky on 2019/2/3.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMDocumentCommand.h"

@interface DIMDocumentCommand ()

@property (strong, nonatomic, nullable) NSArray<id<MKMDocument>> *documents;

@end

@implementation DIMDocumentCommand

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _documents = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithType:(NSString *)type {
    if (self = [super initWithType:type]) {
        _documents = nil;
    }
    return self;
}

- (instancetype)initWithID:(id<MKMID>)ID {
    NSArray<id<MKMDocument>> *docs = @[];
    return [self initWithID:ID meta:nil documents:docs];
}

- (instancetype)initWithID:(id<MKMID>)ID
                      meta:(id<MKMMeta>)meta
                 documents:(NSArray<id<MKMDocument>> *)docs {
    if (self = [self initWithCMD:DKDCommand_Documents ID:ID meta:meta]) {
        // document
        if ([docs count] > 0) {
            [self setObject:MKMDocumentRevert(docs) forKey:@"documents"];
        }
        _documents = docs;
    }
    return self;
}

- (instancetype)initWithID:(id<MKMID>)ID
                  lastTime:(NSDate *)time {
    NSArray<id<MKMDocument>> *docs = @[];
    if (self = [self initWithID:ID meta:nil documents:docs]) {
        // last document time
        if (time) {
            [self setDate:time forKey:@"last_time"];
        }
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMDocumentCommand *content = [super copyWithZone:zone];
    if (content) {
        content.documents = _documents;
    }
    return content;
}

- (NSArray<id<MKMDocument>> *)documents {
    if (!_documents) {
        id array = [self objectForKey:@"documents"];
        if ([array isKindOfClass:[NSArray class]]) {
            _documents = MKMDocumentConvert(array);
        } else {
            NSAssert(array == nil, @"documents error: %@", array);
            _documents = @[];
        }
    }
    return _documents;
}

- (NSDate *)lastTime {
    return [self dateForKey:@"last_time" defaultValue:nil];
}

@end

#pragma mark - Conveniences

DIMDocumentCommand *DIMDocumentCommandResponse(id<MKMID> ID,
                                               id<MKMMeta> meta,
                                               NSArray<id<MKMDocument>> *docs) {
    return [[DIMDocumentCommand alloc] initWithID:ID meta:meta documents:docs];
}

DIMDocumentCommand *DIMDocumentCommandQuery(id<MKMID> ID,
                                            NSDate *lastTime) {
    return [[DIMDocumentCommand alloc] initWithID:ID lastTime:lastTime];
}
