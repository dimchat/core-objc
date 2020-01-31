//
//  DIMCoreTests.m
//  DIMCoreTests
//
//  Created by Albert Moky on 2018/12/20.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <DIMCore/DIMCore.h>

#import "NSObject+JsON.h"
#import "NSData+Extension.h"

@interface DIMCoreTests : XCTestCase

@end

@implementation DIMCoreTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testHash {
    
    NSString *string = @"moky";
    NSData *data = [string data];
    
    NSData *hash;
    NSString *res;
    NSString *exp;
    
    
    // md5（moky）= d0e5edd3fd12b89154bbe7a5e4c82569
    exp = @"d0e5edd3fd12b89154bbe7a5e4c82569";
    hash = [data md5];
    res = [hash hexEncode];
    NSLog(@"md5(%@) = %@", string, res);
    NSAssert([res isEqual:exp], @"md5 error: %@ != %@", res, exp);
    
}

@end
