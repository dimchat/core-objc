//
//  DIMKeyStore.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMKeyStore : NSObject

/**
 Current User
 */
@property (strong, nonatomic) DIMUser *currentUser;

+ (instancetype)sharedInstance;

/**
 Clear all keys in memory
 */
- (void)clearMemory;

#pragma mark - Cipher key to encpryt message for account(contact)

/**
 Get a cipher key to encrypt message for a friend(contact)

 @param ID - friend
 @return passphrase
 */
- (DIMSymmetricKey *)cipherKeyForAccount:(const DIMID *)ID;

/**
 Save the cipher key for the friend(contact)

 @param key - passphrase
 @param ID - friend
 */
- (void)setCipherKey:(DIMSymmetricKey *)key
          forAccount:(const DIMID *)ID;

#pragma mark - Cipher key from contact to decrypt message

/**
 Get a cipher key from a friend(contact) to decrypt message

 @param ID - friend
 @return passphrase
 */
- (DIMSymmetricKey *)cipherKeyFromAccount:(const DIMID *)ID;

/**
 Save the cipher key from the friend(contact)

 @param key - passphrase
 @param ID - friend
 */
- (void)setCipherKey:(DIMSymmetricKey *)key
         fromAccount:(const DIMID *)ID;

#pragma mark - Cipher key to encrypt message for all group members

/**
 Get a cipher key to encrypt message for all members in a group

 @param ID - group
 @return passphrase
 */
- (DIMSymmetricKey *)cipherKeyForGroup:(const DIMID *)ID;

/**
 Save the cipher key for all members in the group

 @param key - passphrase
 @param ID - group
 */
- (void)setCipherKey:(DIMSymmetricKey *)key
            forGroup:(const DIMID *)ID;

#pragma mark - Cipher key from a member in the group to decrypt message

/**
 Get a cipher key from a group member to decrypt message

 @param ID - group.member
 @param group - group
 @return passphrase
 */
- (DIMSymmetricKey *)cipherKeyFromMember:(const DIMID *)ID
                                 inGroup:(const DIMID *)group;

/**
 Save the cipher key from the group member

 @param key - passphrase
 @param ID - group.member
 @param group - group
 */
- (void)setCipherKey:(DIMSymmetricKey *)key
          fromMember:(const DIMID *)ID
             inGroup:(const DIMID *)group;

#pragma mark - Private key encrpyted by a password for user

/**
 Get encrypted SK for user to store elsewhere
 
 @param user - user
 @param PW - password to encrypt the SK
 @return KS
 */
- (NSData *)privateKeyStoredForUser:(const DIMUser *)user
                         passphrase:(const DIMSymmetricKey *)PW;

@end

NS_ASSUME_NONNULL_END
