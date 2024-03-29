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
//  DIMFactoryManager.h
//  DIMCore
//
//  Created by Albert Moky on 2023/2/2.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <DIMCore/DIMCommand.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  General Factory for Commands
 *  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 */
@protocol DIMGeneralCommandFactory

#pragma mark Command

- (void)setCommandFactory:(id<DKDCommandFactory>)factory forName:(NSString *)cmd;
- (nullable id<DKDCommandFactory>)commandFactoryForName:(NSString *)cmd;

// get command name
- (nullable NSString *)getCmd:(NSDictionary<NSString *, id> *)content
                 defaultValue:(nullable NSString *)aValue;

- (nullable id<DKDCommand>)parseCommand:(nullable id)content;

@end

#pragma mark -

@interface DIMGeneralCommandFactory : NSObject <DIMGeneralCommandFactory>

@end

@interface DIMCommandFactoryManager : NSObject

@property(strong, nonatomic) id<DIMGeneralCommandFactory> generalFactory;

+ (instancetype)sharedManager;

@end

NS_ASSUME_NONNULL_END
