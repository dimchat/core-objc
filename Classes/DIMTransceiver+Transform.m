//
//  DIMTransceiver+Transform.m
//  DIMCore
//
//  Created by Albert Moky on 2019/3/15.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMContentType.h"
#import "DIMForwardContent.h"

#import "DIMBarrack.h"
#import "DIMKeyStore.h"

#import "DIMTransceiver+Transform.h"

@implementation DIMTransceiver (Transform)

- (nullable DIMReliableMessage *)encryptAndSignMessage:(DIMInstantMessage *)iMsg {
    NSAssert(iMsg.content, @"content cannot be empty");
    if (iMsg.delegate == nil) {
        iMsg.delegate = self;
    }
    
    DIMKeyStore *store = [DIMKeyStore sharedInstance];
    DIMSymmetricKey *scKey = nil;
    DIMSecureMessage *sMsg = nil;
    
    // 1. encrypt 'content' to 'data' for receiver
    const DIMID *receiver = MKMIDFromString(iMsg.envelope.receiver);
    const DIMID *group = MKMIDFromString(iMsg.content.group);
    if (group) {
        // if 'group' exists and the 'receiver' is a group ID,
        // they must be equal
        NSAssert(MKMNetwork_IsCommunicator(receiver.type) || [receiver isEqual:group],
                 @"receiver error: %@", receiver);
    } else if (MKMNetwork_IsGroup(receiver.type)) {
        group = receiver;
    }
    
    if (group) {
        // group message
        NSArray *members;
        if (MKMNetwork_IsCommunicator(receiver.type)) {
            // split group message
            members = @[receiver];
        } else {
            members = DIMGroupWithID(group).members;
            NSAssert(members.count > 0, @"group members cannot be empty");
        }
        scKey = [store cipherKeyForGroup:group];
        NSAssert(scKey != nil, @"failed to generate key for group: %@", group);
        sMsg = [iMsg encryptWithKey:scKey forMembers:members];
    } else {
        // personal message
        NSAssert(iMsg.content.group == nil, @"content error: %@", iMsg);
        scKey = [store cipherKeyForAccount:receiver];
        NSAssert(scKey != nil, @"failed to generate key for contact: %@", receiver);
        sMsg = [iMsg encryptWithKey:scKey];
    }
    NSAssert(sMsg.data, @"data cannot be empty");
    
    // 2. sign 'data' by sender
    if (sMsg.delegate == nil) {
        sMsg.delegate = self;
    }
    return [sMsg sign];
}

- (nullable DIMInstantMessage *)verifyAndDecryptMessage:(DIMReliableMessage *)rMsg
                                                  users:(const NSArray<const DIMUser *> *)users {
    NSAssert(rMsg.signature, @"signature cannot be empty");
    const DIMID *sender = MKMIDFromString(rMsg.envelope.sender);
    const DIMID *receiver = MKMIDFromString(rMsg.envelope.receiver);
    
    // [Meta Protocol] check meta in first contact message
    const DIMMeta *meta = DIMMetaForID(sender);
    if (!meta) {
        // first contact, try meta in message package
        meta = MKMMetaFromDictionary(rMsg.meta);
        if ([meta matchID:sender]) {
            DIMBarrack *barrack = [DIMBarrack sharedInstance];
            [barrack saveMeta:meta forID:sender];
        } else {
            NSAssert(false, @"meta error: %@, %@", sender, meta);
            return nil;
        }
    }
    
    if (rMsg.delegate == nil) {
        rMsg.delegate = self;
    }
    
    // check recipient
    const DIMID *groupID = MKMIDFromString(rMsg.group);
    const DIMUser *user = nil;
    if (MKMNetwork_IsGroup(receiver.type)) {
        NSAssert(!groupID || [groupID isEqual:receiver], @"group error: %@ != %@", receiver, groupID);
        groupID = receiver;
        // FIXME: maybe other user?
        user = users.firstObject;
        receiver = user.ID;
    } else {
        for (const DIMUser *item in users) {
            if ([item.ID isEqual:receiver]) {
                user = item;
                NSLog(@"got new message for: %@", item.ID);
                break;
            }
        }
    }
    if (!user) {
        NSAssert(false, @"!!! wrong recipient: %@", receiver);
        return nil;
    }
    
    // 1. verify 'data' with 'signature'
    DIMSecureMessage *sMsg = [rMsg verify];
    NSAssert(sMsg.data, @"data cannot be empty");
    
    // 2. decrypt 'data' to 'content'
    DIMInstantMessage *iMsg = nil;
    if (groupID) {
        // group message
        sMsg = [sMsg trimForMember:user.ID];
        sMsg.delegate = self;
        iMsg = [sMsg decryptForMember:receiver];
    } else {
        // personal message
        sMsg.delegate = self;
        iMsg = [sMsg decrypt];
    }
    NSAssert(iMsg.content, @"content cannot be empty");
    
    // 3. check: top-secret message
    if (iMsg.content.type == DIMContentType_Forward) {
        // do it again to drop the wrapper,
        // the secret inside the content is the real message
        DIMForwardContent *content = (DIMForwardContent *)iMsg.content;
        rMsg = content.forwardMessage;
        
        return [self verifyAndDecryptMessage:rMsg users:users];
    }
    
    // OK
    return iMsg;
}

@end
