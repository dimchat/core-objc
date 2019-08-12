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
