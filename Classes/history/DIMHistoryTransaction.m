//
//  DIMHistoryTransaction.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/5.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "DIMHistoryOperation.h"

#import "DIMHistoryTransaction.h"

typedef NSMutableDictionary<const DIMAddress *, NSString *> DIMConfirmTableM;

@interface DIMHistoryTransaction ()

@property (strong, nonatomic) DIMHistoryOperation *operation;

@property (strong, nonatomic) const DIMID *commander;
@property (strong, nonatomic) NSData *signature;

@property (strong, nonatomic) DIMConfirmTableM *confirmations;

@end

@implementation DIMHistoryTransaction

+ (instancetype)transactionWithTransaction:(id)event {
    if ([event isKindOfClass:[DIMHistoryTransaction class]]) {
        return event;
    } else if ([event isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:event];
    } else if ([event isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithJSONString:event];
    } else {
        NSAssert(!event, @"unexpected event: %@", event);
        return nil;
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _operation = nil;
        _commander = nil;
        _signature = nil;
        _confirmations = nil;
    }
    
    return self;
}

- (instancetype)initWithOperation:(const DIMHistoryOperation *)op {
    NSDictionary *dict = @{@"operation":op};
    if (self = [super initWithDictionary:dict]) {
        _operation = [op copy];
        _commander = nil;
        _signature = nil;
        _confirmations = nil;
    }
    return self;
}

- (instancetype)initWithOperation:(const NSString *)operation
                        commander:(const DIMID *)ID
                        signature:(const NSData *)CT {
    NSAssert(MKMNetwork_IsPerson(ID.type), @"commander error: %@", ID);
    NSAssert(CT, @"signature cannot be empty");
    NSDictionary *dict = @{@"operation":operation,
                           @"commander":ID,
                           @"signature":[CT base64Encode],
                           };
    if (self = [super initWithDictionary:dict]) {
        _operation = [DIMHistoryOperation operationWithOperation:operation];
        _commander = [ID copy];
        _signature = [CT copy];
        _confirmations = nil;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMHistoryTransaction *event = [super copyWithZone:zone];
    if (event) {
        event.operation = _operation;
        event.commander = _commander;
        event.signature = _signature;
        event.confirmations = _confirmations;
    }
    return event;
}

- (DIMHistoryOperation *)operation {
    if (!_operation) {
        id op = [_storeDictionary objectForKey:@"operation"];
        _operation = [DIMHistoryOperation operationWithOperation:op];
    }
    return _operation;
}

- (const DIMID *)commander {
    if (!_commander) {
        id ID = [_storeDictionary objectForKey:@"commander"];
        _commander = [DIMID IDWithID:ID];
    }
    return _commander;
}

- (NSData *)signature {
    if (!_signature) {
        NSString *CT = [_storeDictionary objectForKey:@"signature"];
        _signature = [CT base64Decode];
    }
    return _signature;
}

- (DIMConfirmTable *)confirmations {
    if (!_confirmations) {
        _confirmations = [_storeDictionary objectForKey:@"confirmations"];
    }
    return _confirmations;
}

- (void)setConfirmation:(const NSData *)CT forID:(const DIMID *)ID {
    NSAssert(CT, @"confirmation cannot be empty");
    if (!_confirmations) {
        DIMConfirmTableM *table;
        table = [_storeDictionary objectForKey:@"confirmations"];
        if (!table) {
            table = [[DIMConfirmTableM alloc] init];
            [_storeDictionary setObject:table forKey:@"confirmations"];
        }
        _confirmations = table;
    }
    if (CT) {
        NSString *signature = [CT base64Encode];
        [_confirmations setObject:signature forKey:ID.address];
    }
}

- (NSData *)confirmationForID:(const DIMID *)ID {
    NSString *signature = [self.confirmations objectForKey:ID.address];
    NSAssert(signature, @"confirmation not found for %@", ID);
    return [signature base64Decode];
}

@end

@implementation DIMHistoryTransaction (Link)

- (NSData *)previousSignature {
    return _operation.previousSignature;
}

@end
