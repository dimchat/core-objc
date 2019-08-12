//
//  DIMPolylogue.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/8.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMPolylogue.h"

@implementation DIMPolylogue

/* designated initializer */
- (instancetype)initWithID:(DIMID *)ID {
    NSAssert(ID.type == MKMNetwork_Polylogue, @"polylogue ID error: %@", ID);
    if (self = [super initWithID:ID]) {
        //
    }
    return self;
}

- (DIMID *)owner {
    DIMID *ID = [super owner];
    if ([ID isValid]) {
        NSAssert([[self founder] isEqual:ID], @"polylugue's owner is founder");
        return ID;
    }
    return [self founder];
}

@end
