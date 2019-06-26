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

// extends
#import <DIMCore/MKMProfile+Extension.h>
#import <DIMCore/DKDInstantMessage+Extension.h>

// CA
#import <DIMCore/DIMCASubject.h>
#import <DIMCore/DIMCAValidity.h>
#import <DIMCore/DIMCAData.h>
#import <DIMCore/DIMCertificateAuthority.h>

// Network
#import <DIMCore/DIMServiceProvider.h>
#import <DIMCore/DIMStation.h>

// Content
#import <DIMCore/DIMContentType.h>
#import <DIMCore/DIMTextContent.h>
#import <DIMCore/DIMFileContent.h>
#import <DIMCore/DIMImageContent.h>
#import <DIMCore/DIMAudioContent.h>
#import <DIMCore/DIMVideoContent.h>
#import <DIMCore/DIMWebpageContent.h>
#import <DIMCore/DIMForwardContent.h>

// Commands
#import <DIMCore/DIMCommand.h>
#import <DIMCore/DIMHandshakeCommand.h>
#import <DIMCore/DIMBroadcastCommand.h>
#import <DIMCore/DIMReceiptCommand.h>
#import <DIMCore/DIMMetaCommand.h>
#import <DIMCore/DIMProfileCommand.h>
#import <DIMCore/DIMHistoryCommand.h>
#import <DIMCore/DIMGroupCommand.h>

//-
#import <DIMCore/DIMBarrack.h>
#import <DIMCore/DIMKeyStore.h>
#import <DIMCore/DIMTransceiver.h>
#import <DIMCore/DIMTransceiver+Transform.h>

#endif /* ! __DIM_CORE__ */
