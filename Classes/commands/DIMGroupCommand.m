//
//  DIMGroupCommand.m
//  DIMCore
//
//  Created by Albert Moky on 2019/2/3.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMGroupCommand.h"

@implementation DIMCommand (Group)

- (nullable const DIMID *)member {
    NSString *str = [_storeDictionary objectForKey:@"member"];
    DIMID *ID = MKMIDFromString(str);
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
        ID = MKMIDFromString(item);
        NSAssert([ID isValid], @"members item error: %@", item);
        [mArray addObject:ID];
    }
    // replace the members array to avoid building IDs from string again
    [_storeDictionary setObject:mArray forKey:@"members"];
    return mArray;
}

@end

@implementation DIMGroupCommand

- (instancetype)initWithCommand:(const NSString *)cmd
                          group:(const MKMID *)groupID {
    
    if (self = [self initWithHistoryCommand:cmd]) {
        // Group ID
        if (groupID) {
            [_storeDictionary setObject:groupID forKey:@"group"];
        }
    }
    return self;
}

- (instancetype)initWithCommand:(const NSString *)cmd
                          group:(const DIMID *)groupID
                         member:(const DIMID *)memberID {
    
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

@end

#pragma mark -

@implementation DIMInviteCommand

- (instancetype)initWithGroup:(const DIMID *)groupID
                       member:(const DIMID *)memberID {
    
    return [super initWithCommand:DIMGroupCommand_Invite
                            group:groupID
                           member:memberID];
}

- (instancetype)initWithGroup:(const MKMID *)groupID
                      members:(const NSArray<const MKMID *> *)list {
    
    return [super initWithCommand:DIMGroupCommand_Invite
                            group:groupID
                          members:list];
}

@end

@implementation DIMExpelCommand

- (instancetype)initWithGroup:(const DIMID *)groupID
                       member:(const DIMID *)memberID {
    
    return [super initWithCommand:DIMGroupCommand_Expel
                            group:groupID
                           member:memberID];
}

- (instancetype)initWithGroup:(const MKMID *)groupID
                      members:(const NSArray<const MKMID *> *)list {
    
    return [super initWithCommand:DIMGroupCommand_Expel
                            group:groupID
                          members:list];
}

@end

@implementation DIMJoinCommand

- (instancetype)initWithGroup:(const DIMID *)groupID {
    
    return [super initWithCommand:DIMGroupCommand_Join
                            group:groupID];
}

@end

@implementation DIMQuitCommand

- (instancetype)initWithGroup:(const DIMID *)groupID {
    
    return [super initWithCommand:DIMGroupCommand_Quit
                            group:groupID];
}

@end

#pragma mark -

@implementation DIMResetGroupCommand

- (instancetype)initWithGroup:(const MKMID *)groupID
                      members:(const NSArray<const MKMID *> *)list {
    
    return [super initWithCommand:@"reset"
                            group:groupID
                          members:list];
}

@end

@implementation DIMQueryGroupCommand

- (instancetype)initWithGroup:(const DIMID *)groupID {
    
    return [super initWithCommand:@"query"
                            group:groupID];
}

@end
