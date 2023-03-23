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
 *      command : "...", // command name
 *      extra   : info   // command parameters
 *  }
 */
@protocol DKDCommand <DKDContent>

// command name
@property (readonly, strong, nonatomic) NSString *cmd;

@end

@protocol DKDCommandFactory <NSObject>

/**
 *  Parse map object to command
 *
 * @param content - command content
 * @return Command
 */
- (nullable id<DKDCommand>)parseCommand:(NSDictionary *)content;

@end

#pragma mark - Base Command

@interface DIMCommand : DIMContent <DKDCommand>

- (instancetype)initWithType:(DKDContentType)type commandName:(NSString *)cmd;

- (instancetype)initWithCommandName:(NSString *)cmd;

@end

#pragma mark System Command

// command names
#define DIMCommand_Meta      @"meta"
#define DIMCommand_Document  @"document"

#ifdef __cplusplus
extern "C" {
#endif

id<DKDCommandFactory> DKDCommandGetFactory(NSString *cmd);
void DKDCommandSetFactory(NSString *cmd, id<DKDCommandFactory> factory);

id<DKDCommand> DKDCommandParse(id content);

DIMCommand *DIMCommandCreate(NSString *cmd);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
