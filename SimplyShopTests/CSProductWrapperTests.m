//
//  CSProductWrapperTests.m
//  SimplyShop
//
//  Created by Will Harris on 09/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>
#import <CSApi/CSAPI.h>

#import "SenTestCase+CSAsyncTestCase.h"

#import "CSProductWrapper.h"


@interface CSProductWrapperTests : SenTestCase

@end

@implementation CSProductWrapperTests

- (void)testWrapsProductProperties
{
    id product = [OCMockObject mockForProtocol:@protocol(CSProduct)];
    [[[product expect] andReturn:@"name"] name];
    [[[product expect] andReturn:@"description"] description_];
    
    CSProductWrapper *wrapper = [CSProductWrapper wrapperForProduct:product];
    STAssertEqualObjects(wrapper.name, @"name", nil);
    STAssertEqualObjects(wrapper.description_, @"description", nil);
    
    [product verify];
}

- (void)testWrapsProductPicture
{
    id product = [OCMockObject mockForProtocol:@protocol(CSProduct)];
    
    [[[product expect] andDo:^(NSInvocation *inv) {
        void (^cb)(id<CSPictureListPage> firstPage, NSError *error) = nil;
        [inv getArgument:&cb atIndex:2];
        cb((id) @"PAGE", nil);
    }] getPictures:OCMOCK_ANY];
    
    CSProductWrapper *wrapper = [CSProductWrapper wrapperForProduct:product];
    
    __block id page = @"NOT CALLED";
    __block id error = @"NOT CALLED";
    CALL_AND_WAIT(^(void (^done)()) {
        [wrapper getPictures:^(id<CSPictureListPage> firstPage,
                               NSError *anError) {
            page = firstPage;
            error = anError;
            done();
        }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertEqualObjects(page, @"PAGE", nil);
}

- (void)testWrapsProductPrices
{
    id product = [OCMockObject mockForProtocol:@protocol(CSProduct)];
    
    [[[product expect] andDo:^(NSInvocation *inv) {
        void (^cb)(id<CSPriceListPage> firstPage, NSError *error) = nil;
        [inv getArgument:&cb atIndex:2];
        cb((id) @"PAGE", nil);
    }] getPrices:OCMOCK_ANY];
    CSProductWrapper *wrapper = [CSProductWrapper wrapperForProduct:product];
    
    __block id page = @"NOT CALLED";
    __block id error = @"NOT CALLED";
    CALL_AND_WAIT(^(void (^done)()) {
        [wrapper getPrices:^(id<CSPriceListPage> firstPage,
                               NSError *anError) {
            page = firstPage;
            error = anError;
            done();
        }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertEqualObjects(page, @"PAGE", nil);
}

- (void)testWrapsProductSummaryProperties
{
    id summary = [OCMockObject mockForProtocol:@protocol(CSProductSummary)];
    [[[summary expect] andReturn:@"name"] name];
    [[[summary expect] andReturn:@"description"] description_];
    
    CSProductWrapper *wrapper = [CSProductWrapper wrapperForSummary:summary];
    STAssertEqualObjects(wrapper.name, @"name", nil);
    STAssertEqualObjects(wrapper.description_, @"description", nil);
    
    [summary verify];
}

- (void)testWrapsProductSummaryPicture
{
    id summary = [OCMockObject mockForProtocol:@protocol(CSProductSummary)];
    
    [[[summary expect] andDo:^(NSInvocation *inv) {
        void (^cb)(id<CSPictureListPage> firstPage, NSError *error) = nil;
        [inv getArgument:&cb atIndex:2];
        cb((id) @"PAGE", nil);
    }] getPictures:OCMOCK_ANY];
    
    CSProductWrapper *wrapper = [CSProductWrapper wrapperForSummary:summary];
    
    __block id page = @"NOT CALLED";
    __block id error = @"NOT CALLED";
    CALL_AND_WAIT(^(void (^done)()) {
        [wrapper getPictures:^(id<CSPictureListPage> firstPage,
                               NSError *anError) {
            page = firstPage;
            error = anError;
            done();
        }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertEqualObjects(page, @"PAGE", nil);
}

- (void)testWrapsProductSummaryPrices
{
    id summary = [OCMockObject mockForProtocol:@protocol(CSProductSummary)];
    id product = [OCMockObject mockForProtocol:@protocol(CSProduct)];
    
    [[[product expect] andDo:^(NSInvocation *inv) {
        void (^cb)(id<CSPriceListPage>, NSError *) = nil;
        [inv getArgument:&cb atIndex:2];
        cb((id) @"PAGE", nil);
    }] getPrices:OCMOCK_ANY];
    
    [[[summary expect] andDo:^(NSInvocation *inv) {
        void (^cb)(id<CSProduct>, NSError *) = nil;
        [inv getArgument:&cb atIndex:2];
        cb(product, nil);
    }] getProduct:OCMOCK_ANY];
    
    CSProductWrapper *wrapper = [CSProductWrapper wrapperForSummary:summary];
    
    __block id page = @"NOT CALLED";
    __block id error = @"NOT CALLED";
    CALL_AND_WAIT(^(void (^done)()) {
        [wrapper getPrices:^(id<CSPriceListPage> firstPage,
                               NSError *anError) {
            page = firstPage;
            error = anError;
            done();
        }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertEqualObjects(page, @"PAGE", nil);
}

@end
