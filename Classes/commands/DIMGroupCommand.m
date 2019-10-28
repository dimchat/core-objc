//
//  DIMGroupCommand.m
//  DIMCore
//
//  Created by Albert Moky on 2019/2/3.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "DIMGroupCommand.h"

@implementation DIMGroupCommand

- (instancetype)initWithCommand:(NSString *)cmd
                          group:(DIMID *)groupID {
    
    if (self = [self initWithHistoryCommand:cmd]) {
        // Group ID
        if (groupID) {
            [_storeDictionary setObject:groupID forKey:@"group"];
        }
    }
    return self;
}

- (instancetype)initWithCommand:(NSString *)cmd
                          group:(DIMID *)groupID
                         member:(DIMID *)memberID {
    
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

- (instancetype)initWithCommand:(NSString *)cmd
                          group:(DIMID *)groupID
                        members:(NSArray<DIMID *> *)list {
    
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

- (nullable DIMID *)member {
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

- (NSArray<DIMID *> *)members {
    NSArray *list = [_storeDictionary objectForKey:@"members"];
    if (list.count == 0) {
        return nil;
    }
    NSMutableArray<DIMID *> *mArray;
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

@implementation DIMGroupCommand (Runtime)

+ (nullable Class)classForGroupCommand:(NSString *)cmd {
    // NOTICE: here combine all group commands into common command pool
    return [super classForCommand:cmd];
}

+ (nullable instancetype)getInstance:(id)content {
    if (!content) {
        return nil;
    }
    if ([content isKindOfClass:[DIMGroupCommand class]]) {
        // return GroupCommand object directly
        return content;
    }
    NSAssert([content isKindOfClass:[NSDictionary class]], @"group command error: %@", content);
    if ([self isEqual:[DIMGroupCommand class]]) {
        // create instance by subclass with group command name
        NSString *command = [content objectForKey:@"command"];
        Class clazz = [self classForGroupCommand:command];
        if (clazz) {
            return [clazz getInstance:content];
        }
    }
    // custom group command
    return [[self alloc] initWithDictionary:content];
}

@end

#pragma mark -

@implementation DIMInviteCommand

- (instancetype)initWithGroup:(DIMID *)groupID
                       member:(DIMID *)memberID {
    
    return [super initWithCommand:DIMGroupCommand_Invite
                            group:groupID
                           member:memberID];
}

- (instancetype)initWithGroup:(DIMID *)groupID
                      members:(NSArray<DIMID *> *)list {
    
    return [super initWithCommand:DIMGroupCommand_Invite
                            group:groupID
                          members:list];
}

@end

@implementation DIMExpelCommand

- (instancetype)initWithGroup:(DIMID *)groupID
                       member:(DIMID *)memberID {
    
    return [super initWithCommand:DIMGroupCommand_Expel
                            group:groupID
                           member:memberID];
}

- (instancetype)initWithGroup:(DIMID *)groupID
                      members:(NSArray<DIMID *> *)list {
    
    return [super initWithCommand:DIMGroupCommand_Expel
                            group:groupID
                          members:list];
}

@end

@implementation DIMJoinCommand

- (instancetype)initWithGroup:(DIMID *)groupID {
    
    return [super initWithCommand:DIMGroupCommand_Join group:groupID];
}

@end

@implementation DIMQuitCommand

- (instancetype)initWithGroup:(DIMID *)groupID {
    
    return [super initWithCommand:DIMGroupCommand_Quit group:groupID];
}

@end

#pragma mark -

@implementation DIMResetGroupCommand

- (instancetype)initWithGroup:(DIMID *)groupID
                      members:(NSArray<DIMID *> *)list {
    
    return [super initWithCommand:DIMGroupCommand_Reset group:groupID members:list];
}

@end

@implementation DIMQueryGroupCommand

- (instancetype)initWithGroup:(DIMID *)groupID {
    
    return [super initWithCommand:DIMGroupCommand_Query group:groupID];
}

@end
