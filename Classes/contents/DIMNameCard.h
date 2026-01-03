// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2023 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2023 Albert Moky
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
//  DIMNameCard.h
//  DIMCore
//
//  Created by Albert Moky on 2023/12/7.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <MingKeMing/Format.h>

#import <DIMCore/DIMContent.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Name Card content: {
 *
 *      "type" : i2s(0x33),
 *      "sn"   : 123,
 *
 *      "did"    : "{ID}",        // contact's ID
 *      "name"   : "{nickname}",  // contact's name
 *      "avatar" : "{URL}",       // avatar - PNF(URL)
 *      ...
 *  }
 */
@protocol DKDNameCard <DKDContent>

@property (readonly, strong, nonatomic) id<MKMID> identifier;

@property (readonly, strong, nonatomic) NSString *name;

@property (readonly, strong, nonatomic, nullable) id<MKPortableNetworkFile> avatar;

@end

@interface DIMNameCard : DIMContent <DKDNameCard>

- (instancetype)initWithID:(id<MKMID>)did
                      name:(NSString *)nickname
                    avatar:(id<MKPortableNetworkFile>)image;

@end

#pragma mark - Conveniences

#ifdef __cplusplus
extern "C" {
#endif

DIMNameCard *DIMNameCardCreate(id<MKMID> did, NSString *name,
                               _Nullable id<MKPortableNetworkFile> avatar);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
