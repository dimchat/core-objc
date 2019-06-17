//
//  DIMHandshakeCommand.h
//  DIMCore
//
//  Created by Albert Moky on 2019/1/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMCommand.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(UInt8, DIMHandshakeState) {
    DIMHandshake_Init,
    DIMHandshake_Start,   // C -> S, without session key(or session expired)
    DIMHandshake_Again,   // S -> C, with new session key
    DIMHandshake_Restart, // C -> S, with new session key
    DIMHandshake_Success, // S -> C, handshake accepted
};

@interface DIMCommand (Handshake)

@property (readonly, strong, nonatomic) NSString *message;
@property (readonly, strong, nonatomic, nullable) NSString *sessionKey;

@property (readonly, nonatomic) DIMHandshakeState state;

@end

@interface DIMHandshakeCommand : DIMCommand

/**
 *  Command message: {
 *      type : 0x88,
 *      sn   : 123,
 *
 *      command : "handshake",    // command name
 *      message : "Hello world!",
 *      session : "{SESSION_KEY}" // session key
 *  }
 */
- (instancetype)initWithMessage:(const NSString *)message
                     sessionKey:(nullable const NSString *)session;

- (instancetype)initWithSessionKey:(nullable const NSString *)session;

@end

NS_ASSUME_NONNULL_END
