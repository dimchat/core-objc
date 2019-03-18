//
//  DIMKeyStore.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Cache for Cipher Key with direction: <from, to>
 */
@interface DIMKeyStore : NSObject

/**
 Current User
 */
@property (strong, nonatomic) DIMUser *currentUser;

+ (instancetype)sharedInstance;

//- (DIMSymmetricKey *)cipherKeyFrom:(const DIMID *)sender to:(const DIMID *)receiver;
//
//- (void)cacheCipherKey:(DIMSymmetricKey *)key from:(const DIMID *)sender to:(const DIMID *)receiver;

#pragma mark - Cipher key to encpryt message for account(contact)

/**
 Get a cipher key to encrypt message for a friend(contact)

 @param receiver - friend ID
 @return passphrase
 */
- (DIMSymmetricKey *)cipherKeyForAccount:(const DIMID *)receiver;

/**
 Save the cipher key for the friend(contact)

 @param key - passphrase
 @param receiver - friend ID
 */
- (void)setCipherKey:(DIMSymmetricKey *)key forAccount:(const DIMID *)receiver;

#pragma mark - Cipher key from contact to decrypt message

/**
 Get a cipher key from a friend(contact) to decrypt message

 @param sender - friend ID
 @return passphrase
 */
- (DIMSymmetricKey *)cipherKeyFromAccount:(const DIMID *)sender;

/**
 Save the cipher key from the friend(contact)

 @param key - passphrase
 @param sender - friend ID
 */
- (void)setCipherKey:(DIMSymmetricKey *)key fromAccount:(const DIMID *)sender;

#pragma mark - Cipher key to encrypt message for all group members

/**
 Get a cipher key to encrypt message for all members in a group

 @param group - group ID
 @return passphrase
 */
- (DIMSymmetricKey *)cipherKeyForGroup:(const DIMID *)group;

/**
 Save the cipher key for all members in the group

 @param key - passphrase
 @param group - group ID
 */
- (void)setCipherKey:(DIMSymmetricKey *)key forGroup:(const DIMID *)group;

#pragma mark - Cipher key from a member in the group to decrypt message

/**
 Get a cipher key from a group member to decrypt message

 @param sender - group member ID
 @param group - group ID
 @return passphrase
 */
- (DIMSymmetricKey *)cipherKeyFromMember:(const DIMID *)sender inGroup:(const DIMID *)group;

/**
 Save the cipher key from the group member

 @param key - passphrase
 @param sender - group member ID
 @param group - group ID
 */
- (void)setCipherKey:(DIMSymmetricKey *)key fromMember:(const DIMID *)sender inGroup:(const DIMID *)group;

#pragma mark - Private key encrpyted by a password for user

/**
 Get encrypted SK for user to store elsewhere
 
 @param user - user
 @param PW - password to encrypt the SK
 @return KS
 */
- (NSData *)privateKeyStoredForUser:(const DIMUser *)user passphrase:(const DIMSymmetricKey *)PW;

@end

NS_ASSUME_NONNULL_END
