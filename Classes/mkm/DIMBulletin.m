// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2018 Albert Moky
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// =============================================================================
//
//  DIMBulletin.m
//  DIMCore
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMBulletin.h"

@interface DIMBulletin () {
    
    // Bot ID list as group assistants
    NSArray<id<MKMID>> *_bots;
}

@end

@implementation DIMBulletin

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _bots = nil;
    }
    return self;
}

- (instancetype)initWithIdentifier:(id<MKMID>)did
                              data:(NSString *)json
                         signature:(id<MKTransportableData>)CT {
    if (self = [super initWithIdentifier:did data:json signature:CT]) {
        // lazy
        _bots = nil;
    }
    return self;
}

- (instancetype)initWithIdentifier:(id<MKMID>)did type:(NSString *)type {
    if (self = [super initWithIdentifier:did type:type]) {
        // lazy
        _bots = nil;
    }
    return self;
}

- (instancetype)initWithIdentifier:(id<MKMID>)did {
    return [self initWithIdentifier:did type:MKMDocumentType_Bulletin];
}

// Override
- (nullable id<MKMID>)founder {
    return MKMIDParse([self objectForKey:@"founder"]);
}

// Override
- (nullable NSArray<id<MKMID>> *)assistants {
    if (!_bots) {
        id bots = [self propertyForKey:@"assistants"];
        if ([bots isKindOfClass:[NSArray class]]) {
            _bots = MKMIDConvert(bots);
        } else {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            // get from 'assistant'
            id single = [self propertyForKey:@"assistant"];
            single = MKMIDParse(single);
            if (single != nil) {
                [array addObject:single];
            }
            _bots = array;
        }
    }
    return _bots;
}

// Override
- (void)setAssistants:(NSArray<id<MKMID>> *)assistants {
    id array = [assistants count] == 0 ? nil : MKMIDRevert(assistants);
    [self setProperty:array forKey:@"assistants"];
    [self setProperty:nil forKey:@"assistant"];
    _bots = assistants;
}

@end
