//
//  DIMBroadcastCommand.m
//  DIMCore
//
//  Created by Albert Moky on 2019/3/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMBroadcastCommand.h"

@interface DIMBroadcastCommand ()

@property (strong, nonatomic) NSString *title;

@end

@implementation DIMBroadcastCommand

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _title = nil;
    }
    return self;
}

- (instancetype)initWithCommand:(const NSString *)cmd {
    if (self = [super initWithCommand:cmd]) {
        // lazy
        _title = nil;
    }
    return self;
}

- (instancetype)initWithTitle:(const NSString *)title {
    if (self = [self initWithCommand:DKDSystemCommand_Broadcast]) {
        // title
        if (title) {
            [_storeDictionary setObject:title forKey:@"title"];
        }
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMBroadcastCommand *command = [super copyWithZone:zone];
    if (command) {
        command.title = _title;
    }
    return self;
}

- (NSString *)title {
    if (!_title) {
        _title = [_storeDictionary objectForKey:@"title"];
    }
    return _title;
}

@end
