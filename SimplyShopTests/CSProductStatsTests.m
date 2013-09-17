//
//  CSProductStatsTests.m
//  SimplyShop
//
//  Created by Will Harris on 30/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "SenTestCase+CSAsyncTestCase.h"
#import <OCMock/OCMock.h>
#import <CSApi/CSAPI.h>
#import "CSProductStats.h"

@interface TestProduct : NSObject <CSProduct>

@end

@implementation TestProduct

@end

@interface CSProductStatsTests : SenTestCase

@property (strong, nonatomic) id mockProduct;
@property (weak, nonatomic) id<CSProduct> product;

@end

@implementation CSProductStatsTests

@synthesize mockProduct;
@synthesize product;

- (void)setUp
{
    mockProduct = [OCMockObject mockForClass:[TestProduct class]];
    product = mockProduct;
}

- (CSProductStats *)statsWithDefaultMappings
{
    __block CSProductStats *stats = nil;
    __block id error = @"NOT CALLED";
    CALL_AND_WAIT(^(void (^done)()) {
        [CSProductStats loadProduct:product
                           callback:^(CSProductStats *theStats, NSError *anError)
         {
             stats = theStats;
             error = anError;
             done();
         }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(stats, nil);
    return stats;
}

- (id)authorWithName:(NSString *)name
{
    id mockAuthor = [OCMockObject mockForProtocol:@protocol(CSAuthor)];
    [[[mockAuthor stub] andReturn:name] name];
    return mockAuthor;
}

- (id)softwarePlatformWithName:(NSString *)name
{
    return name;
}

- (id)manufacturerWithName:(NSString *)name
{
    return name;
}

- (id)coverTypeWithName:(NSString *)name
{
    return name;
}

- (void)stubAuthor:(id)author
{
    [[[mockProduct stub] andDo:^(NSInvocation *inv) {
        void (^cb)(id<CSAuthor> result, NSError *error);
        [inv getArgument:&cb atIndex:2];
        cb(author, nil);
    }] getAuthor:OCMOCK_ANY];
}

- (void)stubSoftwarePlatform:(id)softwarePlatform
{
    [[[mockProduct stub] andReturn:softwarePlatform] softwarePlatform];
    [[[mockProduct stub] andReturn:softwarePlatform] valueForKey:@"softwarePlatform"];
}

- (void)stubManufacturer:(id)manufacturer
{
    [[[mockProduct stub] andReturn:manufacturer] manufacturer];
    [[[mockProduct stub] andReturn:manufacturer] valueForKey:@"manufacturer"];
}

- (void)stubCoverType:(id)coverType
{
    [[[mockProduct stub] andReturn:coverType] coverType];
    [[[mockProduct stub] andReturn:coverType] valueForKey:@"coverType"];
}

- (void)stubOnlyAuthor:(id)author
{
    [self stubAuthor:author];
    [self stubSoftwarePlatform:nil];
    [self stubManufacturer:nil];
    [self stubCoverType:nil];
}

- (void)testMockedAuthor
{
    id expectedAuthor = [self authorWithName:@"Test Author"];
    [self stubAuthor:expectedAuthor];
    
    __block id<CSAuthor> author = nil;
    __block id error = @"NOT CALLED";
    CALL_AND_WAIT(^(void (^done)()) {
        [product getAuthor:^(id anAuthor, NSError *anError) {
            author = anAuthor;
            error = anError;
            done();
        }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertEquals(author, expectedAuthor, nil);
}

- (void)testStatsHasStatForMapping
{
    NSString *authorName = @"Niccolò Machiavelli";
    [self stubOnlyAuthor:[self authorWithName:authorName]];
    CSProductStats *stats = [self statsWithDefaultMappings];
    
    STAssertEqualObjects(@([stats.stats count]), @(1), nil);
    
    CSProductStat *stat = [stats.stats objectAtIndex:0];
    STAssertTrue([stat isKindOfClass:[CSProductStat class]], nil);
    
    STAssertEqualObjects(stat.label, @"Author", nil);
    STAssertEqualObjects(stat.value, authorName, nil);
}

- (void)testStatsHasNoStatForNilNameAuthor
{
    NSString *authorName = nil;
    [self stubOnlyAuthor:[self authorWithName:authorName]];
    CSProductStats *stats = [self statsWithDefaultMappings];
    
    STAssertEqualObjects(@([stats.stats count]), @(0), nil);
}

- (void)testStatsHasNoStatForNullNameAuthor
{
    NSString *authorName = (NSString *) [NSNull null];
    [self stubOnlyAuthor:[self authorWithName:authorName]];
    CSProductStats *stats = [self statsWithDefaultMappings];
    
    STAssertEqualObjects(@([stats.stats count]), @(0), nil);
}

- (void)testStatsHasNoStatForMissingAuthor
{
    [self stubOnlyAuthor:nil];
    CSProductStats *stats = [self statsWithDefaultMappings];
    
    STAssertEqualObjects(@([stats.stats count]), @(0), nil);
}

- (void)testAllStatsPresent
{
    id author = [self authorWithName:@"Niccolò Machiavelli"];
    id softwarePlatform = [self softwarePlatformWithName:@"Kindle"];
    id manufacturer = [self manufacturerWithName:@"Amazon"];
    id coverType = [self coverTypeWithName:@"Ebook"];
    
    [self stubAuthor:author];
    [self stubSoftwarePlatform:softwarePlatform];
    [self stubManufacturer:manufacturer];
    [self stubCoverType:coverType];
    
    CSProductStats *stats = [self statsWithDefaultMappings];
    NSDictionary *expecedStats = @{@"Author": @"Niccolò Machiavelli",
                                   @"Platform": @"Kindle",
                                   @"Manufacturer": @"Amazon",
                                   @"Cover": @"Ebook"};
    
    NSMutableDictionary *actualStats = [[NSMutableDictionary alloc] init];
    for (CSProductStat *stat in stats.stats) {
        actualStats[stat.label] = stat.value;
    }
    
    STAssertEqualObjects(actualStats, expecedStats, nil);
}



- (void)testStatsHaveAlphabeticalOrder
{
    id author = [self authorWithName:@"Niccolò Machiavelli"];
    id softwarePlatform = [self softwarePlatformWithName:@"Kindle"];
    id manufacturer = [self manufacturerWithName:@"Amazon"];
    id coverType = [self coverTypeWithName:@"Ebook"];
    
    [self stubAuthor:author];
    [self stubSoftwarePlatform:softwarePlatform];
    [self stubManufacturer:manufacturer];
    [self stubCoverType:coverType];

    CSProductStats *stats = [self statsWithDefaultMappings];
    
    NSString *lastLabel = @"";
    for (CSProductStat *stat in stats.stats) {
        NSString *label = stat.label;
        NSComparisonResult order = [lastLabel
                                    localizedCaseInsensitiveCompare:label];
        STAssertTrue(order == NSOrderedAscending,
                     @"%@ should be before %@", label, lastLabel);
        lastLabel = label;
    }
}

@end
