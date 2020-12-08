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

#import "DIMContent.h"

@implementation DIMContentParser

- (nullable __kindof id<DKDContent>)parse:(NSDictionary *)content {
    NSNumber *number = [content objectForKey:@"type"];
    DKDContentType type = [number unsignedCharValue];
    switch (type) {
        case DKDContentType_Forward: {
            return [[DIMForwardContent alloc] initWithDictionary:content];
        }
            break;
            
        case DKDContentType_Text: {
            return [[DIMTextContent alloc] initWithDictionary:content];
        }
            break;
            
        case DKDContentType_File: {
            return [[DIMFileContent alloc] initWithDictionary:content];
        }
            break;
            
        case DKDContentType_Image: {
            return [[DIMImageContent alloc] initWithDictionary:content];
        }
            break;
            
        case DKDContentType_Audio: {
            return [[DIMAudioContent alloc] initWithDictionary:content];
        }
            break;
            
        case DKDContentType_Video: {
            return [[DIMVideoContent alloc] initWithDictionary:content];
        }
            break;
            
        case DKDContentType_Page: {
            return [[DIMWebpageContent alloc] initWithDictionary:content];
        }
            break;
            
        default:
            break;
    }
    // default content
    return [[DKDContent alloc] initWithDictionary:content];
}

@end
