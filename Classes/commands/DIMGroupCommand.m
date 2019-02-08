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

- (nullable DIMID *)member {
    DIMID *ID = [_storeDictionary objectForKey:@"member"];
    return [DIMID IDWithID:ID];
}

@end

#pragma mark -

@implementation DIMInviteCommand

- (instancetype)initWithGroup:(const DIMID *)groupID
                       member:(nullable const DIMID *)memberID {
    return [super initWithCommand:@"invite" group:groupID member:memberID];
}

@end

@implementation DIMExpelCommand

- (instancetype)initWithGroup:(const DIMID *)groupID
                       member:(nullable const DIMID *)memberID {
    return [super initWithCommand:@"expel" group:groupID member:memberID];
}

@end

@implementation DIMQuitCommand

- (instancetype)initWithGroup:(const DIMID *)groupID {
    return [super initWithCommand:@"quit" group:groupID member:nil];
}

@end
