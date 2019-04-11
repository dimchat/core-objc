//
//  DKDInstantMessage+Extension.m
//  DIMCore
//
//  Created by Albert Moky on 2019/4/11.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMReceiptCommand.h"

#import "DKDInstantMessage+Extension.h"

@implementation DKDInstantMessage (Extension)

- (DIMMessageState)state {
    NSNumber *number = [_storeDictionary objectForKey:@"state"];
    return [number unsignedIntegerValue];
}

- (void)setState:(DIMMessageState)state {
    [_storeDictionary setObject:@(state) forKey:@"state"];
}

- (NSString *)error {
    return [_storeDictionary objectForKey:@"error"];
}

- (void)setError:(NSString *)error {
    if (error) {
        [_storeDictionary setObject:error forKey:@"error"];
    } else {
        [_storeDictionary removeObjectForKey:@"error"];
    }
}

- (BOOL)matchReceipt:(DIMReceiptCommand *)cmd {
    
    DIMMessageContent *content = self.content;
    
    // check serial number
    if (cmd.serialNumber != content.serialNumber) {
        return NO;
    }
    
    // check envelope
    DIMEnvelope *env1 = cmd.envelope;
    DIMEnvelope *env2 = self.envelope;
    if (env1 && ![env1 isEqual:env2]) {
        return NO;
    }
    
    // check signature
    NSString *sig1 = [cmd objectForKey:@"signature"];
    NSString *sig2 = [self objectForKey:@"signature"];
    if (sig1.length > 8 && sig2.length > 8) {
        sig1 = [sig1 substringToIndex:8];
        sig2 = [sig2 substringToIndex:8];
        if (![sig1 isEqualToString:sig2]) {
            return NO;
        }
    }
    
    return YES;
}

@end