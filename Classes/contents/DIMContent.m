// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2020 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2020 Albert Moky
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
//  DIMContent.m
//  DIMCore
//
//  Created by Albert Moky on 2020/12/8.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import "DIMContent.h"

DIMContent *DIMContentCreate(DKDContentType type) {
    return [[DIMContent alloc] initWithType:type];
}

@interface DIMContent () {
    
    id<MKMID> _group;
}

@property (nonatomic) DKDContentType type;
@property (nonatomic) unsigned long serialNumber;
@property (strong, nonatomic, nullable) NSDate *time;

@end

@implementation DIMContent

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    return [self initWithType:0];
}

/* designated initializer */
- (instancetype)initWithType:(DKDContentType)type {
    NSDate *now = [[NSDate alloc] init];
    NSUInteger sn = DKDInstantMessageGenerateSerialNumber(type, now);
    NSDictionary *dict = @{@"type":@(type),
                           @"sn"  :@(sn),
                           @"time":@([now timeIntervalSince1970]),
                           };
    if (self = [super initWithDictionary:dict]) {
        _type = type;
        _serialNumber = sn;
        _time = now;
        
        _group = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy load
        _type = 0;
        _serialNumber = 0;
        _time = nil;
        _group = nil;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMContent *content = [super copyWithZone:zone];
    if (content) {
        content.type = _type;
        content.serialNumber = _serialNumber;
        content.time = _time;
        //content.group = _group;
    }
    return content;
}

- (DKDContentType)type {
    if (_type == 0) {
        _type = [self uint8ForKey:@"type"];
    }
    return _type;
}

- (unsigned long)serialNumber {
    if (_serialNumber == 0) {
        _serialNumber = [self ulongForKey:@"sn"];
    }
    return _serialNumber;
}

- (nullable NSDate *)time {
    if (!_time) {
        _time = [self dateForKey:@"time"];
    }
    return _time;
}

- (nullable id<MKMID>)group {
    if (!_group) {
        _group = MKMIDParse([self objectForKey:@"group"]);
    }
    return _group;
}

- (void)setGroup:(nullable id<MKMID>)group {
    if (group) {
        [self setString:group forKey:@"group"];
    } else {
        [self removeObjectForKey:@"group"];
    }
    _group = group;
}

@end
