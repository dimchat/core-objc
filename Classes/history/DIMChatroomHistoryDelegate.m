//
//  DIMChatroomHistoryDelegate.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/6.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMHistoryOperation.h"
#import "DIMHistoryTransaction.h"
#import "DIMHistoryBlock.h"

#import "DIMChatroomHistoryDelegate.h"

@implementation DIMChatroomHistoryDelegate

- (BOOL)evolvingEntity:(const DIMEntity *)entity
        canWriteRecord:(const DIMHistoryBlock *)record {
    // call super check
    if (![super evolvingEntity:entity canWriteRecord:record]) {
        return NO;
    }
    
    DIMID *recorder = [DIMID IDWithID:record.recorder];
    NSAssert([recorder isValid], @"recorder error: %@", recorder);
    
    NSAssert([entity isKindOfClass:[DIMChatroom class]], @"entity must be a chatroom: %@", entity);
    DIMChatroom *chatroom = (DIMChatroom *)entity;
    
    BOOL isOwner = [chatroom.owner isEqual:recorder];
    if (isOwner) {
        return YES;
    }
    
    // only the owner can write history for chatroom
    return NO;
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
    
    DIMHistoryOperation *operation = event.operation;
    operation = [DIMHistoryOperation operationWithOperation:operation];
    
    NSAssert([entity isKindOfClass:[DIMChatroom class]], @"entity must be a chatroom: %@", entity);
    DIMChatroom *chatroom = (DIMChatroom *)entity;
    
    //BOOL isFounder = [chatroom.founder isEqual:commander];
    BOOL isOwner = [chatroom.owner isEqual:commander];
    BOOL isAdmin = [chatroom existsAdmin:commander];
    //BOOL isMember = isOwner || isAdmin || [chatroom hasMember:ID];
    
    const NSString *op = operation.command;
    if ([op isEqualToString:@"name"] ||
        [op isEqualToString:@"setName"]) {
        // let the subclass to reduce it
    } else if ([op isEqualToString:@"invite"]) {
        // let the subclass to reduce it
    } else if ([op isEqualToString:@"expel"]) {
        // owner or admin
        if (!isOwner && !isAdmin) {
            NSAssert(false, @"only owner or admin can expel member");
            return NO;
        }
    } else if ([op isEqualToString:@"hire"]) {
        // only owner
        if (!isOwner) {
            NSAssert(false, @"only owner can hire admin");
            return NO;
        }
    } else if ([op isEqualToString:@"fire"]) {
        // only owner
        if (!isOwner) {
            NSAssert(false, @"only owner can fire admin");
            return NO;
        }
    } else if ([op isEqualToString:@"resign"]) {
        // only admin
        if (!isAdmin || isOwner) {
            NSAssert(false, @"only admin can resign");
            return NO;
        }
    } else if ([op isEqualToString:@"quit"]) {
        // the super has forbidden the owner to quit directly
        // here forbid the admin too
        if (isAdmin) {
            NSAssert(false, @"admin cannot quit, resign first");
            return NO;
        }
    }
    
    // let the subclass to extend the permission list
    return YES;
}

- (void)evolvingEntity:(DIMEntity *)entity
               execute:(const DIMHistoryOperation *)operation
             commander:(const DIMID *)commander {
    // call super execute
    [super evolvingEntity:entity execute:operation commander:commander];
    
    NSAssert([entity isKindOfClass:[DIMChatroom class]], @"entity must be a chatroom: %@", entity);
    DIMChatroom *chatroom = (DIMChatroom *)entity;
    
    const NSString *op = operation.command;
    if ([op isEqualToString:@"hire"]) {
        NSAssert([chatroom.owner isEqual:commander], @"permission denied");
        // hire admin
        DIMID *admin = [operation objectForKey:@"admin"];
        if (!admin) {
            admin = [operation objectForKey:@"administrator"];
        }
        if (admin) {
            admin = [DIMID IDWithID:admin];
            // TODO: hire admin
            //[chatroom addAdmin:admin];
        }
    } else if ([op isEqualToString:@"fire"]) {
        NSAssert([chatroom.owner isEqual:commander], @"permission denied");
        // fire admin
        DIMID *admin = [operation objectForKey:@"admin"];
        if (!admin) {
            admin = [operation objectForKey:@"administrator"];
        }
        if (admin) {
            admin = [DIMID IDWithID:admin];
            // TODO: fire admin
            //[chatroom removeAdmin:admin];
        }
    } else if ([op isEqualToString:@"resign"]) {
        NSAssert([chatroom existsAdmin:commander], @"history error");
        // TODO: resign admin
        //[chatroom removeAdmin:commander];
    }
}

@end
