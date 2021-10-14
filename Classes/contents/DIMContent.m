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
//  DIMContent.m
//  DIMCore
//
//  Created by Albert Moky on 2020/12/8.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import "DIMForwardContent.h"
#import "DIMTextContent.h"
#import "DIMFileContent.h"
#import "DIMImageContent.h"
#import "DIMAudioContent.h"
#import "DIMVideoContent.h"
#import "DIMWebpageContent.h"
#import "DIMMoneyContent.h"
#import "DIMTransferContent.h"

#import "DIMCommand.h"
#import "DIMHistoryCommand.h"

#import "DIMContent.h"

@interface DIMContentFactory () {
    
    DIMContentParserBlock _block;
}

@end

@implementation DIMContentFactory

- (instancetype)init {
    if (self = [super init]) {
        _block = NULL;
    }
    return self;
}

- (instancetype)initWithBlock:(DIMContentParserBlock)block {
    if (self = [super init]) {
        _block = block;
    }
    return self;
}

- (nullable __kindof id<DKDContent>)parseContent:(NSDictionary *)content {
    if (_block == NULL) {
        return [[DKDContent alloc] initWithDictionary:content];
    }
    return _block(content);
}

@end

#pragma mark - Register Parsers

@implementation DIMContentFactory (Register)

+ (void)registerContentFactories {
    
    // Top-Secret
    DIMContentFactoryRegisterClass(DKDContentType_Forward, DIMForwardContent);
    // Text
    DIMContentFactoryRegisterClass(DKDContentType_Text, DIMTextContent);
    
    // File
    DIMContentFactoryRegisterClass(DKDContentType_File, DIMFileContent);
    // Image
    DIMContentFactoryRegisterClass(DKDContentType_Image, DIMImageContent);
    // Audio
    DIMContentFactoryRegisterClass(DKDContentType_Audio, DIMAudioContent);
    // Video
    DIMContentFactoryRegisterClass(DKDContentType_Video, DIMVideoContent);
    
    // Web Page
    DIMContentFactoryRegisterClass(DKDContentType_Page, DIMWebpageContent);
    
    // Money
    DIMContentFactoryRegisterClass(DKDContentType_Money, DIMMoneyContent);
    DIMContentFactoryRegisterClass(DKDContentType_Transfer, DIMTransferContent);
    
    // Command
    id<DKDContentFactory> cmdParser = [[DIMCommandFactory alloc] init];
    DIMContentFactoryRegister(DKDContentType_Command, cmdParser);
    
    // History Command
    id<DKDContentFactory> hisParser = [[DIMHistoryCommandFactory alloc] init];
    DIMContentFactoryRegister(DKDContentType_History, hisParser);
    
    // unknown content type
    DIMContentFactoryRegisterClass(0, DKDContent);
}

@end
