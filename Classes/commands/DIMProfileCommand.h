// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2019 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
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
//  DIMProfileCommand.h
//  DIMCore
//
//  Created by Albert Moky on 2019/2/3.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMMetaCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMProfileCommand : DIMMetaCommand

@property (readonly, strong, nonatomic, nullable) DIMProfile *profile;

// current signature string for querying profile,
// if this matched, the station will respond 304 (Not Modified)
@property (readonly, strong, nonatomic, nullable) NSString *signature;

/*
 *  Command message: {
 *      type : 0x88,
 *      sn   : 123,
 *
 *      command   : "profile", // command name
 *      ID        : "{ID}",    // entity ID
 *      meta      : {...},     // only for handshaking with new friend
 *      profile   : {...}      // when profile is empty, means query for ID
 *  }
 */
- (instancetype)initWithID:(DIMID *)ID
                      meta:(nullable DIMMeta *)meta
                   profile:(nullable DIMProfile *)profile;

- (instancetype)initWithID:(DIMID *)ID
                   profile:(DIMProfile *)profile;

// query profile
- (instancetype)initWithID:(DIMID *)ID;

// query profile for updating with current signature
- (instancetype)initWithID:(MKMID *)ID signature:(NSString *)signature;

@end

NS_ASSUME_NONNULL_END
