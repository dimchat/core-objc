//
//  DIMHistoryTransaction.h
//  DIMCore
//
//  Created by Albert Moky on 2018/11/5.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class DIMID;
@class DIMAddress;
@class DIMHistoryOperation;

typedef NSDictionary<const DIMAddress *, NSString *> DIMConfirmTable;

/**
 *  history.records[i].events[j]
 *
 *      data format: {
 *          operation: "{...}",
 *          commander: "...",   // account ID
 *          signature: "...",   // algorithm defined by version
 *          //-- confirmed by members
 *          confirmations: {"address":"CT", }, // CT = sign(cmderSig, memberSK)
 *      }
 */
@interface DIMHistoryTransaction : DIMDictionary

@property (readonly, strong, nonatomic) DIMHistoryOperation *operation;

@property (readonly, strong, nonatomic) const DIMID *commander;
@property (readonly, strong, nonatomic) NSData *signature;

/**
 NOTICE: The history recorder must collect more than 50% confirmations
 from members before packing a HistoryBlock for a group.
 */
@property (readonly, strong, nonatomic) DIMConfirmTable *confirmations;

+ (instancetype)transactionWithTransaction:(id)event;

/**
 Copy history event from a dictioanry
 
 @param dict - data from database/network
 @return Operation
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict;

/**
 Initialize an operation without signature,
 while the commander is the recorder

 @param op - operation object
 @return Event object
 */
- (instancetype)initWithOperation:(const DIMHistoryOperation *)op;

/**
 Initialize an operation with signature
 
 @param operation - JsON string of an operation
 @param ID - commander ID
 @param CT - signature
 @return Event object
 */
- (instancetype)initWithOperation:(const NSString *)operation
                        commander:(const DIMID *)ID
                        signature:(const NSData *)CT;

/**
 Add confirmation of member

 @param CT - confirmation = sign(commander.signature, member.SK)
 @param ID - member ID
 */
- (void)setConfirmation:(const NSData *)CT forID:(const DIMID *)ID;

/**
 Get confirmation by member ID

 @param ID - member ID
 @return confirmation of the signature
 */
- (NSData *)confirmationForID:(const DIMID *)ID;

@end

#pragma mark - Link Transaction

@interface DIMHistoryTransaction (Link)

@property (readonly, strong, nonatomic) NSData *previousSignature;

@end

NS_ASSUME_NONNULL_END
