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
//  DKDContentType.m
//  DIMCore
//
//  Created by Albert Moky on 2020/12/8.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import "DKDContentType.h"

NSString * DKDContentType_Any   = nil;

NSString * DKDContentType_Text  = nil;

NSString * DKDContentType_File  = nil;
NSString * DKDContentType_Image = nil;
NSString * DKDContentType_Audio = nil;
NSString * DKDContentType_Video = nil;

NSString * DKDContentType_Page     = nil;

NSString * DKDContentType_NameCard = nil;

NSString * DKDContentType_Quote    = nil;

NSString * DKDContentType_Money        = nil;
NSString * DKDContentType_Transfer     = nil;
NSString * DKDContentType_LuckyMoney   = nil;
NSString * DKDContentType_ClaimPayment = nil;
NSString * DKDContentType_SplitBill    = nil;

NSString * DKDContentType_Command      = nil;
NSString * DKDContentType_History      = nil;

NSString * DKDContentType_Application      = nil;
//NSString * DKDContentType_Application_1  = nil;
//           ...
//NSString * DKDContentType_Application_15 = nil;

//NSString * DKDContentType_Customized_0   = nil;
//NSString * DKDContentType_Customized_1   = nil;
//         .....
NSString * DKDContentType_Array            = nil;
//         ...
NSString * DKDContentType_Customized       = nil;
//         ...
NSString * DKDContentType_CombineForward   = nil;

NSString * DKDContentType_Forward          = nil;

static inline NSString *i2s(UInt8 value) {
    return [NSString stringWithFormat:@"%u", value];
}

void DKDInitializeContentTypes(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        DKDContentType_Any      = i2s(0x00); // 0000 0000 (Undefined)
        
        DKDContentType_Text     = i2s(0x01); // 0000 0001

        DKDContentType_File     = i2s(0x10); // 0001 0000
        DKDContentType_Image    = i2s(0x12); // 0001 0010
        DKDContentType_Audio    = i2s(0x14); // 0001 0100
        DKDContentType_Video    = i2s(0x16); // 0001 0110

        // Web Page
        DKDContentType_Page     = i2s(0x20); // 0010 0000

        // Name Card
        DKDContentType_NameCard = i2s(0x33); // 0011 0011

        // Quote a message before and reply it with text
        DKDContentType_Quote    = i2s(0x37); // 0011 0111

        DKDContentType_Money        = i2s(0x40); // 0100 0000
        DKDContentType_Transfer     = i2s(0x41); // 0100 0001
        DKDContentType_LuckyMoney   = i2s(0x42); // 0100 0010
        DKDContentType_ClaimPayment = i2s(0x48); // 0100 1000 (Claim for Payment)
        DKDContentType_SplitBill    = i2s(0x49); // 0100 1001 (Split the Bill)

        DKDContentType_Command      = i2s(0x88); // 1000 1000
        DKDContentType_History      = i2s(0x89); // 1000 1001 (Entity History Command)

        // Application Customized
        DKDContentType_Application       = i2s(0xA0); // 1010 0000 (Application 0nly, Reserved)
        // DKDContentType_Application_1  = i2s(0xA1); // 1010 0001 (Reserved)
        // ...                                        // 1010 ???? (Reserved)
        // DKDContentType_Application_15 = i2s(0xAF); // 1010 1111 (Reserved)
        
        // DKDContentType_Customized_0   = i2s(0xC0); // 1100 0000 (Reserved)
        // DKDContentType_Customized_1   = i2s(0xC1); // 1100 0001 (Reserved)
        // ...                                        // 1100 ???? (Reserved)
        DKDContentType_Array             = i2s(0xCA); // 1100 1010 (Content Array)
        // ...                                        // 1100 ???? (Reserved)
        DKDContentType_Customized        = i2s(0xCC); // 1100 1100 (Customized Content)
        // ...                                        // 1100 ???? (Reserved)
        DKDContentType_CombineForward    = i2s(0xCF); // 1100 1111 (Combine and Forward)

        // Top-Secret message forward by proxy (MTA)
        DKDContentType_Forward           = i2s(0xFF); // 1111 1111

    });
}

__attribute__((constructor))
static void autoInitializeContentTypes(void) {
    DKDInitializeContentTypes();
}
