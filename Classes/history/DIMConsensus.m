//
//  DIMConsensus.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/11.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "DIMHistoryOperation.h"
#import "DIMHistoryTransaction.h"
#import "DIMHistoryBlock.h"
#import "DIMHistory.h"

#import "DIMAccountHistoryDelegate.h"
#import "DIMChatroomHistoryDelegate.h"

#import "DIMConsensus.h"

static inline id history_delegate(const DIMEntity *entity) {
    DIMEntityHistoryDelegate *delegate = nil;
    if (MKMNetwork_IsPerson(entity.type)) {
        delegate = [DIMConsensus sharedInstance].accountHistoryDelegate;
    } else if (MKMNetwork_IsGroup(entity.type)) {
        delegate = [DIMConsensus sharedInstance].groupHistoryDelegate;
    }
    assert(delegate);
    return delegate;
}

@interface DIMConsensus () {
    
    DIMAccountHistoryDelegate *_defaultAccountDelegate;
    DIMChatroomHistoryDelegate *_defaultChatroomDelegate;
}

@end

@implementation DIMConsensus

SingletonImplementations(DIMConsensus, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        _defaultAccountDelegate = [[DIMAccountHistoryDelegate alloc] init];
        _defaultChatroomDelegate = [[DIMChatroomHistoryDelegate alloc] init];
        
        _accountHistoryDelegate = nil;
        _groupHistoryDelegate = nil;
        
        _entityHistoryDataSource = nil;
    }
    return self;
}

- (id<DIMEntityHistoryDelegate>)accountHistoryDelegate {
    if (_accountHistoryDelegate) {
        return _accountHistoryDelegate;
    } else {
        return _defaultAccountDelegate;
    }
}

- (id<DIMEntityHistoryDelegate>)groupHistoryDelegate {
    if (_groupHistoryDelegate) {
        return _groupHistoryDelegate;
    } else {
        return _defaultChatroomDelegate;
    }
}

#pragma mark - DIMEntityHistoryDelegate

- (BOOL)evolvingEntity:(const DIMEntity *)entity
        canWriteRecord:(const DIMHistoryBlock *)record {
    NSAssert(!record.recorder || MKMNetwork_IsPerson(record.recorder.type),
             @"recorder error: %@", record.recorder);
    id<DIMEntityHistoryDelegate> delegate = history_delegate(entity);
    return [delegate evolvingEntity:entity canWriteRecord:record];
}

- (BOOL)evolvingEntity:(const DIMEntity *)entity
           canRunEvent:(const DIMHistoryTransaction *)event
              recorder:(const DIMID *)recorder {
    NSAssert(!recorder || MKMNetwork_IsPerson(recorder.type),
             @"recorder error: %@", recorder);
    NSAssert(!event.commander || MKMNetwork_IsPerson(event.commander.type),
             @"commander error: %@", event.commander);
    id<DIMEntityHistoryDelegate> delegate = history_delegate(entity);
    return [delegate evolvingEntity:entity canRunEvent:event recorder:recorder];
}

- (void)evolvingEntity:(DIMEntity *)entity
               execute:(const DIMHistoryOperation *)operation
             commander:(const DIMID *)commander {
    NSAssert(MKMNetwork_IsPerson(commander.type), @"commander error: %@", commander);
    id<DIMEntityHistoryDelegate> delegate = history_delegate(entity);
    return [delegate evolvingEntity:entity execute:operation commander:commander];
}

#pragma mark - DIMEntityHistoryDataSource

- (DIMHistory *)historyForEntityID:(const DIMID *)ID {
    NSAssert(_entityHistoryDataSource, @"entity history data source not set");
    return [_entityHistoryDataSource historyForEntityID:ID];
}

@end

@implementation DIMConsensus (History)

- (NSUInteger)runHistory:(const DIMHistory *)history
               forEntity:(DIMEntity *)entity {
    NSAssert([entity.ID isValid], @"entity ID error: %@", entity);
    NSAssert([history.ID isEqual:entity.ID], @"ID not match: %@", entity.ID);
    NSAssert([history count] > 0, @"history cannot be empty");
    NSUInteger pos = 0;
    
//    // Compare the history with the old one.
//    // If they has the same record at the first place, it means
//    // the new history should have the same records with the old one,
//    // we should cut off all the exists records and just add the new ones.
//    DIMHistory * oldHis = DIMHistoryForID(entity.ID);
//
//    NSUInteger old_len = oldHis.count;
//    NSUInteger new_len = history.count;
//    if (old_len > 0 && [oldHis.firstObject isEqual:history.firstObject]) {
//        // 1. check whether new len is longer than the old len
//        if (new_len <= old_len) {
//            // all the new records must be the same with the old ones
//            // it's not necessary to check them now
//            return 0;
//        }
//        // 2. make sure the exists history is contained by the new one
//        DIMHistoryRecord *oldRec, *newRec;
//        for (pos = 1; pos < old_len; ++pos) {
//            oldRec = [oldHis objectAtIndex:pos];
//            newRec = [history objectAtIndex:pos];
//            NSAssert([oldRec isEqual:newRec], @"new record error: %@", newRec);
//            if (![oldRec isEqual:newRec]) {
//                // error
//                return 0;
//            }
//        }
//        // 3. cut off the same records, use the new records remaining
//        NSRange range = NSMakeRange(old_len, new_len - old_len);
//        NSArray *array = [history subarrayWithRange:range];
//        history = [[DIMHistory alloc] initWithArray:array];
//    }
    
    // OK, add new history records now
    DIMHistoryBlock *record, *prev = nil;
    for (id item in history.blocks) {
        record = [DIMHistoryBlock blockWithBlock:item];
        // check the link with previous record
        if (prev && ![record.previousSignature isEqualToData:prev.signature]) {
            NSAssert(false, @"blocks not linked");
            break;
        }
        // run this record
        if ([self runHistoryBlock:record forEntity:entity]) {
            ++pos;
        } else {
            // record error
            break;
        }
        prev = record;
    }
    
    return pos;
}

- (BOOL)runHistoryBlock:(const DIMHistoryBlock *)record
              forEntity:(DIMEntity *)entity {
    // 1. check permision for writting history record
    if (![self evolvingEntity:entity canWriteRecord:record]) {
        NSAssert(false, @"permission denied");
        return NO;
    }
    
    // 2. get recorder
    const DIMID *recorder = record.recorder;
    if (recorder) {
        recorder = [DIMID IDWithID:recorder];
    } else {
        NSAssert(MKMNetwork_IsPerson(entity.type), @"not a person: %@", entity);
        recorder = entity.ID;
    }
    
    // 3. check permission for each commander in all events
    DIMHistoryTransaction *event;
    for (id item in record.transactions) {
        // 3.1. get history event
        event = [DIMHistoryTransaction transactionWithTransaction:item];
        
        // 3.2. check permission for running history event
        if (![self evolvingEntity:entity canRunEvent:event recorder:recorder]) {
            NSAssert(false, @"commander permission denied");
            return NO;
        }
    }
    
    // 4. execute all events in this record
    DIMHistoryOperation *op;
    const DIMID *commander;
    for (id item in record.transactions) {
        // 4.1. get event.commander
        event = [DIMHistoryTransaction transactionWithTransaction:item];
        commander = event.commander;
        if (!commander) {
            commander = recorder;
        }
        
        // 4.2. get event.operation
        op = [DIMHistoryOperation operationWithOperation:event.operation];
        
        // 4.3. execute history operation
        [self evolvingEntity:entity execute:op commander:commander];
    }
    
    return YES;
}

@end
