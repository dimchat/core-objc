//
//  DIMHandshakeCommand.m
//  DIMCore
//
//  Created by Albert Moky on 2019/1/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMHandshakeCommand.h"

@interface DIMHandshakeCommand ()

@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic, nullable) NSString *sessionKey;

@property (nonatomic) DIMHandshakeState state;

@end

@implementation DIMHandshakeCommand

- (instancetype)initWithMessage:(NSString *)message
                     sessionKey:(nullable NSString *)session {
    if (self = [self initWithCommand:DIMSystemCommand_Handshake]) {
        // message
        if (message) {
            [_storeDictionary setObject:message forKey:@"message"];
        }
        _message = message;
        
        // session key
        if (session) {
            [_storeDictionary setObject:session forKey:@"session"];
        }
        _sessionKey = session;
        
        _state = DIMHandshake_Init;
    }
    return self;
}

- (instancetype)initWithSessionKey:(nullable NSString *)session {
    return [self initWithMessage:@"Hello world!" sessionKey:session];
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _message = nil;
        _sessionKey = nil;
        _state = DIMHandshake_Init;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMHandshakeCommand *cmd = [[self class] allocWithZone:zone];
    cmd = [cmd initWithDictionary:_storeDictionary];
    if (cmd) {
        cmd.message = _message;
        cmd.sessionKey = _sessionKey;
        cmd.state = _state;
    }
    return cmd;
}

- (NSString *)message {
    if (!_message) {
        _message = [_storeDictionary objectForKey:@"message"];
    }
    return _message;
}

- (nullable NSString *)sessionKey {
    if (!_sessionKey) {
        _sessionKey = [_storeDictionary objectForKey:@"session"];
    }
    return _sessionKey;
}

- (DIMHandshakeState)state {
    if (_state != DIMHandshake_Init) {
        return _state;
    }
    NSString *msg = self.message;
    if ([msg isEqualToString:@"DIM!"] || [msg isEqualToString:@"OK!"]) {
        _state = DIMHandshake_Success;
    } else if ([msg isEqualToString:@"DIM?"]) {
        _state = DIMHandshake_Again;
    } else if (self.sessionKey) {
        _state = DIMHandshake_Restart;
    } else {
        _state = DIMHandshake_Start;
    }
    return _state;
}

@end
