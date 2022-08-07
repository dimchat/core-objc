// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
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
//  DIMEntity.h
//  DIMCore
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <MingKeMing/MingKeMing.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DIMEntityDataSource <NSObject>

/**
 *  Get meta for entity ID
 *
 * @param ID - entity ID
 * @return Meta
 */
- (nullable id<MKMMeta>)metaForID:(id<MKMID>)ID;

/**
 *  Get document for entity ID
 *
 * @param ID - entity ID
 * @param type - document type
 * @return Document
 */
- (nullable __kindof id<MKMDocument>)documentForID:(id<MKMID>)ID type:(nullable NSString *)type;

@end

@protocol DIMEntity <NSObject>

@property (readonly, copy, nonatomic) id<MKMID> ID;     // name@address

@property (readonly, nonatomic) UInt8 type;    // Network ID

@property (weak, nonatomic) __kindof id<DIMEntityDataSource> dataSource;

@property (readonly, strong, nonatomic) id<MKMMeta> meta;

/**
 *  Get entity document with type
 */
- (nullable __kindof id<MKMDocument>)documentWithType:(nullable NSString *)type;

@end

@interface DIMEntity : NSObject <DIMEntity, NSCopying>

- (instancetype)initWithID:(id<MKMID>)ID NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
