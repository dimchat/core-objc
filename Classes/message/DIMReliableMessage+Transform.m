//
//  DIMReliableMessage+Transform.m
//  DIMCore
//
//  Created by Albert Moky on 2018/12/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMBarrack.h"

#import "DIMReliableMessage+Transform.h"

@implementation DIMReliableMessage (Transform)

- (DIMSecureMessage *)verify {
    const DIMID *sender = [DIMID IDWithID:self.envelope.sender];
    NSAssert(MKMNetwork_IsCommunicator(sender.type), @"sender error: %@", sender);
    
    // 1. verify the signature with public key
    DIMPublicKey *PK = DIMPublicKeyForID(sender);
    if (!PK) {
        // first contact, try meta in message package
        const DIMMeta *meta = [DIMMeta metaWithMeta:self.meta];
        if ([meta matchID:sender]) {
            PK = meta.key;
        }
    }
    if (![PK verify:self.data withSignature:self.signature]) {
        //NSAssert(false, @"signature error: %@", self);
        return nil;
    }
    
    // 2. create secure message
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithDictionary:self];
    [mDict removeObjectForKey:@"signature"];
    return [[DIMSecureMessage alloc] initWithDictionary:mDict];
}

@end
