//
//  dimMacros.h
//  DIMCore
//
//  Created by Albert Moky on 2018/12/21.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#ifndef dimMacros_h
#define dimMacros_h

#import <MingKeMing/MingKeMing.h>

// Cryptography
#define DIMSymmetricKey                 MKMSymmetricKey
#define DIMPublicKey                    MKMPublicKey
#define DIMPrivateKey                   MKMPrivateKey

// Entity
#define DIMID                           MKMID
#define DIMAddress                      MKMAddress
#define DIMMeta                         MKMMeta
#define DIMEntity                       MKMEntity

#define DIMEntityDataSource             MKMEntityDataSource

// Group
#define DIMGroup                        MKMGroup
#define DIMPolylogue                    MKMPolylogue
#define DIMChatroom                     MKMChatroom

#define DIMMember                       MKMMember
#define DIMFounder                      MKMFounder
#define DIMOwner                        MKMOwner
#define DIMAdmin                        MKMAdmin

#define DIMGroupDataSource              MKMGroupDataSource
#define DIMChatroomDataSource           MKMChatroomDataSource

//-
#define DIMAccount                      MKMAccount
#define DIMUser                         MKMUser
#define DIMContact                      MKMContact

#define DIMUserDataSource               MKMUserDataSource

#define DIMProfile                      MKMProfile

#import <DaoKeDao/DaoKeDao.h>

// Types
#define DIMDictionary                   DKDDictionary

#define DIMEnvelope                     DKDEnvelope
#define DIMContent                      DKDContent

// Message
#define DIMMessage                      DKDMessage
#define DIMInstantMessage               DKDInstantMessage
#define DIMSecureMessage                DKDSecureMessage
#define DIMReliableMessage              DKDReliableMessage
#define DIMEncryptedKeyMap              DKDEncryptedKeyMap

#endif /* dimMacros_h */
