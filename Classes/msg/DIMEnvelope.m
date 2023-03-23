// license: https://mit-license.org
//
//  Dao-Ke-Dao: Universal Message Module
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
//  DIMEnvelope.m
//  DIMSDK
//
//  Created by Albert Moky on 2018/10/1.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMEnvelope.h"

@interface DIMEnvelope ()

@property (strong, nonatomic) id<MKMID> sender;
@property (strong, nonatomic) id<MKMID> receiver;
@property (strong, nonatomic) NSDate *time;

@end

@implementation DIMEnvelope

- (instancetype)init {
    NSAssert(false, @"DON'T call me!");
    NSDictionary *dict = nil;
    return [self initWithDictionary:dict];
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _sender = nil;
        _receiver = nil;
        _time = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithSender:(id<MKMID>)from receiver:(id<MKMID>)to time:(NSDate *)when {
    NSDictionary *dict = @{
        @"sender":[from string],
        @"receiver":[to string],
        @"time":@([when timeIntervalSince1970])
    };
    if (self = [super initWithDictionary:dict]) {
        _sender = from;
        _receiver = to;
        _time = when;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMEnvelope *envelope = [super copyWithZone:zone];
    if (envelope) {
        envelope.sender = _sender;
        envelope.receiver = _receiver;
        envelope.time = _time;
    }
    return envelope;
}

- (id<MKMID>)sender {
    if (!_sender) {
        _sender = MKMIDParse([self objectForKey:@"sender"]);
    }
    return _sender;
}

- (id<MKMID>)receiver {
    if (!_receiver) {
        _receiver = MKMIDParse([self objectForKey:@"receiver"]);
        if (!_receiver) {
            _receiver = MKMAnyone();
        }
    }
    return _receiver;
}

- (NSDate *)time {
    if (!_time) {
        _time = [self dateForKey:@"time"];
    }
    return _time;
}

- (nullable id<MKMID>)group {
    return MKMIDParse([self objectForKey:@"group"]);
}

- (void)setGroup:(nullable id<MKMID>)group {
    if (group) {
        [self setString:group forKey:@"group"];
    } else {
        [self removeObjectForKey:@"group"];
    }
}

- (DKDContentType)type {
    return [self uint8ForKey:@"type"];
}

- (void)setType:(DKDContentType)type {
    [self setObject:@(type) forKey:@"type"];
}

@end

@implementation DIMEnvelopeFactory

- (id<DKDEnvelope>)createEnvelopeWithSender:(id<MKMID>)from
                                   receiver:(id<MKMID>)to
                                       time:(nullable NSDate *)when {
    if (!when) {
        // now()
        when = [[NSDate alloc] init];
    }
    return [[DIMEnvelope alloc] initWithSender:from receiver:to time:when];
}

- (nullable id<DKDEnvelope>)parseEnvelope:(NSDictionary *)env {
    // check 'sender'
    id sender = [env objectForKey:@"sender"];
    if (!sender) {
        // env.sender should not be empty
        return nil;
    }
    return [[DIMEnvelope alloc] initWithDictionary:env];
}

@end
