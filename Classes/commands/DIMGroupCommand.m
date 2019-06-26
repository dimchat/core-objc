//
//  DIMGroupCommand.m
//  DIMCore
//
//  Created by Albert Moky on 2019/2/3.
//  Copyright © 2019 DIM Group. All rights reserved.
//

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

static NSMutableDictionary<NSString *, Class> *group_command_classes(void) {
    static NSMutableDictionary<NSString *, Class> *classes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classes = [[NSMutableDictionary alloc] init];
        // invite
        [classes setObject:[DIMInviteCommand class] forKey:DIMGroupCommand_Invite];
        // expel
        [classes setObject:[DIMExpelCommand class] forKey:DIMGroupCommand_Expel];
        // join
        [classes setObject:[DIMJoinCommand class] forKey:DIMGroupCommand_Join];
        // quit
        [classes setObject:[DIMQuitCommand class] forKey:DIMGroupCommand_Quit];
        // reset
        [classes setObject:[DIMResetGroupCommand class] forKey:@"reset"];
        // query
        [classes setObject:[DIMQueryGroupCommand class] forKey:@"query"];
    });
    return classes;
}

@implementation DIMGroupCommand (Runtime)

+ (void)registerClass:(nullable Class)cmdClass forCommand:(NSString *)cmd {
    NSAssert(![cmdClass isEqual:self], @"only subclass");
    NSAssert([cmdClass isSubclassOfClass:self], @"class error: %@", cmdClass);
    if (cmdClass) {
        [group_command_classes() setObject:cmdClass forKey:cmd];
    } else {
        [group_command_classes() removeObjectForKey:cmd];
    }
}

+ (nullable instancetype)getInstance:(id)content {
    if (!content) {
        return nil;
    }
    if ([content isKindOfClass:[DIMGroupCommand class]]) {
        // return GroupCommand object directly
        return content;
    }
    NSAssert([content isKindOfClass:[NSDictionary class]],
             @"group command should be a dictionary: %@", content);
    if (![self isEqual:[DIMGroupCommand class]]) {
        // subclass
        NSAssert([self isSubclassOfClass:[DIMGroupCommand class]],
                 @"cmd class error");
        return [[self alloc] initWithDictionary:content];
    }
    // create instance by subclass with group command
    NSString *command = [content objectForKey:@"command"];
    Class clazz = [group_command_classes() objectForKey:command];
    if (clazz) {
        return [clazz getInstance:content];
    } else {
        return [[self alloc] initWithDictionary:content];
    }
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
    
    return [super initWithCommand:@"reset" group:groupID members:list];
}

@end

@implementation DIMQueryGroupCommand

- (instancetype)initWithGroup:(DIMID *)groupID {
    
    return [super initWithCommand:@"query" group:groupID];
}

@end
