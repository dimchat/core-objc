//
//  DIMHistoryCommand.m
//  DIMCore
//
//  Created by Albert Moky on 2019/1/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSDate+Timestamp.h"

#import "DIMContentType.h"

#import "DIMGroupCommand.h"

#import "DIMHistoryCommand.h"

@implementation DIMHistoryCommand

- (instancetype)initWithHistoryCommand:(const NSString *)cmd {
    NSAssert(cmd.length > 0, @"command name cannot be empty");
    if (self = [super initWithType:DIMContentType_History]) {
        // command
        if (cmd) {
            [_storeDictionary setObject:cmd forKey:@"command"];
        }
        // time
        NSDate *time = [[NSDate alloc] init];
        NSNumber *timestemp = NSNumberFromDate(time);
        [_storeDictionary setObject:timestemp forKey:@"time"];
    }
    return self;
}

- (NSDate *)time {
    NSNumber *timestamp = [_storeDictionary objectForKey:@"time"];
    NSAssert(timestamp != nil, @"time error: %@", _storeDictionary);
    return NSDateFromNumber(timestamp);
}

@end

@implementation DIMHistoryCommand (Runtime)

+ (nullable instancetype)getInstance:(id)content {
    if (!content) {
        return nil;
    }
    if ([content isKindOfClass:[DIMHistoryCommand class]]) {
        // return HistoryCommand object directly
        return content;
    }
    NSAssert([content isKindOfClass:[NSDictionary class]],
             @"history command should be a dictionary: %@", content);
    
    NSString *group = [content objectForKey:@"group"];
    if (group) {
        // group history command
        return [DIMGroupCommand getInstance:content];
    }
    
    NSAssert(false, @"unsupport history command: %@", content);
    return [[self alloc] initWithDictionary:content];
}

@end
