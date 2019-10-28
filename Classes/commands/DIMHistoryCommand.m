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

- (instancetype)initWithHistoryCommand:(NSString *)cmd {
    NSAssert(cmd.length > 0, @"command name cannot be empty");
    if (self = [super initWithType:DKDContentType_History]) {
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

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _time = nil;
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
    return [super classForCommand:cmd];
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
