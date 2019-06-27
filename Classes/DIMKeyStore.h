//
//  DIMKeyStore.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DIMCipherKeyDataSource <NSObject>

/**
 *  Get cipher key for encrypt message from 'sender' to 'receiver'
 *
 * @param sender - user or contact ID
 * @param receiver - contact or user/group ID
 * @return cipher key
 */
- (DIMSymmetricKey *)cipherKeyFrom:(DIMID *)sender
                                to:(DIMID *)receiver;

/**
 *  Cache cipher key for reusing, with the direction (from 'sender' to 'receiver')
 *
 * @param key - cipher key
 * @param sender - user or contact ID
 * @param receiver - contact or user/group ID
 */
- (void)cacheCipherKey:(DIMSymmetricKey *)key
                  from:(DIMID *)sender
                    to:(DIMID *)receiver;

/**
 *  Update/create cipher key for encrypt message content
 *
 * @param key - old key to be reused (nullable)
 * @param sender - user ID
 * @param receiver - contact/group ID
 * @return new key
 */
- (DIMSymmetricKey *)reuseCipherKey:(nullable DIMSymmetricKey *)key
                               from:(DIMID *)sender
                                 to:(DIMID *)receiver;

@end

/**
 *  Cache for Cipher Key with direction: <from, to>
 */
@interface DIMKeyStore : NSObject <DIMCipherKeyDataSource>

/**
 *  Trigger for saving cipher key table
 */
- (void)flush;

/**
 *  Callback for saving cipher key table into local storage
 *  (Override it to access database)
 *
 * @param keyMap - all cipher keys(with direction) from memory cache
 * @return YES on success
 */
- (BOOL)saveKeys:(NSDictionary *)keyMap;

/**
 *  Load cipher key table from local storage
 *  (Override it to access database)
 *
 * @return keys map
 */
- (NSDictionary *)loadKeys;

/**
 *  Update cipher key table into memory cache
 *
 * @param keyMap - cipher keys(with direction) from local storage
 * @return NO on nothing changed
 */
- (BOOL)updateKeys:(NSDictionary *)keyMap;

@end

NS_ASSUME_NONNULL_END
