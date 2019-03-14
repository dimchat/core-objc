//
//  DIMConsensus.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/11.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMEntityHistoryDelegate.h"

NS_ASSUME_NONNULL_BEGIN

#define DIMHistoryForID(ID) [[DIMConsensus sharedInstance] historyForEntityID:(ID)]

@interface DIMConsensus : NSObject <DIMEntityHistoryDelegate, DIMEntityHistoryDataSource>

@property (weak, nonatomic) id<DIMEntityHistoryDelegate> accountHistoryDelegate;
@property (weak, nonatomic) id<DIMEntityHistoryDelegate> groupHistoryDelegate;

@property (weak, nonatomic) id<DIMEntityHistoryDataSource> entityHistoryDataSource;

+ (instancetype)sharedInstance;

@end

@class DIMHistory;
@class DIMHistoryBlock;

@interface DIMConsensus (History)

/**
 Run the whole history, stop when error
 
 @param history - history records
 @return Cout of success
 */
- (NSUInteger)runHistory:(const DIMHistory *)history
               forEntity:(DIMEntity *)entity;

/**
 Run one new history record
 
 @param record - history record
 @return YES when success
 */
- (BOOL)runHistoryBlock:(const DIMHistoryBlock *)record
              forEntity:(DIMEntity *)entity;

@end

NS_ASSUME_NONNULL_END
