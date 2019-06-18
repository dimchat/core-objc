//
//  DKDInstantMessage+Extension.h
//  DIMCore
//
//  Created by Albert Moky on 2019/4/11.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(UInt8, DIMMessageState) {
    DIMMessageState_Init = 0,
    DIMMessageState_Normal = DIMMessageState_Init,
    
    DIMMessageState_Waiting,
    DIMMessageState_Sending,   // sending to station
    DIMMessageState_Accepted,  // station accepted, delivering
    
    DIMMessageState_Delivering = DIMMessageState_Accepted,
    DIMMessageState_Delivered, // delivered to receiver (station said)
    DIMMessageState_Arrived,   // the receiver's client feedback
    DIMMessageState_Read,      // the receiver's client feedback
    
    DIMMessageState_Error = -1, // failed to send
};

@class DIMReceiptCommand;

@interface DKDInstantMessage (Extension)

@property (nonatomic) DIMMessageState state;
@property (strong , nonatomic, nullable) NSString *error;

- (BOOL)matchReceipt:(const DIMReceiptCommand *)cmd;

@end

NS_ASSUME_NONNULL_END
