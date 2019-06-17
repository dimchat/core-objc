//
//  DIMStation.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/13.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Compare.h"
#import "NSObject+JsON.h"

#import "DIMServiceProvider.h"

#import "DIMStation.h"

@interface DIMStation ()

@property (strong, nonatomic) NSString *host;
@property (nonatomic) UInt32 port;

@end

@implementation DIMStation

/* designated initializer */
- (instancetype)initWithID:(const DIMID *)ID {
    if (self = [super initWithID:ID]) {
        _host = nil;
        _port = 9394;
        _SP = nil;
        _CA = nil;
        _delegate = nil;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    // ID
    DIMID *ID = [dict objectForKey:@"ID"];
    ID = [DIMID IDWithID:ID];
//    // public key
//    DIMPublicKey *PK = [dict objectForKey:@"publicKey"];
//    if (!PK) {
//        PK = [dict objectForKey:@"PK"];
//        if (!PK) {
//            // get from meta.key
//            DIMMeta *meta = [dict objectForKey:@"meta"];
//            if (meta) {
//                meta = [DIMMeta metaWithMeta:meta];
//                PK = meta.key;
//            }
//        }
//    }
//    PK = [DIMPublicKey keyWithKey:PK];
    
    // host
    NSString *host = [dict objectForKey:@"host"];
    // port
    NSNumber *port = [dict objectForKey:@"port"];
    if (port == nil) {
        port = @(9394);
    }
    // SP
    id SP = [dict objectForKey:@"SP"];
    if ([SP isKindOfClass:[NSDictionary class]]) {
        SP = [[DIMServiceProvider alloc] initWithDictionary:SP];
    }
    // CA
    DIMCertificateAuthority *CA = [dict objectForKey:@"CA"];
    CA = [DIMCertificateAuthority caWithCA:CA];
    
//    if (!PK) {
//        // get from CA.info.publicKey
//        PK = CA.info.publicKey;
//    }
    // TODO: save public key for the Station
    
    if (self = [self initWithID:ID
                           host:host
                           port:[port unsignedIntValue]]) {
        _SP = SP;
        _CA = CA;
    }
    return self;
}

- (instancetype)initWithID:(const DIMID *)ID
                      host:(const NSString *)IP
                      port:(UInt32)port {
    if (self = [self initWithID:ID]) {
        _host = [IP copy];
        _port = port;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMStation *server = [super copyWithZone:zone];
    if (server) {
        server.host = _host;
        server.port = _port;
        server.SP = _SP;
        server.CA = _CA;
        server.delegate = _delegate;
    }
    return server;
}

- (NSString *)debugDescription {
    NSString *desc = [super debugDescription];
    NSData *data = [desc data];
    NSDictionary *dict = [data jsonDictionary];
    NSMutableDictionary *mDict = [dict mutableCopy];
    [mDict setObject:self.host forKey:@"host"];
    [mDict setObject:@(self.port) forKey:@"port"];
    return [mDict jsonString];
}

- (BOOL)isEqual:(id)object {
    DIMStation *server = (DIMStation *)object;
    if ([server.ID isEqual:_ID]) {
        return YES;
    }
    if (NSStringEquals(server.host, _host) && server.port == _port) {
        return YES;
    }
    return NO;
}

- (NSString *)name {
    DIMCASubject *subject = self.CA.info.subject;
    if (subject.commonName) {
        return subject.commonName;
    } else if (subject.organization) {
        return subject.organization;
    } else {
        return [super name];
    }
}

- (DIMPublicKey *)publicKey {
    return self.CA.info.publicKey;
}

- (NSURL *)home {
    return self.SP.home;
}

- (NSData *)encrypt:(const NSData *)plaintext {
    // 1. get key for encryption from CA.info.publicKey
    const MKMPublicKey *key = [self publicKey];
    if (key == nil) {
        // 2. get key for encryption from meta
        const MKMMeta *meta = [self meta];
        // NOTICE: meta.key will never changed,
        //         so use profile.key to encrypt is the better way
        key = [meta key];
    }
    // 3. encrypt with profile.key
    return [key encrypt:plaintext];
}

#pragma mark - DIMTransceiverDelegate

- (BOOL)sendPackage:(const NSData *)data completionHandler:(nullable DIMTransceiverCompletionHandler)handler {
    NSAssert(false, @"override me");
    return NO;
}

- (NSURL *)uploadEncryptedFileData:(const NSData *)CT forMessage:(const DKDInstantMessage *)iMsg {
    NSAssert(false, @"override me");
    return nil;
}

- (nullable NSData *)downloadEncryptedFileData:(const NSURL *)url forMessage:(const DKDInstantMessage *)iMsg {
    NSAssert(false, @"override me");
    return nil;
}

@end
