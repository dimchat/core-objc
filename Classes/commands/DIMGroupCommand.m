//
//  DIMGroupCommand.m
//  DIMCore
//
//  Created by Albert Moky on 2019/2/3.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMGroupCommand.h"

@implementation DIMGroupCommand

- (instancetype)initWithCommand:(const NSString *)cmd
                          group:(const DIMID *)groupID
                         member:(nullable const DIMID *)memberID {
    if (self = [self initWithHistoryCommand:cmd]) {
        // Group ID
        if (groupID) {
            [_storeDictionary setObject:groupID forKey:@"group"];
        }
        // Member ID
        if (memberID) {
            [_storeDictionary setObject:memberID forKey:@"member"];
        }
    }
    return self;
}

- (instancetype)initWithCommand:(const NSString *)cmd
                          group:(const MKMID *)groupID
                        members:(const NSArray<const MKMID *> *)list {
    if (self = [self initWithHistoryCommand:cmd]) {
        // Group ID
        if (groupID) {
            [_storeDictionary setObject:groupID forKey:@"group"];
        }
        // Members
        if (list.count > 0) {
            [_storeDictionary setObject:list forKey:@"members"];
        }
    }
    return self;
}

- (nullable const DIMID *)member {
    NSString *str = [_storeDictionary objectForKey:@"member"];
    DIMID *ID = [DIMID IDWithID:str];
    if (ID != str) {
        if (ID) {
            // replace the member ID object
            [_storeDictionary setObject:ID forKey:@"member"];
        } else {
            NSAssert(false, @"member error: %@", str);
            //[_storeDictionary removeObjectForKey:@"member"];
        }
    }
    return ID;
}

- (const NSArray<const DIMID *> *)members {
    NSArray *list = [_storeDictionary objectForKey:@"members"];
    if (list.count == 0) {
        return nil;
    }
    //list = [list copy];
    NSMutableArray<const DIMID *> *mArray;
    mArray = [[NSMutableArray alloc] initWithCapacity:list.count];
    NSString *item;
    DIMID *ID;
    for (item in list) {
        ID = [DIMID IDWithID:item];
        NSAssert(ID.isValid, @"members item error: %@", item);
        [mArray addObject:ID];
    }
    // replace the members array to avoid building IDs from string again
    [_storeDictionary setObject:mArray forKey:@"members"];
    return mArray;
}

@end

#pragma mark -

@implementation DIMInviteCommand

- (instancetype)initWithGroup:(const DIMID *)groupID
                       member:(nullable const DIMID *)memberID {
    return [super initWithCommand:@"invite" group:groupID member:memberID];
}

- (instancetype)initWithGroup:(const MKMID *)groupID
                      members:(const NSArray<const MKMID *> *)list {
    return [super initWithCommand:@"invite" group:groupID members:list];
}

@end

@implementation DIMExpelCommand

- (instancetype)initWithGroup:(const DIMID *)groupID
                       member:(nullable const DIMID *)memberID {
    return [super initWithCommand:@"expel" group:groupID member:memberID];
}

- (instancetype)initWithGroup:(const MKMID *)groupID
                      members:(const NSArray<const MKMID *> *)list {
    return [super initWithCommand:@"expel" group:groupID members:list];
}

@end

@implementation DIMQuitCommand

- (instancetype)initWithGroup:(const DIMID *)groupID {
    return [super initWithCommand:@"quit" group:groupID member:nil];
}

@end
