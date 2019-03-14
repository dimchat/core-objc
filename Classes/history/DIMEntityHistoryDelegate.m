//
//  DIMEntityHistoryDelegate.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/6.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"

#import "DIMHistoryOperation.h"
#import "DIMHistoryTransaction.h"
#import "DIMHistoryBlock.h"
#import "DIMHistory.h"

#import "DIMBarrack.h"

#import "DIMEntityHistoryDelegate.h"

@implementation DIMEntityHistoryDelegate

- (BOOL)evolvingEntity:(const DIMEntity *)entity
        canWriteRecord:(const DIMHistoryBlock *)record {
    NSAssert([record.recorder isValid], @"recorder error: %@", record.recorder);
    
    // hash(record.events)
    NSData *hash = record.merkleRoot;
    NSAssert(hash, @"merkle root cannot be empty");
    
    // signature
    NSData *CT = record.signature;
    NSAssert(CT, @"signature cannot be empty");
    
    // check signature for this record
    DIMPublicKey *PK = DIMPublicKeyForID(record.recorder);
    if (![PK verify:hash withSignature:CT]) {
        NSAssert(false, @"signature not match the hash data with key: %@", PK);
        return NO;
    }
    
    // let the subclass to define the permissions
    return YES;
}

- (BOOL)evolvingEntity:(const DIMEntity *)entity
           canRunEvent:(const DIMHistoryTransaction *)event
              recorder:(const DIMID *)recorder {
    NSAssert([recorder isValid], @"recorder error: %@", recorder);
    
    if (event.commander == nil || [event.commander isEqual:recorder]) {
        // no need to verify signature when commander is the history recorder
        // and if event.commander not set, it means the recorder is commander
        NSAssert(event.signature == nil, @"event error: %@", event);
        return YES;
    }
    NSAssert([event.commander isValid], @"commander error: %@", event.commander);
    
    // operation
    id op = event.operation;
    NSData *data;
    if ([op isKindOfClass:[NSString class]]) {
        data = [op data];
    } else {
        NSAssert(false, @"operation error");
        data = [op jsonData];
    }
    
    // signature
    NSAssert(event.signature, @"signature error");
    
    // check signature for this event
    DIMPublicKey *PK = DIMPublicKeyForID(event.commander);
    if (![PK verify:data withSignature:event.signature]) {
        NSAssert(false, @"signature error");
        return NO;
    }
    
    // let the subclass to define the permissions
    return YES;
}

- (void)evolvingEntity:(DIMEntity *)entity
               execute:(const DIMHistoryOperation *)operation
             commander:(const DIMID *)commander {
    NSAssert([commander isValid], @"commander error: %@", commander);
    // let the subclass to do the operating
    return ;
}

@end
