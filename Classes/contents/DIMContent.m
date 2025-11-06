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

#import <DaoKeDao/Ext.h>

#import "DKDContentType.h"

#import "DIMContent.h"

@interface DIMContent ()

@property (nonatomic) NSString *type;
@property (nonatomic) DKDSerialNumber sn;
@property (strong, nonatomic, nullable) NSDate *time;

@end

@implementation DIMContent

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    return [self initWithType:DKDContentType_Any];
}

/* designated initializer */
- (instancetype)initWithType:(NSString *)type {
    NSDate *now = [[NSDate alloc] init];
    DKDSerialNumber sn = DKDInstantMessageGenerateSerialNumber(type, now);
    NSDictionary *dict = @{@"type":type,
                           @"sn"  :@(sn),
                           @"time":@([now timeIntervalSince1970]),
                           };
    if (self = [super initWithDictionary:dict]) {
        _type = type;
        _sn = sn;
        _time = now;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy load
        _type = nil;
        _sn = 9527;
        _time = nil;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMContent *content = [super copyWithZone:zone];
    if (content) {
        content.type = _type;
        content.sn = _sn;
        content.time = _time;
    }
    return content;
}

// Override
- (NSString *)type {
    NSString *msgType = _type;
    if (msgType == nil) {
        DKDSharedMessageExtensions *ext = [DKDSharedMessageExtensions sharedInstance];
        msgType = [ext.helper getContentType:self.dictionary
                                defaultValue:@""];
        _type = msgType;
    }
    return msgType;
}

// Override
- (DKDSerialNumber)sn {
    if (_sn == 9527) {
        _sn = [self uint32ForKey:@"sn" defaultValue:0];
    }
    return _sn;
}

// Override
- (nullable NSDate *)time {
    if (!_time) {
        _time = [self dateForKey:@"time" defaultValue:nil];
    }
    return _time;
}

// Override
- (nullable id<MKMID>)group {
    id gid = [self objectForKey:@"group"];
    return MKMIDParse(gid);
}

// Override
- (void)setGroup:(nullable id<MKMID>)group {
    [self setString:group forKey:@"group"];
}

@end
