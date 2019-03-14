//
//  DIMHistoryBlock.h
//  DIMCore
//
//  Created by Albert Moky on 2018/11/5.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class DIMPublicKey;
@class DIMPrivateKey;

@class DIMID;

@class DIMHistoryTransaction;

/**
 *  history.records[i]
 *
 *      data format: {
 *          events   : [],        // transactions
 *          merkle   : "...",     // merkle root of events with SHA256D
 *          signature: "...",     // sign(merkle, recorder.SK)
 *          recorder : "USER_ID", // history recorder
 *      }
 */
@interface DIMHistoryBlock : DIMDictionary

@property (readonly, strong, nonatomic) NSArray *transactions; // events
@property (readonly, strong, nonatomic) NSData *merkleRoot;
@property (readonly, strong, nonatomic) NSData *signature;
@property (readonly, strong, nonatomic, nullable) const DIMID *recorder;

+ (instancetype)blockWithBlock:(id)record;

/**
 Copy history record from a dictionary

 @param dict - data from database/network
 @return history record(block)
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict;

/**
 Copy history record from network
 
 @param events - transactions with string items
 @param hash - merkle root of events
 @param CT - signature of the merkle root
 @param ID - recorder ID
 @return Record object
 */
- (instancetype)initWithTransactions:(const NSArray *)events
                              merkle:(const NSData *)hash
                           signature:(const NSData *)CT
                            recorder:(nullable const DIMID *)ID;

/**
 Add history event(Transaction) to this record(Block)

 @param event - Transaction
 */
- (void)addTransaction:(const DIMHistoryTransaction *)event;

/**
 Calculate Merkle Root of all transactions and sign it

 @param SK - recorder's private key
 @return YES on success
 */
- (BOOL)signWithPrivateKey:(const DIMPrivateKey *)SK;

@end

#pragma mark - Link Block

@interface DIMHistoryBlock (Link)

@property (readonly, strong, nonatomic) NSData *previousSignature;

@end

NS_ASSUME_NONNULL_END
