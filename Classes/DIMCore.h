//
//  DIMCore.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for DIMCore.
FOUNDATION_EXPORT double DIMCoreVersionNumber;

//! Project version string for DIMCore.
FOUNDATION_EXPORT const unsigned char DIMCoreVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <DIMCore/PublicHeader.h>

// MKM
//#import <MingKeMing/MingKeMing.h>

// DKD
//#import <DaoKeDao/DaoKeDao.h>

#if !defined(__DIM_CORE__)
#define __DIM_CORE__ 1

#import <DIMCore/dimMacros.h>

// History
#import <DIMCore/DIMHistoryOperation.h>
#import <DIMCore/DIMHistoryTransaction.h>
#import <DIMCore/DIMHistoryBlock.h>
#import <DIMCore/DIMHistory.h>
#import <DIMCore/DIMEntityHistoryDelegate.h>
#import <DIMCore/DIMAccountHistoryDelegate.h>
#import <DIMCore/DIMGroupHistoryDelegate.h>
#import <DIMCore/DIMChatroomHistoryDelegate.h>
#import <DIMCore/DIMConsensus.h>
#import <DIMCore/DIMUser+History.h>

// message
#import <DIMCore/DIMInstantMessage+Transform.h>
#import <DIMCore/DIMSecureMessage+Transform.h>
#import <DIMCore/DIMReliableMessage+Transform.h>

// CA
#import <DIMCore/DIMCASubject.h>
#import <DIMCore/DIMCAValidity.h>
#import <DIMCore/DIMCAData.h>
#import <DIMCore/DIMCertificateAuthority.h>

// Network
#import <DIMCore/DIMServiceProvider.h>
#import <DIMCore/DIMStation.h>

// Commands
#import <DIMCore/DIMCommand.h>
#import <DIMCore/DIMHandshakeCommand.h>
#import <DIMCore/DIMMetaCommand.h>
#import <DIMCore/DIMGroupCommand.h>
#import <DIMCore/DIMProfileCommand.h>

//-
#import <DIMCore/DIMBarrack.h>
#import <DIMCore/DIMBarrack+LocalStorage.h>

#import <DIMCore/DIMKeyStore.h>
#import <DIMCore/DIMKeyStore+CacheFile.h>
#import <DIMCore/DIMTransceiver.h>

#import <DIMCore/DIMConversation.h>
#import <DIMCore/DIMAmanuensis.h>

#endif /* ! __DIM_CORE__ */
