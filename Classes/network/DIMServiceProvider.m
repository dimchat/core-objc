//
//  DIMServiceProvider.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/13.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMStation.h"

#import "DIMServiceProvider.h"

@implementation DIMServiceProvider

/* designated initializer */
- (instancetype)initWithID:(DIMID *)ID {
    if (self = [super initWithID:ID]) {
        _CA = nil;
        _home = nil;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    // ID
    DIMID *ID = MKMIDFromString([dict objectForKey:@"ID"]);
//    // founder
//    DIMID *founder = [dict objectForKey:@"founder"];
//    founder = MKMIDFromString(founder);
//    // owner
//    DIMID *owner = [dict objectForKey:@"owner"];
//    owner = MKMIDFromString(owner);
    
    // CA
    DIMCertificateAuthority *CA = [dict objectForKey:@"CA"];
    CA = [DIMCertificateAuthority caWithCA:CA];
    // home
    id home = [dict objectForKey:@"home"];
    if ([home isKindOfClass:[NSString class]]) {
        home = [NSURL URLWithString:home];
    }
    
    if (self = [self initWithID:ID]) {
        _CA = CA;
        _home = home;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMServiceProvider *SP = [super copyWithZone:zone];
    if (SP) {
        SP.CA = _CA;
        SP.home = _home;
    }
    return SP;
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

#pragma mark Station

- (BOOL)verifyStation:(DIMStation *)server {
    DIMCertificateAuthority *CA = server.CA;
    return [CA verifyWithPublicKey:self.publicKey];
}

@end
