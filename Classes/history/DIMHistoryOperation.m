//
//  DIMHistoryOperation.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/5.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "DIMHistoryOperation.h"

@interface DIMHistoryOperation ()

@property (strong, nonatomic) NSString *command;
@property (strong, nonatomic) NSDate *time;

@end

@implementation DIMHistoryOperation

+ (instancetype)operationWithOperation:(id)op {
    if ([op isKindOfClass:[DIMHistoryOperation class]]) {
        return op;
    } else if ([op isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:op];
    } else if ([op isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithJSONString:op];
    } else {
        NSAssert(!op, @"unexpected operation: %@", op);
        return nil;
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _command = nil;
        _time = nil;
    }
    return self;
}

- (instancetype)initWithCommand:(const NSString *)op
                           time:(nullable const NSDate *)time {
    NSTimeInterval timestamp;
    if (time) {
        timestamp = [time timeIntervalSince1970];
    } else {
        timestamp = [[[NSDate alloc] init] timeIntervalSince1970];
    }
    NSDictionary *dict = @{@"command": op,
                           @"time"   : @(timestamp),
                           };
    if (self = [super initWithDictionary:dict]) {
        _command = [op copy];
        _time = [time copy];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMHistoryOperation *op = [super copyWithZone:zone];
    if (op) {
        op.command = _command;
        op.time = _time;
    }
    return op;
}

- (NSString *)command {
    if (!_command) {
        _command = [_storeDictionary objectForKey:@"command"];
    }
    return _command;
}

- (NSDate *)time {
    if (!_time) {
        NSNumber *timestamp = [_storeDictionary objectForKey:@"time"];
        NSAssert(timestamp, @"time error: %@", _storeDictionary);
        _time = [[NSDate alloc] initWithTimeIntervalSince1970:timestamp.doubleValue];
    }
    return _time;
}

@end

#pragma mark - Link Operation

@implementation DIMHistoryOperation (Link)

- (instancetype)initWithPreviousSignature:(const NSData *)prevSign
                                     time:(nullable const NSDate *)time {
    NSAssert(prevSign, @"previous signature cannot be empty");
    NSString *command = @"link";
    if (self = [self initWithCommand:command time:time]) {
        // previous signature
        if (prevSign) {
            NSString *CT = [prevSign base64Encode];
            [_storeDictionary setObject:CT forKey:@"prevSign"];
        }
    }
    return self;
}

- (NSData *)previousSignature {
    NSString *CT = nil;
    if ([_command isEqualToString:@"link"]) {
        CT = [_storeDictionary objectForKey:@"prevSign"];
        NSAssert(CT, @"previous signature cannot be empty in link command");
    }
    return [CT base64Decode];
}

@end
