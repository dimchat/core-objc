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
#define DIMProfile                      MKMProfile
#define DIMEntity                       MKMEntity
#define DIMEntityDataSource             MKMEntityDataSource

// User
#define DIMUser                         MKMUser
#define DIMLocalUser                    MKMLocalUser
#define DIMUserDataSource               MKMUserDataSource

// Group
#define DIMGroup                        MKMGroup
#define DIMGroupDataSource              MKMGroupDataSource


#import <DaoKeDao/DaoKeDao.h>

// Types
#define DIMDictionary                   DKDDictionary

#define DIMEnvelope                     DKDEnvelope
#define DIMContent                      DKDContent
#define DIMForwardContent               DKDForwardContent

// Message
#define DIMMessage                      DKDMessage
#define DIMInstantMessage               DKDInstantMessage
#define DIMSecureMessage                DKDSecureMessage
#define DIMReliableMessage              DKDReliableMessage

#define DIMMessageDelegate              DKDMessageDelegate
//#define DIMInstantMessageDelegate       DKDInstantMessageDelegate
//#define DIMSecureMessageDelegate        DKDSecureMessageDelegate
#define DIMReliableMessageDelegate      DKDReliableMessageDelegate

#endif /* dimMacros_h */
