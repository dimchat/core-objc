//
//  DIMBarrack+LocalStorage.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/11.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSDictionary+Binary.h"

#import "DIMBarrack+LocalStorage.h"

static inline NSString *document_directory(void) {
    NSArray *paths;
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                NSUserDomainMask, YES);
    return paths.firstObject;
}

static inline void make_dirs(NSString *dir) {
    // check base directory exists
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:dir isDirectory:nil]) {
        NSError *error = nil;
        // make sure directory exists
        [fm createDirectoryAtPath:dir withIntermediateDirectories:YES
                       attributes:nil error:&error];
        assert(!error);
    }
}

static inline BOOL file_exists(NSString *path) {
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm fileExistsAtPath:path];
}

static NSString *s_directory = nil;

static inline NSString *base_directory(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (s_directory == nil) {
            NSString *dir = document_directory();
            dir = [dir stringByAppendingPathComponent:@".mkm"];
            s_directory = dir;
        }
    });
    return s_directory;
}

/**
 Get meta filepath in Documents Directory
 
 @param ID - entity ID
 @return "Documents/.mkm/{address}/meta.plist"
 */
static inline NSString *meta_filepath(const DIMID *ID, BOOL autoCreate) {
    NSString *dir = base_directory();
    dir = [dir stringByAppendingPathComponent:(NSString *)ID.address];
    // check base directory exists
    if (autoCreate && !file_exists(dir)) {
        // make sure directory exists
        make_dirs(dir);
    }
    return [dir stringByAppendingPathComponent:@"meta.plist"];
}

@implementation DIMBarrack (LocalStorage)

// "Documents/.mkm"
- (NSString *)directory {
    return base_directory();
}

- (void)setDirectory:(NSString *)directory {
    s_directory = directory;
}

- (nullable const DIMMeta *)loadMetaForID:(const DIMID *)ID {
    NSString *path = meta_filepath(ID, NO);
    if (file_exists(path)) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        return [[DIMMeta alloc] initWithDictionary:dict];
    }
    return nil;
}

- (BOOL)saveMeta:(const DIMMeta *)meta forEntityID:(const DIMID *)ID {
    if (![self setMeta:meta forID:ID]) {
        // meta not match ID
        return NO;
    }
    
    NSString *path = meta_filepath(ID, YES);
    if (file_exists(path)) {
        NSLog(@"meta file already exists: %@, IGNORE!", path);
        return YES;
    }
    return [meta writeToBinaryFile:path];
}

@end
