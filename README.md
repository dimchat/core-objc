# Decentralized Instant Messaging Protocol (Objective-C)

[![License](https://img.shields.io/github/license/dimchat/core-objc)](https://github.com/dimchat/core-objc/blob/master/LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/dimchat/core-objc/pulls)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20OSX%20%7C%20watchOS%20%7C%20tvOS-brightgreen.svg)](https://github.com/dimchat/core-objc/wiki)
[![Issues](https://img.shields.io/github/issues/dimchat/core-objc)](https://github.com/dimchat/core-objc/issues)
[![Repo Size](https://img.shields.io/github/repo-size/dimchat/core-objc)](https://github.com/dimchat/core-objc/archive/refs/heads/master.zip)
[![Tags](https://img.shields.io/github/tag/dimchat/core-objc)](https://github.com/dimchat/core-objc/tags)
[![Version](https://img.shields.io/cocoapods/v/DIMCore
)](https://cocoapods.org/pods/DIMCore)

[![Watchers](https://img.shields.io/github/watchers/dimchat/core-objc)](https://github.com/dimchat/core-objc/watchers)
[![Forks](https://img.shields.io/github/forks/dimchat/core-objc)](https://github.com/dimchat/core-objc/forks)
[![Stars](https://img.shields.io/github/stars/dimchat/core-objc)](https://github.com/dimchat/core-objc/stargazers)
[![Followers](https://img.shields.io/github/followers/dimchat)](https://github.com/orgs/dimchat/followers)

## Dependencies

| Name | Version | Description |
|------|---------|-------------|
| [Ming Ke Ming (名可名)](https://github.com/dimchat/mkm-objc) | [![Version](https://img.shields.io/cocoapods/v/MingKeMing)](https://cocoapods.org/pods/MingKeMing) | Decentralized User Identity Authentication |
| [Dao Ke Dao (道可道)](https://github.com/dimchat/dkd-objc) | [![Version](https://img.shields.io/cocoapods/v/DaoKeDao)](https://cocoapods.org/pods/DaoKeDao) | Universal Message Module |

## Examples

### Extends Command

* _Handshake Command Protocol_
  0. (C-S) handshake start
  1. (S-C) handshake again with new session
  2. (C-S) handshake restart with new session
  3. (S-C) handshake success

```objective-c
#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

#define DKDCommand_Handshake @"handshake"

typedef NS_ENUM(UInt8, DKDHandshakeState) {
    DKDHandshake_Init,
    DKDHandshake_Start,   // C -> S, without session key(or session expired)
    DKDHandshake_Again,   // S -> C, with new session key
    DKDHandshake_Restart, // C -> S, with new session key
    DKDHandshake_Success, // S -> C, handshake accepted
};

#ifdef __cplusplus
extern "C" {
#endif

DKDHandshakeState DKDHandshakeCheckState(NSString *title, NSString *_Nullable session);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

/*
 *  Command message: {
 *      type : 0x88,
 *      sn   : 123,
 *
 *      command : "handshake",    // command name
 *      title   : "Hello world!",
 *      session : "{SESSION_KEY}" // session key
 *  }
 */
@protocol DKDHandshakeCommand <DKDCommand>

@property (readonly, strong, nonatomic) NSString *title;
@property (readonly, strong, nonatomic, nullable) NSString *sessionKey;

@property (readonly, nonatomic) DKDHandshakeState state;

@end

@interface DIMHandshakeCommand : DIMCommand <DKDHandshakeCommand>

- (instancetype)initWithTitle:(NSString *)title
                   sessionKey:(nullable NSString *)session;

- (instancetype)initWithSessionKey:(nullable NSString *)session;

@end

NS_ASSUME_NONNULL_END
```

```objective-c
#import "DIMHandshakeCommand.h"

DKDHandshakeState DKDHandshakeCheckState(NSString *title, NSString *_Nullable session) {
    if ([title isEqualToString:@"DIM!"]/* || [title isEqualToString:@"OK!"]*/) {
        return DKDHandshake_Success;
    } else if ([title isEqualToString:@"DIM?"]) {
        return DKDHandshake_Again;
    } else if ([session length] == 0) {
        return DKDHandshake_Start;
    } else {
        return DKDHandshake_Restart;
    }
}

@interface DIMHandshakeCommand ()

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic, nullable) NSString *sessionKey;

@property (nonatomic) DKDHandshakeState state;

@end

@implementation DIMHandshakeCommand

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _title = nil;
        _sessionKey = nil;
        _state = DKDHandshake_Init;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithType:(NSString *)type {
    if (self = [super initWithType:type]) {
        _title = nil;
        _sessionKey = nil;
        _state = DKDHandshake_Init;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
                   sessionKey:(nullable NSString *)session {
    if (self = [self initWithCmd:DKDCommand_Handshake]) {
        // title
        if (title) {
            [self setObject:title forKey:@"title"];
        }
        _title = title;
        
        // session key
        if (session) {
            [self setObject:session forKey:@"session"];
        }
        _sessionKey = session;
        
        _state = DKDHandshake_Init;
    }
    return self;
}

- (instancetype)initWithSessionKey:(nullable NSString *)session {
    return [self initWithTitle:@"Hello world!" sessionKey:session];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMHandshakeCommand *content = [super copyWithZone:zone];
    if (content) {
        content.title = _title;
        content.sessionKey = _sessionKey;
        content.state = _state;
    }
    return content;
}

- (NSString *)title {
    if (!_title) {
        _title = [self objectForKey:@"title"];
    }
    return _title;
}

- (nullable NSString *)sessionKey {
    if (!_sessionKey) {
        _sessionKey = [self objectForKey:@"session"];
    }
    return _sessionKey;
}

- (DKDHandshakeState)state {
    if (_state == DKDHandshake_Init) {
        _state = DKDHandshakeCheckState(self.title, self.sessionKey);
    }
    return _state;
}

@end
```

### Extends Content

```objective-c
#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

/*
 *  Content for Application 0nly: {
 *      type : i2s(0xA0),
 *      sn   : 123,
 *
 *      app   : "{APP_ID}",  // application (e.g.: "chat.dim.sechat")
 *      extra : info         // others
 *  }
 */
@interface DIMApplicationContent : DIMContent <DKDAppContent>

- (instancetype)initWithApplication:(NSString *)app;

@end

NS_ASSUME_NONNULL_END
```

```objective-c
#import "DIMApplicationContent.h"

@implementation DIMApplicationContent

- (instancetype)initWithApplication:(NSString *)app {
    if (self = [self initWithType:DKDContentType_Application]) {
        [self setObject:app forKey:@"app"];
    }
    return self;
}

- (NSString *)application {
    return [self stringForKey:@"app" defaultValue:@""];
}

@end
```

### Extends ID Address

* Examples in [DIMPlugins](https://cocoapods.org/pods/DIMPlugins)

----

Copyright &copy; 2018-2025 Albert Moky
[![Followers](https://img.shields.io/github/followers/moky)](https://github.com/moky?tab=followers)
