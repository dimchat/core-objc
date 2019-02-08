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

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _message = nil;
        _sessionKey = nil;
        _state = DIMHandshake_Init;
    }
    return self;
}

- (instancetype)initWithMessage:(const NSString *)message
                     sessionKey:(nullable const NSString *)session {
    if (self = [self initWithCommand:@"handshake"]) {
        // message
        if (message) {
            [_storeDictionary setObject:message forKey:@"message"];
        }
        _message = nil; // lazy
        // session key
        if (session) {
            [_storeDictionary setObject:session forKey:@"session"];
        }
        _sessionKey = nil; // lazy
        // state
        if (session) {
            _state = DIMHandshake_Restart;
        } else {
            _state = DIMHandshake_Start;
        }
    }
    return self;
}

- (instancetype)initWithSessionKey:(nullable const NSString *)session {
    return [self initWithMessage:@"Hello world!" sessionKey:session];
}

- (id)copyWithZone:(NSZone *)zone {
    DIMHandshakeCommand *command = [super copyWithZone:zone];
    if (command) {
        command.message = _message;
        command.sessionKey = _sessionKey;
        command.state = _state;
    }
    return command;
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
    if (_state == DIMHandshake_Init) {
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
    }
    return _state;
}

@end
