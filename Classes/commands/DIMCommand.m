//
//  DIMCommand.m
//  DIMCore
//
//  Created by Albert Moky on 2019/1/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSDate+Timestamp.h"

#import "DIMContentType.h"

#import "DIMCommand.h"

@implementation DIMContent (Command)

- (NSString *)command {
    return [_storeDictionary objectForKey:@"command"];
}

@end

@implementation DIMCommand

- (instancetype)initWithCommand:(const NSString *)cmd {
    NSAssert(cmd.length > 0, @"command name cannot be empty");
    if (self = [self initWithType:DIMContentType_Command]) {
        // command
        if (cmd) {
            [_storeDictionary setObject:cmd forKey:@"command"];
        }
    }
    return self;
}

@end

#pragma mark -

@implementation DIMCommand (History)

- (NSDate *)time {
    NSNumber *timestamp = [_storeDictionary objectForKey:@"time"];
    NSAssert(timestamp != nil, @"time error: %@", _storeDictionary);
    return NSDateFromNumber(timestamp);
}

@end

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

@end
