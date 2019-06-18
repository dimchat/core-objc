//
//  DIMHandshakeCommand.m
//  DIMCore
//
//  Created by Albert Moky on 2019/1/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMHandshakeCommand.h"

@implementation DIMHandshakeCommand

- (instancetype)initWithMessage:(const NSString *)message
                     sessionKey:(nullable const NSString *)session {
    if (self = [self initWithCommand:DIMSystemCommand_Handshake]) {
        // message
        if (message) {
            [_storeDictionary setObject:message forKey:@"message"];
        }
        // session key
        if (session) {
            [_storeDictionary setObject:session forKey:@"session"];
        }
    }
    return self;
}

- (instancetype)initWithSessionKey:(nullable const NSString *)session {
    return [self initWithMessage:@"Hello world!" sessionKey:session];
}

- (NSString *)message {
    return [_storeDictionary objectForKey:@"message"];
}

- (nullable NSString *)sessionKey {
    return [_storeDictionary objectForKey:@"session"];
}

- (DIMHandshakeState)state {
    NSString *msg = self.message;
    if ([msg isEqualToString:@"DIM!"] || [msg isEqualToString:@"OK!"]) {
        return DIMHandshake_Success;
    } else if ([msg isEqualToString:@"DIM?"]) {
        return DIMHandshake_Again;
    } else if (self.sessionKey) {
        return DIMHandshake_Restart;
    } else {
        return DIMHandshake_Start;
    }
}

@end
