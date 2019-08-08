# Decentralized Instant Messaging Protocol (Objective-C)

[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/dimchat/core-objc/blob/master/LICENSE)
[![Version](https://img.shields.io/badge/alpha-0.1.0-red.svg)](https://github.com/dimchat/core-objc/archive/master.zip)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/dimchat/core-objc/pulls)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20OSX%20%7C%20watchOS%20%7C%20tvOS-brightgreen.svg)](https://github.com/dimchat/core-objc/wiki)

## Talk is cheap, show you the codes!

### Dependencies

```shell
git clone https://github.com/dimchat/core-objc.git
git clone https://github.com/dimchat/dkd-objc.git
git clone https://github.com/dimchat/mkm-objc.git
```

### Common Extensions

Facebook.h/m

```objective-c
#define DIMMetaForID(ID)         [[DIMFacebook sharedInstance] metaForID:(ID)]
#define DIMProfileForID(ID)      [[DIMFacebook sharedInstance] profileForID:(ID)]

#define DIMIDWithString(ID)      [[DIMFacebook sharedInstance] IDWithString:(ID)]
#define DIMAccountWithID(ID)     [[DIMFacebook sharedInstance] accountWithID:(ID)]
#define DIMUserWithID(ID)        [[DIMFacebook sharedInstance] userWithID:(ID)]
#define DIMGroupWithID(ID)       [[DIMFacebook sharedInstance] groupWithID:(ID)]

@interface DIMFacebook : DIMBarrack

+ (instancetype)sharedInstance;

- (BOOL)savePrivateKey:(DIMPrivateKey *)SK forID:(DIMID *)ID;
- (BOOL)saveProfile:(DIMProfile *)profile;

@end
```

```objective-c
@implementation DIMFacebook

SingletonImplementations(DIMFacebook, sharedInstance)

- (BOOL)verifyProfile:(DIMProfile *)profile {
    if (!profile) {
        return NO;
    } else if ([profile isValid]) {
        // already verified
        return YES;
    }
    DIMID *ID = profile.ID;
    NSAssert([ID isValid], @"Invalid ID: %@", ID);
    DIMMeta *meta = nil;
    // check signer
    if (MKMNetwork_IsCommunicator(ID.type)) {
        // verify with account's meta.key
        meta = [self metaForID:ID];
    } else if (MKMNetwork_IsGroup(ID.type)) {
        // verify with group owner's meta.key
        DIMGroup *group = DIMGroupWithID(ID);
        DIMID *owner = group.owner;
        if ([owner isValid]) {
            meta = [self metaForID:owner];
        }
    }
    return [profile verify:meta.key];
}

- (BOOL)saveProfile:(DIMProfile *)profile {
    if (![self verifyProfile:profile]) {
        // profile error
        return NO;
    }
    // TODO: save to local storage
    return NO;
}

- (BOOL)savePrivateKey:(DIMPrivateKey *)SK forID:(DIMID *)ID {
    return [SK saveKeyWithIdentifier:ID.address];
}

#pragma mark - DIMSocialNetworkDataSource

- (nullable DIMAccount *)accountWithID:(DIMID *)ID {
    DIMAccount *account = [super accountWithID:ID];
    if (account) {
        return account;
    }
    // check meta
    DIMMeta *meta = DIMMetaForID(ID);
    if (!meta) {
        NSLog(@"meta not found: %@", ID);
        return nil;
    }
    // create it with type
    if (MKMNetwork_IsStation(ID.type)) {
        account = [[DIMServer alloc] initWithID:ID];
    } else if (MKMNetwork_IsPerson(ID.type)) {
        account = [[DIMAccount alloc] initWithID:ID];
    }
    NSAssert(account, @"account error: %@", ID);
    [self cacheAccount:account];
    return account;
}

- (nullable DIMUser *)userWithID:(DIMID *)ID {
    if (!MKMNetwork_IsPerson(ID.type)) {
        return nil;
    }
    DIMUser *user = [super userWithID:ID];
    if (user) {
        return user;
    }
    // check meta and private key
    DIMMeta *meta = DIMMetaForID(ID);
    DIMPrivateKey *key = [self privateKeyForSignatureOfUser:ID];
    if (!meta || !key) {
        NSLog(@"meta/private key not found: %@", ID);
        return nil;
    }
    // create it
    user = [[DIMUser alloc] initWithID:ID];
    [self cacheUser:user];
    return user;
}

- (nullable DIMGroup *)groupWithID:(DIMID *)ID {
    DIMGroup *group = [super groupWithID:ID];
    if (group) {
        return group;
    }
    // check meta
    DIMMeta *meta = DIMMetaForID(ID);
    if (!meta) {
        NSLog(@"meta not found: %@", ID);
        return nil;
    }
    // create it with type
    if (ID.type == MKMNetwork_Polylogue) {
        group = [[DIMPolylogue alloc] initWithID:ID];
    } else if (ID.type == MKMNetwork_Chatroom) {
        group = [[DIMChatroom alloc] initWithID:ID];
    }
    NSAssert(group, @"group error: %@", ID);
    [self cacheGroup:group];
    return group;
}

@end
```

KeyStore.h/m

```objective-c
@interface DIMKeyStore : DIMKeyCache

+ (instancetype)sharedInstance;

@end
```

```objective-c
@implementation DIMKeyStore

SingletonImplementations(DIMKeyStore, sharedInstance)

- (BOOL)saveKeys:(NSDictionary *)keyMap {
    // TODO: save to local cache
    return NO;
}

- (NSDictionary *)loadKeys {
    // TODO: load from local cache
    return nil;
}

@end
```

Messanger.h/m

```objective-c
@interface DIMMessanger : DIMTransceiver

+ (instancetype)sharedInstance;

@end
```

```objective-c
@implementation DIMMessanger

SingletonImplementations(DIMMessanger, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        // register all content classes
        [DIMContent loadContentClasses];
        
        // register new address classes
        [MKMAddress registerClass:[MKMAddressETH class]];
        
        // register new meta classes
        [MKMMeta registerClass:[MKMMetaBTC class] forVersion:MKMMetaVersion_BTC];
        [MKMMeta registerClass:[MKMMetaBTC class] forVersion:MKMMetaVersion_ExBTC];
        [MKMMeta registerClass:[MKMMetaETH class] forVersion:MKMMetaVersion_ETH];
        [MKMMeta registerClass:[MKMMetaETH class] forVersion:MKMMetaVersion_ExETH];
        
        // delegates
        _barrack = [DIMFacebook sharedInstance];
        _keyCache = [DIMKeyStore sharedInstance];
    }
    return self;
}

@end
```

### User Account

Register.m

```c
static inline DIMUser *register(NSString *username) {
    // 1. generate private key
    DIMPrivateKey *SK = MKMPrivateKeyWithAlgorithm(ACAlgorithmRSA);
    
    // 2. generate meta with username(as seed) and private key
    DIMMeta *meta = MKMMetaGenerate(MKMMetaDefaultVersion, SK, username);
    
    // 3. generate ID with network type by meta
    DIMID *ID = [meta generateID:MKMNetwork_Main];
    
    // 4. save private key and meta info
    [facebook savePrivateKey:SK forID:ID];
    [facebook saveMeta:meta forID:ID];
    
    // 5. create user with ID
    return DIMUserWithID(ID);
}
```

### Messaging

Send.m

```c
static inline DIMReliableMessage *pack(DIMContent *content, DIMID *sender, DIMID *receiver) {
    DIMInstantMessasge *iMsg = DKDInstantMessageCreate(content, sender, receiver, nil);
    return [messanger encryptAndSignMessage:iMsg];
}

static inline void send(DIMContent *content, DIMID *sender, DIMID *receiver) {
    DIMInstantMessasge *iMsg = DKDInstantMessageCreate(content, sender, receiver, nil);
    // callback
    DIMTransceiverCallback callback;
    callback = ^(DKDReliableMessage *rMsg, NSError *error) {
        if (error) {
            NSLog(@"send message error: %@", error);
            //iMsg.state = DIMMessageState_Error;
            //iMsg.error = [error localizedDescription];
        } else {
            NSLog(@"sent message: %@ -> %@", iMsg, rMsg);
            //iMsg.state = DIMMessageState_Accepted;
        }
    };
    // send out
    [messanger sendInstantMessage:iMsg callback:callback dispersedly:YES];
}

void test() {
    DIMID *moki = DIMIDWithString(@"moki@4WDfe3zZ4T7opFSi3iDAKiuTnUHjxmXekk");
    DIMID *hulk = DIMIDWithString(@"hulk@4YeVEN3aUnvC1DNUufCq1bs9zoBSJTzVEj");
    
    DIMContent *content = [[DIMTextContent alloc] initWithText:@"Hello world!"];
    send(content, moki, hulk);
}
```

Receive.m

```objective-c
#pragma mark DIMStationDelegate

- (void)station:(DIMStation *)server didReceivePackage:(NSData *)data {
    // decode to reliable message
    NSDictionary *dict = [data jsonDictionary];
    DIMReliableMessage *rMsg = DKDReliableMessageFromDictionary(dict);
    DIMInstantMessage *iMsg = [messanger verifyAndDecryptMessage:rMsg];
    // TODO: process message content
}
```

Copyright &copy; 2018 Albert Moky
