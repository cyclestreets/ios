//
//  RouteManagerTest.m
//  CycleStreets
//
//  Created by Neil Edwards on 25/06/2015.
//  Copyright (c) 2015 CycleStreets Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "RouteManager.h"

@interface RouteManagerTest : XCTestCase

@end

@implementation RouteManagerTest

- (void)setUp {
    [super setUp];
	
	[RouteManager sharedInstance];
	
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

-(void)testloadRouteForFileID{
	
	RouteVO *route=[[RouteManager sharedInstance]loadRouteForFileID:EMPTYSTRING];
	
	XCTAssert(route==nil, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
