//
//  DIMBroadcastCommand.m
//  DIMCore
//
//  Created by Albert Moky on 2019/3/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMBroadcastCommand.h"

@implementation DIMCommand (Broadcast)

- (NSString *)title {
    return [_storeDictionary objectForKey:@"title"];
}

@end

@implementation DIMBroadcastCommand

- (instancetype)initWithTitle:(const NSString *)title {
    if (self = [self initWithCommand:DIMSystemCommand_Broadcast]) {
        // title
        if (title) {
            [_storeDictionary setObject:title forKey:@"title"];
        }
    }
    return self;
}

@end
