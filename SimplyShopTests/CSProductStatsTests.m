//
//  CSProductStatsTests.m
//  SimplyShop
//
//  Created by Will Harris on 30/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
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

- (void)testRemembersMappings
{
    NSDictionary *mappings = @{@"author": @"Author"};
    CSProductStats *stats = [[CSProductStats alloc] initWithMappings:mappings];
    STAssertEqualObjects(stats.mappings, mappings, nil);
}

- (void)testStatsHasStatForMapping
{
    NSDictionary *mappings = @{@"author": @"Author"};
    CSProductStats *stats = [[CSProductStats alloc] initWithMappings:mappings];
    
    NSString *authorName = @"Niccolò Machiavelli";
    [[[mockProduct stub] andReturn:authorName] author];
    [[[mockProduct stub] andReturn:authorName] valueForKey:@"author"];
    stats.product = product;
    
    STAssertEqualObjects(@([stats.stats count]), @(1), nil);
    
    CSProductStat *stat = [stats.stats objectAtIndex:0];
    STAssertTrue([stat isKindOfClass:[CSProductStat class]], nil);
    
    STAssertEqualObjects(stat.label, @"Author", nil);
    STAssertEqualObjects(stat.value, authorName, nil);
}

- (void)testStatsHasNoStatForNilMapping
{
    NSDictionary *mappings = @{@"author": @"Author"};
    CSProductStats *stats = [[CSProductStats alloc] initWithMappings:mappings];
    
    NSString *authorName = nil;
    [[[mockProduct stub] andReturn:authorName] author];
    [[[mockProduct stub] andReturn:authorName] valueForKey:@"author"];
    stats.product = product;
    
    STAssertEqualObjects(@([stats.stats count]), @(0), nil);
}

- (void)testStatsHasNoStatForNullMapping
{
    NSDictionary *mappings = @{@"author": @"Author"};
    CSProductStats *stats = [[CSProductStats alloc] initWithMappings:mappings];
    
    NSString *authorName = (NSString *) [NSNull null];
    [[[mockProduct stub] andReturn:authorName] author];
    [[[mockProduct stub] andReturn:authorName] valueForKey:@"author"];
    stats.product = product;
    
    STAssertEqualObjects(@([stats.stats count]), @(0), nil);
}

- (void)testDefaultMappings
{
    NSDictionary *mappings = @{@"author": @"Author",
                               @"softwarePlatform": @"Platform",
                               @"manufacturer": @"Manfacturer",
                               @"coverType": @"Cover"};
    CSProductStats *stats = [[CSProductStats alloc] init];
    STAssertEqualObjects(stats.mappings, mappings, nil);
}

- (void)testStatsHaveAlphabeticalOrder
{
    CSProductStats *stats = [[CSProductStats alloc] init];
    
    NSString *author = @"Niccolò Machiavelli";
    NSString *softwarePlatform = @"Kindle";
    NSString *manufacturer = @"Amazon";
    NSString *coverType = @"Ebook";
    
    [[[mockProduct stub] andReturn:author] author];
    [[[mockProduct stub] andReturn:author] valueForKey:@"author"];

    [[[mockProduct stub] andReturn:softwarePlatform] softwarePlatform];
    [[[mockProduct stub] andReturn:softwarePlatform] valueForKey:@"softwarePlatform"];

    [[[mockProduct stub] andReturn:manufacturer] manufacuturer];
    [[[mockProduct stub] andReturn:manufacturer] valueForKey:@"manufacturer"];

    [[[mockProduct stub] andReturn:coverType] coverType];
    [[[mockProduct stub] andReturn:coverType] valueForKey:@"coverType"];

    stats.product = product;
    
    STAssertEqualObjects(@([stats.stats count]), @([stats.mappings count]), nil);
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
