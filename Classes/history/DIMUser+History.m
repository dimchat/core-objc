//
//  DIMUser+History.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMHistoryOperation.h"
#import "DIMHistoryTransaction.h"
#import "DIMHistoryBlock.h"
#import "DIMHistory.h"

#import "DIMConsensus.h"

#import "DIMUser+History.h"

@implementation DIMUser (History)

- (DIMHistoryBlock *)registerWithMessage:(nullable const NSString *)hello {
    NSAssert(self.privateKey, @"private key not set");
    
    DIMHistoryBlock *record;
    DIMHistoryTransaction *event;
    DIMHistoryOperation *op;
    
    // create operation with command: "register"
    op = [[DIMHistoryOperation alloc] initWithCommand:@"register" time:nil];
    if (hello.length > 0) {
        [op setObject:hello forKey:@"message"];
    }
    
    // create event(Transaction) with operation
    event = [[DIMHistoryTransaction alloc] initWithOperation:op];
    
    // create record(Block) with events
    NSData *hash = nil;
    NSData *CT = nil;
    record = [[DIMHistoryBlock alloc] initWithTransactions:@[event]
                                                    merkle:hash
                                                 signature:CT
                                                  recorder:self.ID];
    [record signWithPrivateKey:self.privateKey];
    
    return record;
}

- (DIMHistoryBlock *)suicideWithMessage:(nullable const NSString *)lastWords {
    NSAssert(self.privateKey, @"private key not set");
    
    DIMHistory *history = DIMHistoryForID(_ID);
    DIMHistoryBlock *lastBlock = history.blocks.lastObject;
    lastBlock = [DIMHistoryBlock blockWithBlock:lastBlock];
    NSData *CT = lastBlock.signature;
    NSAssert(CT, @"last block error: %@", lastBlock);
    
    DIMHistoryBlock *record;
    DIMHistoryTransaction *ev1, *ev2;
    DIMHistoryOperation *op1, *op2;
    
    // create event1(Transaction) with operation: "link"
    op1 = [[DIMHistoryOperation alloc] initWithPreviousSignature:CT time:nil];
    ev1 = [[DIMHistoryTransaction alloc] initWithOperation:op1];
    
    // create event2(Transaction) with operation: "suicide"
    op2 = [[DIMHistoryOperation alloc] initWithCommand:@"suicide" time:nil];
    if (lastWords.length > 0) {
        [op2 setObject:lastWords forKey:@"message"];
    }
    ev2 = [[DIMHistoryTransaction alloc] initWithOperation:op2];
    
    // create record(Block) with events
    NSData *hash = nil;
    CT = nil;
    record = [[DIMHistoryBlock alloc] initWithTransactions:@[ev1, ev2]
                                                    merkle:hash
                                                 signature:CT
                                                  recorder:self.ID];
    [record signWithPrivateKey:self.privateKey];
    
    return record;
}

@end
