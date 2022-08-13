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
//  DIMCommand.h
//  DIMCore
//
//  Created by Albert Moky on 2019/1/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMCore/DIMContent.h>

NS_ASSUME_NONNULL_BEGIN

/*
 *  Command message: {
 *      type : 0x88,
 *      sn   : 123,
 *
 *      cmd     : "...", // command name
 *      extra   : info   // command parameters
 *  }
 */
@protocol DIMCommand <DKDContent>

// command name
@property (readonly, strong, nonatomic) NSString *cmd;

@end

@protocol DIMCommandFactory <NSObject>

/**
 *  Parse map object to command
 *
 * @param command - command content
 * @return Command
 */
- (nullable id<DIMCommand>)parseCommand:(NSDictionary *)command;

@end

#ifdef __cplusplus
extern "C" {
#endif

id<DIMCommandFactory> DIMCommandGetFactory(NSString *cmd);
void DIMCommandSetFactory(NSString *cmd, id<DIMCommandFactory> factory);

// get command name
NSString *DIMCommandGetName(NSDictionary *command);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

#define DIMCommandFromDictionary(dict)    DIMCommandParse(dict)

#define DIMCommandRegister(cmd, factory)  DIMCommandSetFactory(cmd, factory)

#pragma mark - Base Command

@interface DIMCommand : DKDContent <DIMCommand>

- (instancetype)initWithType:(DKDContentType)type commandName:(NSString *)cmd;

- (instancetype)initWithCommandName:(NSString *)cmd;

@end

#pragma mark System Command

// command names
#define DIMCommand_Meta      @"meta"
#define DIMCommand_Document  @"document"

#pragma mark Command Factory

typedef id<DIMCommand>_Nullable(^DIMCommandParserBlock)(NSDictionary *command);

@interface DIMCommandFactory : NSObject <DKDContentFactory, DIMCommandFactory>

@property (readonly, nonatomic, nullable) DIMCommandParserBlock block;

- (instancetype)initWithBlock:(DIMCommandParserBlock)block;

@end

#define DIMCommandFactoryWithBlock(block)                                      \
            [[DIMCommandFactory alloc] initWithBlock:(block)]                  \
                                   /* EOF 'DIMCommandFactoryWithBlock(block)' */

#define DIMCommandFactoryWithClass(clazz)                                      \
            DIMCommandFactoryWithBlock(^(NSDictionary *command) {              \
                return [[clazz alloc] initWithDictionary:command];             \
            })                                                                 \
                                   /* EOF 'DIMCommandFactoryWithClass(clazz)' */

#define DIMCommandFactoryRegister(name, factory)                               \
            DIMCommandRegister(name, factory)                                  \
                            /* EOF 'DIMCommandFactoryRegister(name, factory)' */

#define DIMCommandFactoryRegisterBlock(name, block)                            \
            DIMCommandFactoryRegister((name),                                  \
                                      DIMCommandFactoryWithBlock(block))       \
                         /* EOF 'DIMCommandFactoryRegisterBlock(name, block)' */

#define DIMCommandFactoryRegisterClass(name, clazz)                            \
            DIMCommandFactoryRegister((name),                                  \
                                      DIMCommandFactoryWithClass(clazz))       \
                         /* EOF 'DIMCommandFactoryRegisterClass(name, clazz)' */

#ifdef __cplusplus
extern "C" {
#endif

/**
 *  Register Core Command Factories
 */
void DIMRegisterCommandFactories(void);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
