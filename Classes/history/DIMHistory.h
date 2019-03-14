//
//  DIMHistory.h
//  DIMCore
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class DIMID;
@class DIMHistoryBlock;

/**
 *  history
 *
 *      data format: {
 *          ID: "name@address", // entity ID
 *          records: [],        // history blocks
 *      }
 */
@interface DIMHistory : DIMDictionary

@property (readonly, strong, nonatomic) const DIMID *ID;

@property (readonly, strong, nonatomic) NSArray *blocks; // records

+ (instancetype)historyWithHistory:(id)history;

- (instancetype)initWithID:(const DIMID *)ID;

- (void)addBlock:(DIMHistoryBlock *)record;

@end

#pragma mark - Entity History Delegates

@protocol DIMEntityHistoryDataSource <NSObject>

- (DIMHistory *)historyForEntityID:(const DIMID *)ID;

@end

@class DIMEntity;
@class DIMHistoryTransaction;
@class DIMHistoryOperation;

@protocol DIMEntityHistoryDelegate <NSObject>

/**
 Check whether a record(Block) can write to the entity's evolving history
 
 @param entity - Account/Group
 @param record - history record
 @return YES/NO
 */
- (BOOL)evolvingEntity:(const DIMEntity *)entity
        canWriteRecord:(const DIMHistoryBlock *)record;

/**
 Check whether an event(Transaction) can run for the entity
 
 @param entity - Account/Group
 @param event - history transaction
 @param recorder - history recorder's ID
 @return YES/NO
 */
- (BOOL)evolvingEntity:(const DIMEntity *)entity
           canRunEvent:(const DIMHistoryTransaction *)event
              recorder:(const DIMID *)recorder;

/**
 Run operation
 
 @param entity - User/Group
 @param operation - history operation
 @param commander - commander's ID
 */
- (void)evolvingEntity:(DIMEntity *)entity
               execute:(const DIMHistoryOperation *)operation
             commander:(const DIMID *)commander;

@end

NS_ASSUME_NONNULL_END
