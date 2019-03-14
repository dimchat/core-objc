//
//  DIMAmanuensis.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/21.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "DIMBarrack.h"
#import "DIMConversation.h"

#import "DIMAmanuensis.h"

@interface DIMAmanuensis () {
    
    NSMutableDictionary<const DIMAddress *, DIMConversation *> *_conversations;
}

@end

@implementation DIMAmanuensis

SingletonImplementations(DIMAmanuensis, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        _conversations = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setConversationDataSource:(id<DIMConversationDataSource>)dataSource {
    if (dataSource) {
        // update exists chat boxes
        DIMConversation *chatBox;
        for (id addr in _conversations) {
            chatBox = [_conversations objectForKey:addr];
            if (chatBox.dataSource == nil) {
                chatBox.dataSource = dataSource;
            }
        }
    }
    _conversationDataSource = dataSource;
}

- (void)setConversationDelegate:(id<DIMConversationDelegate>)delegate {
    if (delegate) {
        // update exists chat boxes
        DIMConversation *chatBox;
        for (id addr in _conversations) {
            chatBox = [_conversations objectForKey:addr];
            if (chatBox.delegate == nil) {
                chatBox.delegate = delegate;
            }
        }
    }
    _conversationDelegate = delegate;
}

- (DIMConversation *)conversationWithID:(const DIMID *)ID {
    DIMConversation *chatBox = [_conversations objectForKey:ID.address];
    if (!chatBox) {
        if (_conversationDelegate) {
            // create by delegate
            chatBox = [_conversationDelegate conversationWithID:ID];
        }
        if (!chatBox) {
            // create directly if we can find the entity
            // get entity with ID
            DIMEntity *entity = nil;
            if (MKMNetwork_IsCommunicator(ID.type)) {
                entity = DIMAccountWithID(ID);
            } else if (MKMNetwork_IsGroup(ID.type)) {
                entity = DIMGroupWithID(ID);
            }
            NSAssert(entity, @"ID error: %@", ID);
            if (entity) {
                // create new conversation with entity(Account/Group)
                chatBox = [[DIMConversation alloc] initWithEntity:entity];
            }
        }
        NSAssert(chatBox, @"failed to create conversation: %@", ID);
        [self addConversation:chatBox];
    }
    return chatBox;
}

- (void)addConversation:(DIMConversation *)chatBox {
    NSAssert([chatBox.ID isValid], @"conversation invalid: %@", chatBox.ID);
    // check data source
    if (chatBox.dataSource == nil) {
        chatBox.dataSource = _conversationDataSource;
    }
    // check delegate
    if (chatBox.delegate == nil) {
        chatBox.delegate = _conversationDelegate;
    }
    const DIMID *ID = chatBox.ID;
    [_conversations setObject:chatBox forKey:ID.address];
}

- (void)removeConversation:(DIMConversation *)chatBox {
    const DIMID *ID = chatBox.ID;
    [_conversations removeObjectForKey:ID.address];
}

@end

@implementation DIMAmanuensis (Message)

- (void)saveMessage:(const DIMInstantMessage *)iMsg {
    NSLog(@"saving message: %@", iMsg);
    
    DIMConversation *chatBox = nil;
    
    DIMEnvelope *env = iMsg.envelope;
    const DIMID *sender = [DIMID IDWithID:env.sender];
    const DIMID *receiver = [DIMID IDWithID:env.receiver];
    const DIMID *groupID = [DIMID IDWithID:iMsg.content.group];
    
    if (MKMNetwork_IsGroup(receiver.type)) {
        // group chat, get chat box with group ID
        chatBox = [self conversationWithID:receiver];
    } else if (groupID) {
        // group chat, get chat box with group ID
        chatBox = [self conversationWithID:groupID];
    } else {
        // personal chat, get chat box with contact ID
        chatBox = [self conversationWithID:sender];
    }
    
    NSAssert(chatBox, @"chat box not found for message: %@", iMsg);
    [chatBox insertMessage:iMsg];
}

@end
