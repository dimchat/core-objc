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
#define DIMUserWithID(ID)        [[DIMFacebook sharedInstance] userWithID:(ID)]
#define DIMGroupWithID(ID)       [[DIMFacebook sharedInstance] groupWithID:(ID)]

@interface DIMFacebook : DIMBarrack

+ (instancetype)sharedInstance;

- (BOOL)savePrivateKey:(DIMPrivateKey *)SK forID:(DIMID *)ID;
- (BOOL)saveMeta:(DIMMeta *)meta forID:(DIMID *)ID;
- (BOOL)saveProfile:(DIMProfile *)profile;

@end
```

```objective-c
@implementation DIMFacebook

SingletonImplementations(DIMFacebook, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        // register new asymmetric cryptography key classes
        [MKMPrivateKey registerClass:[MKMECCPrivateKey class] forAlgorithm:ACAlgorithmECC];
        [MKMPublicKey registerClass:[MKMECCPublicKey class] forAlgorithm:ACAlgorithmECC];
        
        // register new address classes
        [MKMAddress registerClass:[MKMAddressETH class]];
        
        // register new meta classes
        [MKMMeta registerClass:[MKMMetaBTC class] forVersion:MKMMetaVersion_BTC];
        [MKMMeta registerClass:[MKMMetaBTC class] forVersion:MKMMetaVersion_ExBTC];
        [MKMMeta registerClass:[MKMMetaETH class] forVersion:MKMMetaVersion_ETH];
        [MKMMeta registerClass:[MKMMetaETH class] forVersion:MKMMetaVersion_ExETH];
    }
    return self;
}

- (BOOL)savePrivateKey:(DIMPrivateKey *)SK forID:(DIMID *)ID {
    return [SK saveKeyWithIdentifier:ID.address];
}

- (BOOL)saveMeta:(DIMMeta *)meta forID:(DIMID *)ID {
    if (![meta matchID:ID]) {
        NSAssert(false, @"meta not match ID: %@ -> %@", ID, meta);
        return NO;
    }
    // TODO: save meta to local/persistent storage
    return NO;
}

- (BOOL)saveProfile:(DIMProfile *)profile {
    if (![self verifyProfile:profile]) {
        // profile error
        return NO;
    }
    // TODO: save to local storage
    return NO;
}

- (BOOL)verifyProfile:(DIMProfile *)profile {
    if (!profile) {
        return NO;
    }
    DIMID *ID = profile.ID;
    NSAssert([ID isValid], @"Invalid ID: %@", ID);
    DIMMeta *meta = nil;
    // check signer
    if (MKMNetwork_IsUser(ID.type)) {
        // verify with user's meta.key
        meta = [self metaForID:ID];
    } else if (MKMNetwork_IsGroup(ID.type)) {
        // verify with group owner's meta.key
        DIMGroup *group = DIMGroupWithID(ID);
        meta = [self metaForID:group.owner];
    }
    return [profile verify:meta.key];
}

#pragma mark DIMBarrack

- (nullable DIMID *)createID:(NSString *)string {
    // try ANS record
    DIMID *ID = [self ansGet:string];
    if (ID) {
        return ID;
    }
    // create by Barrack
    return [super createID:string];
}

- (nullable DIMUser *)createUser:(DIMID *)ID {
    if ([ID isBroadcast]) {
        // create user 'anyone@anywhere'
        return [[DIMUser alloc] initWithID:ID];
    }
    if (![self metaForID:ID]) {
        //NSAssert(false, @"failed to get meta for user: %@", ID);
        return nil;
    }
    MKMNetworkType type = ID.type;
    if (MKMNetwork_IsPerson(type)) {
        return [[DIMUser alloc] initWithID:ID];
    }
    if (MKMNetwork_IsRobot(type)) {
        return [[DIMRobot alloc] initWithID:ID];
    }
    if (MKMNetwork_IsStation(type)) {
        return [[DIMStation alloc] initWithID:ID];
    }
    NSAssert(false, @"Unsupported user type: %d", type);
    return nil;
}

