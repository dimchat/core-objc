//
//  DIMAccountHistoryDelegate.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/6.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMImmortals.h"

#import "DIMHistoryOperation.h"
#import "DIMHistoryTransaction.h"
#import "DIMHistoryBlock.h"
#import "DIMHistory.h"

#import "DIMAccountHistoryDelegate.h"

@implementation DIMAccountHistoryDelegate

- (BOOL)evolvingEntity:(const DIMEntity *)entity
        canWriteRecord:(const DIMHistoryBlock *)record {
    // check recorder
    if (![record.recorder isEqual:entity.ID]) {
        NSAssert(false, @"only itself can write history record");
        return NO;
    }
    
    // call super check
    return [super evolvingEntity:entity canWriteRecord:record];
}

- (BOOL)evolvingEntity:(const DIMEntity *)entity
           canRunEvent:(const DIMHistoryTransaction *)event
              recorder:(const DIMID *)recorder {
    // call super check
    if (![super evolvingEntity:entity canRunEvent:event recorder:recorder]) {
        return NO;
    }
    
    // check commander
    const DIMID *commander = event.commander;
    if (!commander) {
        commander = recorder;
    }
    if (![commander isEqual:entity.ID]) {
        NSAssert(false, @"only itself can run history event");
        return NO;
    }
    
    NSAssert([entity isKindOfClass:[DIMAccount class]], @"entity must be an account: %@", entity);
    const DIMAccount *account = (const DIMAccount *)entity;
    
    DIMHistoryOperation *operation;
    operation = [DIMHistoryOperation operationWithOperation:event.operation];
    const NSString *op = operation.command;
    if ([op isEqualToString:@"register"] ||
        [op isEqualToString:@"create"]) {
        // status: Initialized -> Registered
        if (account.status == MKMAccountStatusInitialized) {
            return YES;
        } else {
            return NO;
        }
    } else if ([op isEqualToString:@"suicide"] ||
               [op isEqualToString:@"destroy"]) {
        // Immortal Accounts
        if ([commander isEqualToString:MKM_IMMORTAL_HULK_ID] ||
            [commander isEqualToString:MKM_MONKEY_KING_ID]) {
            NSAssert(false, @"immortals cannot suicide!");
            return NO;
        }
        // status: Registered -> Dead
        //if (account.status == MKMAccountStatusRegistered) {
            return YES;
        //}
    }
    
    // Account history only support TWO operations above
    return NO;
}

- (void)evolvingEntity:(DIMEntity *)entity
               execute:(const DIMHistoryOperation *)operation
             commander:(const DIMID *)commander {
    // call super execute
    [super evolvingEntity:entity execute:operation commander:commander];
    
    NSAssert([entity isKindOfClass:[DIMAccount class]], @"entity must be an account: %@", entity);
    DIMAccount *account = (DIMAccount *)entity;
    
    const NSString *op = operation.command;
    if ([op isEqualToString:@"register"] ||
        [op isEqualToString:@"create"]) {
        // status: Initialized -> Registered
        if (account.status == MKMAccountStatusInitialized) {
            // TODO: update account status
            //account.status = MKMAccountStatusRegistered;
        }
    } else if ([op isEqualToString:@"suicide"] ||
               [op isEqualToString:@"destroy"]) {
        // Immortal Accounts
        if ([commander isEqualToString:MKM_IMMORTAL_HULK_ID] ||
            [commander isEqualToString:MKM_MONKEY_KING_ID]) {
            NSAssert(false, @"immortals cannot suicide!");
            return ;
        }
        // status: Registered -> Dead
        //if (account.status == MKMAccountStatusRegistered) {
            // TODO: update account status
            //account.status = MKMAccountStatusDead;
        //}
    }
}

@end
