//
//  DIMAmanuensis.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/21.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

#import "DKDInstantMessage+Extension.h"

NS_ASSUME_NONNULL_BEGIN

#define DIMClerk()                [DIMAmanuensis sharedInstance]
#define DIMConversationWithID(ID) [DIMClerk() conversationWithID:(ID)]

@class DIMConversation;
@class DIMReceiptCommand;

@protocol DIMConversationDataSource;
@protocol DIMConversationDelegate;

/**
 *  Conversation pool to manage conversation instances
 *
 *      1st, get instance here to avoid create same instance,
 *      2nd, if their history was updated, we can notice them here immediately
 */
@interface DIMAmanuensis : NSObject

@property (weak, nonatomic) id<DIMConversationDataSource> conversationDataSource;
@property (weak, nonatomic) id<DIMConversationDelegate> conversationDelegate;

+ (instancetype)sharedInstance;

// conversation factory
- (DIMConversation *)conversationWithID:(const DIMID *)ID;

- (void)addConversation:(DIMConversation *)chatBox;
- (void)removeConversation:(DIMConversation *)chatBox;

@end

@interface DIMAmanuensis (Message)

/**
 Save received message
 
 @param iMsg - instant message
 @return YES on success
 */
- (BOOL)saveMessage:(DIMInstantMessage *)iMsg;

/**
 Save state with receipt
 
 @param cmd - receipt
 @return YES while message found
 */
- (BOOL)saveReceipt:(const DIMReceiptCommand *)cmd;

@end

NS_ASSUME_NONNULL_END