- (nullable DIMGroup *)createGroup:(DIMID *)ID {
    NSAssert(MKMNetwork_IsGroup(ID.type), @"group ID error: %@", ID);
    if ([ID isBroadcast]) {
        // create group 'everyone@everywhere'
        return [[DIMGroup alloc] initWithID:ID];
    }
    if (![self metaForID:ID]) {
        //NSAssert(false, @"failed to get meta for group: %@", ID);
        return nil;
    }
    MKMNetworkType type = ID.type;
    if (type == MKMNetwork_Polylogue) {
        return [[DIMPolylogue alloc] initWithID:ID];
    }
    if (type == MKMNetwork_Chatroom) {
        return [[DIMChatroom alloc] initWithID:ID];
    }
    if (MKMNetwork_IsProvider(type)) {
        return [[DIMServiceProvider alloc] initWithID:ID];
    }
    NSAssert(false, @"Unsupported group type: %d", type);
    return nil;
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
@interface DIMMessanger : DIMTransceiver <DIMConnectionDelegate>

@property (weak, nonatomic) id<DIMMessengerDelegate> delegate;

+ (instancetype)sharedInstance;

@end

@interface DIMMessenger (Send)

/**
 *  Send instant message (encrypt and sign) onto DIM network
 *
 *  @param iMsg - instant message
 *  @param callback - callback function
 *  @param split - if it's a group message, split it before sending out
 *  @return NO on data/delegate error
 */
- (BOOL)sendInstantMessage:(DIMInstantMessage *)iMsg
                  callback:(nullable DIMMessengerCallback)callback
               dispersedly:(BOOL)split;

@end
```

```objective-c
@implementation DIMMessanger

SingletonImplementations(DIMMessanger, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        // delegates
        _barrack = [DIMFacebook sharedInstance];
        _keyCache = [DIMKeyStore sharedInstance];
    }
    return self;
}

#pragma mark DKDInstantMessageDelegate

- (nullable NSData *)message:(DIMInstantMessage *)iMsg
              encryptContent:(DIMContent *)content
                     withKey:(NSDictionary *)password {
    DIMSymmetricKey *key = MKMSymmetricKeyFromDictionary(password);
    NSAssert(key == password, @"irregular symmetric key: %@", password);
    // check attachment for File/Image/Audio/Video message content
    if ([content isKindOfClass:[DIMFileContent class]]) {
        DIMFileContent *file = (DIMFileContent *)content;
        NSAssert(file.fileData != nil, @"content.fileData should not be empty");
        NSAssert(file.URL == nil, @"content.URL exists, already uploaded?");
        // encrypt and upload file data onto CDN and save the URL in message content
        NSData *CT = [key encrypt:file.fileData];
        NSURL *url = [_delegate uploadEncryptedFileData:CT forMessage:iMsg];
        if (url) {
            // replace 'data' with 'URL'
            file.URL = url;
            file.fileData = nil;
        }
        //[iMsg setObject:file forKey:@"content"];
    }
    return [super message:iMsg encryptContent:content withKey:key];
}

#pragma mark DKDSecureMessageDelegate

- (nullable DIMContent *)message:(DIMSecureMessage *)sMsg
                  decryptContent:(NSData *)data
                         withKey:(NSDictionary *)password {
    DIMSymmetricKey *key = MKMSymmetricKeyFromDictionary(password);
    NSAssert(key == password, @"irregular symmetric key: %@", password);
    DIMContent *content = [super message:sMsg decryptContent:data withKey:key];
    if (!content) {
        return nil;
    }
    // check attachment for File/Image/Audio/Video message content
    if ([content isKindOfClass:[DIMFileContent class]]) {
        DIMFileContent *file = (DIMFileContent *)content;
        NSAssert(file.URL != nil, @"content.URL should not be empty");
        NSAssert(file.fileData == nil, @"content.fileData already download");
        DIMInstantMessage *iMsg;
        iMsg = [[DIMInstantMessage alloc] initWithContent:content
                                                 envelope:sMsg.envelope];
        // download from CDN
        NSData *fileData = [_delegate downloadEncryptedFileData:file.URL
                                                     forMessage:iMsg];
        if (fileData) {
            // decrypt file data
            file.fileData = [key decrypt:fileData];
            file.URL = nil;
        } else {
            // save the symmetric key for decrypte file data later
            file.password = key;
        }
        //content = file;
    }
    return content;
}

#pragma mark DIMConnectionDelegate

- (nullable NSData *)onReceivePackage:(NSData *)data {
    DIMReliableMessage *rMsg = [self deserializeMessage:data];
    DIMContent *res = [self processMessage:rMsg];
    if (!res) {
        // nothing to response
        return nil;
    }
    DIMUser *user = [self currentUser];
    NSAssert(user, @"failed to get current user");
    DIMID *receiver = [_facebook IDWithString:rMsg.envelope.sender];
    DIMInstantMessage *iMsg;
    iMsg = [[DIMInstantMessage alloc] initWithContent:res
                                               sender:user.ID
                                             receiver:receiver
                                                 time:nil];
    DIMSecureMessage *sMsg = [self encryptMessage:iMsg];
    NSAssert(sMsg, @"failed to encrypt message: %@", iMsg);
    DIMReliableMessage *nMsg = [self signMessage:sMsg];
    NSAssert(nMsg, @"failed to sign message: %@", sMsg);
    return [self serializeMessage:nMsg];
}

- (nullable DIMContent *)processMessage:(DIMReliableMessage *)rMsg {
    // TODO: try to verify/decrypt message and process it
    return nil;
}

@end

@implementation DIMMessenger (Send)

