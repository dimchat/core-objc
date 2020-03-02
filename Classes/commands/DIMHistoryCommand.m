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
//  DIMHistoryCommand.m
//  DIMCore
//
//  Created by Albert Moky on 2019/1/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSDate+Timestamp.h"

#import "DIMGroupCommand.h"

#import "DIMHistoryCommand.h"

@interface DIMHistoryCommand ()

@property (strong, nonatomic) NSDate *time;

@end

@implementation DIMHistoryCommand

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _time = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithType:(UInt8)type {
    if (self = [super initWithType:type]) {
        _time = nil;
    }
    return self;
}

- (instancetype)initWithHistoryCommand:(NSString *)cmd {
    NSAssert(cmd.length > 0, @"command name cannot be empty");
    if (self = [self initWithType:DKDContentType_History]) {
        // command
        if (cmd) {
            [_storeDictionary setObject:cmd forKey:@"command"];
        }
        // time
        _time = [[NSDate alloc] init];
        NSNumber *timestemp = NSNumberFromDate(_time);
        [_storeDictionary setObject:timestemp forKey:@"time"];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMHistoryCommand *cmd = [super copyWithZone:zone];
    if (cmd) {
        cmd.time = _time;
    }
    return cmd;
}

- (NSDate *)time {
    if (!_time) {
        NSNumber *timestamp = [_storeDictionary objectForKey:@"time"];
        NSAssert(timestamp != nil, @"time error: %@", _storeDictionary);
        _time = NSDateFromNumber(timestamp);
    }
    return _time;
}

@end

@implementation DIMHistoryCommand (Runtime)

+ (nullable Class)classForHistoryCommand:(NSString *)cmd {
    // NOTICE: here combine all history commands into common command pool
    return [self classForCommand:cmd];
}

+ (nullable instancetype)getInstance:(id)content {
    if (!content) {
        return nil;
    }
    if ([content isKindOfClass:[DIMHistoryCommand class]]) {
        // return HistoryCommand object directly
        return content;
    }
    NSAssert([content isKindOfClass:[NSDictionary class]], @"history error: %@", content);
    if ([self isEqual:[DIMHistoryCommand class]]) {
        // check group
        NSString *group = [content objectForKey:@"group"];
        if (group) {
            // group history command
            return [DIMGroupCommand getInstance:content];
        }
        // create instance by subclass with command name
        NSString *command = [content objectForKey:@"command"];
        Class clazz = [self classForHistoryCommand:command];
        if (clazz) {
            return [clazz getInstance:content];
        }
    }
    // custom history command
    return [[self alloc] initWithDictionary:content];
}

@end
