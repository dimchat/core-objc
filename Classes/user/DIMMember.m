// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
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
//  DIMMember.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/1.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMMember.h"

@interface DIMMember ()

@property (strong, nonatomic) DIMID *group;

@end

@implementation DIMMember

- (instancetype)initWithID:(DIMID *)ID {
    NSAssert(false, @"DON'T call me");
    DIMID *group = nil;
    return [self initWithGroup:group user:ID];
}

/* designated initializer */
- (instancetype)initWithGroup:(DIMID *)group
                         user:(DIMID *)ID {
    NSAssert(MKMNetwork_IsUser(ID.type), @"member ID error: %@", ID);
    NSAssert(!group || MKMNetwork_IsGroup(group.type), @"group ID error: %@", group);
    if (self = [super initWithID:ID]) {
        _group = group;
        _role = DIMMember_Member;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMMember *member = [super copyWithZone:zone];
    if (member) {
        member.group = _group;
        member.role = _role;
    }
    return member;
}

@end

#pragma mark -

@implementation DIMFounder

- (instancetype)initWithGroup:(DIMID *)group
                         user:(DIMID *)ID {
    if (self = [super initWithGroup:group user:ID]) {
        _role = DIMMember_Founder;
    }
    return self;
}

@end

@implementation DIMOwner

- (instancetype)initWithGroup:(DIMID *)group
                         user:(DIMID *)ID {
    if (self = [super initWithGroup:group user:ID]) {
        _role = DIMMember_Owner;
    }
    return self;
}

@end

@implementation DIMAdmin

- (instancetype)initWithGroup:(DIMID *)group
                         user:(DIMID *)ID {
    if (self = [super initWithGroup:group user:ID]) {
        _role = DIMMember_Admin;
    }
    return self;
}

@end