- (BOOL)sendInstantMessage:(DIMInstantMessage *)iMsg
                  callback:(nullable DIMMessengerCallback)callback
               dispersedly:(BOOL)split {
    // Send message (secured + certified) to target station
    DIMSecureMessage *sMsg = [self encryptMessage:iMsg];
    DIMReliableMessage *rMsg = [self signMessage:sMsg];
    if (!rMsg) {
        NSAssert(false, @"failed to encrypt and sign message: %@", iMsg);
        iMsg.content.state = DIMMessageState_Error;
        iMsg.content.error = @"Encryption failed.";
        return NO;
    }
    
    DIMID *receiver = [self.facebook IDWithString:iMsg.envelope.receiver];
    BOOL OK = YES;
    if (split && MKMNetwork_IsGroup(receiver.type)) {
        NSAssert([receiver isEqual:iMsg.content.group], @"error: %@", iMsg);
        // split for each members
        NSArray<DIMID *> *members = [self.facebook membersOfGroup:receiver];
        NSAssert([members count] > 0, @"group members empty: %@", receiver);
        NSArray *messages = [rMsg splitForMembers:members];
        if ([members count] == 0) {
            NSLog(@"failed to split msg, send it to group: %@", receiver);
            OK = [self sendReliableMessage:rMsg callback:callback];
        } else {
            for (DIMReliableMessage *item in messages) {
                if (![self sendReliableMessage:item callback:callback]) {
                    OK = NO;
                }
            }
        }
    } else {
        OK = [self sendReliableMessage:rMsg callback:callback];
    }
    
    // sending status
    if (OK) {
        iMsg.content.state = DIMMessageState_Sending;
    } else {
        NSLog(@"cannot send message now, put in waiting queue: %@", iMsg);
        iMsg.content.state = DIMMessageState_Waiting;
    }
    if (![self saveMessage:iMsg]) {
        return NO;
    }
    return OK;
}

- (BOOL)sendReliableMessage:(DIMReliableMessage *)rMsg
                   callback:(nullable DIMMessengerCallback)callback {
    NSData *data = [self serializeMessage:rMsg];
    if (data) {
        NSAssert(_delegate, @"transceiver delegate not set");
        return [_delegate sendPackage:data
                    completionHandler:^(NSError * _Nullable error) {
                        !callback ?: callback(rMsg, error);
                    }];
    } else {
        NSAssert(false, @"message data error: %@", rMsg);
        return NO;
    }
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
    return [facebook userWithID:ID];
}
```

### Messaging

Send.m

```c
static inline DIMReliableMessage *pack(DIMContent *content, DIMID *sender, DIMID *receiver) {
    // 1. create InstantMessage
    DIMInstantMessasge *iMsg = DKDInstantMessageCreate(content, sender, receiver, nil);
    
    // 2. encrypt 'content' to 'data' for receiver
    DIMSecureMessage *sMsg = [messenger encryptMessage:iMsg];
    
    // 3. sign 'data' by sender
    DIMReliableMessage *rMsg = [messenger signMessage:sMsg];
    
    // OK
    return rMsg;
}

static inline void send(DIMContent *content, DIMID *sender, DIMID *receiver) {
    // 1. pack message
    DIMReliableMessage *rMsg = pack(content, sender, receiver);
    
    // 2. callback handler
    DIMMessengerCallback callback;
    callback = ^(DIMReliableMessage *rMsg, NSError *error) {
        NSString *name = nil;
        if (error) {
            NSLog(@"send message error: %@", error);
            name = kNotificationName_SendMessageFailed;
            content.state = DIMMessageState_Error;
            content.error = [error localizedDescription];
        } else {
            NSLog(@"sent message: %@ -> %@", content, rMsg);
            name = kNotificationName_MessageSent;
            content.state = DIMMessageState_Accepted;
        }
        
        NSDictionary *info = @{@"content": content};
        [NSNotificationCenter postNotificationName:name
                                            object:self
                                          userInfo:info];
    };
    
    // 3. encode and send out
    return [messenger sendReliableMessage:rMsg callback:callback];
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
static inline DIMContent *unpack(DIMReliableMessage *rMsg) {
    // 1. verify 'data' with 'signature'
    DIMSecureMessage *sMsg = [messenger verifyMessage:rMsg];
    
    // 2. check group message
    DIMID *receiver = [barrack IDWithString:sMsg.envelope.receiver];
    if (MKMNetwork_IsGroup(receiver.type)) {
        // TODO: split it
    }
    
    // 3. decrypt 'data' to 'content'
    DIMInstantMessage *iMsg = [messenger decryptMessage:sMsg];
    
    // OK
    return iMsg.content;
}

#pragma mark DIMStationDelegate

- (void)station:(DIMStation *)server didReceivePackage:(NSData *)data {
    // 1. decode message package
    DIMReliableMessage *rMsg = [self deserializeMessage:data];
    
    // 2. verify and decrypt message
    DIMContent *content = unpack(rMsg);
    
    // TODO: process message content
}
```

Copyright &copy; 2019 Albert Moky
