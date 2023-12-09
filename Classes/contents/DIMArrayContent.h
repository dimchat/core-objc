// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2022 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2022 Albert Moky
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
//  DIMArrayContent.h
//  DIMCore
//
//  Created by Albert Moky on 2022/8/8.
//  Copyright © 2022 DIM Group. All rights reserved.
//

#import <DIMCore/DIMContent.h>

NS_ASSUME_NONNULL_BEGIN

/*
 *  Content Array message: {
 *      type : 0xCA,
 *      sn   : 123,
 *
 *      contents : [...]  // content array
 *  }
 */
@protocol DKDArrayContent <DKDContent>

@property (readonly, atomic) NSArray<id<DKDContent>> *contents;

@end

@interface DIMArrayContent : DIMContent <DKDArrayContent>

- (instancetype)initWithContents:(NSArray<id<DKDContent>> *)array;

@end

#ifdef __cplusplus
extern "C" {
#endif

/**
 *  Convert content list from dictionary array
 */
NSArray<id<DKDContent>> *DKDContentConvert(NSArray<id> *contents);

/**
 *  Revert content list to dictionary array
 */
NSArray<NSDictionary *> *DKDContentRevert(NSArray<id<DKDContent>> *contents);

DIMArrayContent *DIMArrayContentCreate(NSArray<id<DKDContent>> *contents);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
