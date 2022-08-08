// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2020 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2020 Albert Moky
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
//  DIMContent.h
//  DIMCore
//
//  Created by Albert Moky on 2020/12/8.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import <DaoKeDao/DaoKeDao.h>

NS_ASSUME_NONNULL_BEGIN

typedef __kindof id<DKDContent>_Nullable(^DIMContentParserBlock)(NSDictionary *content);

@interface DIMContentFactory : NSObject <DKDContentFactory>

@property (readonly, nonatomic, nullable) DIMContentParserBlock block;

- (instancetype)initWithBlock:(DIMContentParserBlock)block;

@end

#define DIMContentFactoryWithBlock(block)                                      \
            [[DIMContentFactory alloc] initWithBlock:(block)]                  \
                                   /* EOF 'DIMContentFactoryWithBlock(block)' */

#define DIMContentFactoryWithClass(clazz)                                      \
            DIMContentFactoryWithBlock(^(NSDictionary *content) {              \
                return [[clazz alloc] initWithDictionary:content];             \
            })                                                                 \
                                   /* EOF 'DIMContentFactoryWithClass(clazz)' */

#define DIMContentRegister(type, factory)                                      \
            DKDContentRegister(type, factory)                                  \
                                   /* EOF 'DIMContentRegister(type, factory)' */

#define DIMContentRegisterBlock(type, block)                                   \
            DIMContentRegister((type),                                         \
                                      DIMContentFactoryWithBlock(block))       \
                                /* EOF 'DIMContentRegisterBlock(type, block)' */

#define DIMContentRegisterClass(type, clazz)                                   \
            DIMContentRegister((type),                                         \
                                      DIMContentFactoryWithClass(clazz))       \
                                /* EOF 'DIMContentRegisterClass(type, clazz)' */

#ifdef __cplusplus
extern "C" {
#endif

/**
 *  Register Core Content Factories
 */
void DIMRegisterContentFactories(void);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
