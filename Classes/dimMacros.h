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

// Content
#define DIMMessageContent               DKDMessageContent
#define DIMMessageType                  DKDMessageType
#define DIMMessageType_Text             DKDMessageType_Text
#define DIMMessageType_File             DKDMessageType_File
#define DIMMessageType_Image            DKDMessageType_Image
#define DIMMessageType_Audio            DKDMessageType_Audio
#define DIMMessageType_Video            DKDMessageType_Video
#define DIMMessageType_Page             DKDMessageType_Page
#define DIMMessageType_Quote            DKDMessageType_Quote
#define DIMMessageType_Command          DKDMessageType_Command
#define DIMMessageType_History          DKDMessageType_History
#define DIMMessageType_Forward          DKDMessageType_Forward
#define DIMMessageType_Unknown          DKDMessageType_Unknown

// Message
#define DIMEnvelope                     DKDEnvelope
#define DIMMessage                      DKDMessage
#define DIMInstantMessage               DKDInstantMessage
#define DIMSecureMessage                DKDSecureMessage
#define DIMReliableMessage              DKDReliableMessage
#define DIMEncryptedKeyMap              DKDEncryptedKeyMap

#endif /* dimMacros_h */
