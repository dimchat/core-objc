//
//  DIMTransceiver+Transform.m
//  DIMCore
//
//  Created by Albert Moky on 2019/3/15.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMBarrack+LocalStorage.h"
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
    const DIMID *receiver = [DIMID IDWithID:iMsg.envelope.receiver];
    if (MKMNetwork_IsCommunicator(receiver.type)) {
        NSAssert(iMsg.content.group == nil, @"content error: %@", iMsg);
        scKey = [store cipherKeyForAccount:receiver];
        if (!scKey) {
            // create a new key & save it into the Key Store
            scKey = [[DIMSymmetricKey alloc] init];
            [store setCipherKey:scKey forAccount:receiver];
        }
        sMsg = [iMsg encryptWithKey:scKey];
    } else if (MKMNetwork_IsGroup(receiver.type)) {
        const DIMID *groupID = [DIMID IDWithID:iMsg.content.group];
        NSAssert([groupID isEqual:receiver], @"group error: %@ not %@", groupID, receiver);
        scKey = [store cipherKeyForGroup:groupID];
        if (!scKey) {
            // create a new key & save it into the Key Store
            scKey = [[DIMSymmetricKey alloc] init];
            [store setCipherKey:scKey forGroup:groupID];
        }
        DIMGroup *group = DIMGroupWithID(groupID);
        NSArray *members = group.members;
        sMsg = [iMsg encryptWithKey:scKey forMembers:members];
    } else {
        NSAssert(false, @"receiver error: %@", receiver);
        return nil;
    }
    NSAssert(sMsg.data, @"data cannot be empty");
    
    // 2. sign 'data' by sender
    if (sMsg.delegate == nil) {
        sMsg.delegate = self;
    }
    return [sMsg sign];
}

- (nullable DIMInstantMessage *)verifyAndDecryptMessage:(DIMReliableMessage *)rMsg
                                                  users:(NSArray<const DIMUser *> *)users {
    NSAssert(rMsg.signature, @"signature cannot be empty");
    const DIMID *sender = [DIMID IDWithID:rMsg.envelope.sender];
    const DIMID *receiver = [DIMID IDWithID:rMsg.envelope.receiver];
    
    // [Meta Protocol] check meta in first contact message
    const DIMMeta *meta = DIMMetaForID(sender);
    if (!meta) {
        // first contact, try meta in message package
        meta = [DIMMeta metaWithMeta:rMsg.meta];
        if ([meta matchID:sender]) {
            DIMBarrack *barrack = [DIMBarrack sharedInstance];
            [barrack saveMeta:meta forEntityID:sender];
        } else {
            NSAssert(false, @"meta not found for sender: %@", sender);
            return nil;
        }
    }
    
    if (rMsg.delegate == nil) {
        rMsg.delegate = self;
    }
    
    // check recipient
    const DIMID *groupID = [DIMID IDWithID:rMsg.group];
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
    
    // 1. verify 'data' witn 'signature'
    DIMSecureMessage *sMsg = [rMsg verify];
    NSAssert(sMsg.data, @"data cannot be empty");
    
    // 1.1. trim for user
    sMsg = [sMsg trimForMember:user.ID];
    NSAssert(MKMNetwork_IsPerson(receiver.type), @"receiver error: %@", receiver);
    
    if (sMsg.delegate == nil) {
        sMsg.delegate = self;
    }
    
    // 2. decrypt 'data' to 'content'
    DIMInstantMessage *iMsg = nil;
    if (MKMNetwork_IsGroup(receiver.type)) {
        // group message
        iMsg = [sMsg decryptForMember:user.ID];
    } else if ([sMsg objectForKey:@"group"]) {
        // splitted group message
        iMsg = [sMsg decryptForMember:receiver];
    } else {
        // personal message
        iMsg = [sMsg decrypt];
    }
    NSAssert(iMsg.content, @"content cannot be empty");
    
    // 3. check: top-secret message
    if (iMsg.content.type == DIMMessageType_Forward) {
        // do it again to drop the wrapper,
        // the secret inside the content is the real message
        rMsg = iMsg.content.forwardMessage;
        
        return [self verifyAndDecryptMessage:rMsg users:users];
    }
    
    // OK
    return iMsg;
}

@end
