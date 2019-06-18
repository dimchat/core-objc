//
//  DIMFileContent.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "DIMContentType.h"

#import "DIMFileContent.h"

@implementation DIMFileContent

- (instancetype)initWithFileData:(const NSData *)data
                        filename:(nullable const NSString *)name {
    NSAssert(data.length > 0, @"file data cannot be empty");
    if (self = [self initWithType:DIMContentType_File]) {
        
        // filename
        if (name) {
            [_storeDictionary setObject:name forKey:@"filename"];
        }
        
        // file data
        self.fileData = data;
    }
    return self;
}

- (nullable NSURL *)URL {
    NSString *string = [_storeDictionary objectForKey:@"URL"];
    if (string) {
        return [NSURL URLWithString:string];
    }
    return nil;
}

- (void)setURL:(NSURL *)URL {
    NSString *string = [URL absoluteString];
    if (string) {
        [_storeDictionary setObject:string forKey:@"URL"];
    } else {
        [_storeDictionary removeObjectForKey:@"URL"];
    }
}

- (nullable const NSData *)fileData {
//    return _attachment;
    return nil;
}

- (void)setFileData:(const NSData *)fileData {
//    _attachment = fileData;
    
    // update filename with MD5 string
    if (fileData.length > 0) {
        NSString *filename = [[fileData md5] hexEncode];
        NSString *ext = [[self.filename pathExtension] lowercaseString];
        if (ext.length > 0) {
            filename = [NSString stringWithFormat:@"%@.%@", filename, ext];
        }
        //NSAssert([self.filename isEqualToString:filename], @"filename error");
        [_storeDictionary setObject:filename forKey:@"filename"];
    }
}

- (nullable NSString *)filename {
    return [_storeDictionary objectForKey:@"filename"];
}

@end
