//
//  DIMHistoryOperation.h
//  DIMCore
//
//  Created by Albert Moky on 2018/11/5.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  history.records[i].events[j].operation
 *
 *      data format: {
 *          command: "register",
 *          time: 123,
 *          ...
 *      }
 */
@interface DIMHistoryOperation : DIMDictionary

@property (readonly, strong, nonatomic) NSString *command;
@property (readonly, strong, nonatomic) NSDate *time;

+ (instancetype)operationWithOperation:(id)op;

/**
 Copy history operation from a dictioanry

 @param dict - data from database/network
 @return Operation
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict;

/**
 Create a new operation

 @param op - command
 @param time - time
 @return Operation
 */
- (instancetype)initWithCommand:(const NSString *)op
                           time:(nullable const NSDate *)time;

@end

#pragma mark - Link Operation

/**
 *  history.records[i].events[0].operation
 *
 *      data format: {
 *          command: "Link",
 *          prevSign: "...", // previous record's signature
 *          ...
 *      }
 */
@interface DIMHistoryOperation (Link)

@property (readonly, copy, nonatomic) NSData *previousSignature;

- (instancetype)initWithPreviousSignature:(const NSData *)prevSign
                                     time:(nullable const NSDate *)time;

@end

NS_ASSUME_NONNULL_END
