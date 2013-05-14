//
//  CSPriceContextTests.m
//  SimplyShop
//
//  Created by Will Harris on 03/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "CSPriceContext.h"
#import <OCMock/OCMock.h>
#import <CSApi/CSAPI.h>
#import <NSArray+Functional/NSArray+Functional.h>
#import "SenTestCase+CSAsyncTestCase.h"

@interface FakeList : NSObject <CSPriceList, CSLikeList>

@property (strong, nonatomic) NSArray *things;

+ (id)fakeListWithThings:(NSArray *)things;
+ (id)fakeListWithLikedURLs:(NSArray *)likedURLs;

@end

@implementation FakeList

+ (id)fakeListWithThings:(NSArray *)things
{
    FakeList *result = [[FakeList alloc] init];
    result.things = things;
    return result;
}

+ (id)fakeListWithLikedURLs:(NSArray *)likedURLs
{
    NSArray *things = [likedURLs mapUsingBlock:^id<CSLike>(NSURL *obj) {
        id result = [OCMockObject mockForProtocol:@protocol(CSLike)];
        [[[result stub] andReturn:obj] likedURL];
        return result;
    }];
    return [FakeList fakeListWithThings:things];
}

- (NSUInteger)count
{
    return [_things count];
}

- (void)getThingAtIndex:(NSUInteger)index
               callback:(void (^)(id, NSError *))callback
{
    if (index >= [_things count]) {
        NSError *error = [NSError errorWithDomain:@"FakeList.OutOfRange"
                                             code:0
                                         userInfo:nil];
        callback(nil, error);
        return;
    }
    
    callback([_things objectAtIndex:index], nil);
}

- (void)getPriceAtIndex:(NSUInteger)index
               callback:(void (^)(id<CSPrice>, NSError *))callback
{
    [self getThingAtIndex:index callback:callback];
}

- (void)getLikeAtIndex:(NSUInteger)index
               callback:(void (^)(id<CSLike>, NSError *))callback
{
    [self getThingAtIndex:index callback:callback];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FakeList: things=%@>", self.things];
}

@end

@interface FakePrice : NSObject

@property (nonatomic) NSDecimalNumber *effectivePrice;
@property (nonatomic) NSDecimalNumber *price;
@property (nonatomic) NSDecimalNumber *deliveryPrice;
@property (nonatomic) NSURL *retailerURL;

+ (id<CSPrice>)priceWithEffectivePrice:(NSString *)effectivePrice
                          stickerPrice:(NSString *)stickerPrice
                           retailerURL:(NSURL *)retailerURL;

@end

@implementation FakePrice

+ (id<CSPrice>)priceWithEffectivePrice:(NSString *)effectivePrice
                          stickerPrice:(NSString *)stickerPrice
                           retailerURL:(NSURL *)retailerURL
{
    FakePrice *price = [[FakePrice alloc] init];
    price.effectivePrice = [NSDecimalNumber decimalNumberWithString:effectivePrice];
    price.price = [NSDecimalNumber decimalNumberWithString:stickerPrice];
    price.deliveryPrice = [price.effectivePrice decimalNumberBySubtracting:price.price];
    price.retailerURL = retailerURL;
    return (id) price;
}

- (BOOL)isEqual:(id)object
{
    if ( ! [object isKindOfClass:[FakePrice class]]) {
        return NO;
    }
    
    return self == object;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ at %@",
            self.effectivePrice, self.retailerURL];
}

@end


@interface CSPriceContextTests : SenTestCase

@end

@implementation CSPriceContextTests

- (id<CSLikeList>)noLikes
{
    return [FakeList fakeListWithThings:[NSArray array]];
}

- (id<CSPriceList>)noPrices
{
    return [FakeList fakeListWithThings:[NSArray array]];
}

- (NSURL *)dislikedRetailer0
{
    return [NSURL URLWithString:@"http://localhost/retailers/0-disliked"];
}

- (NSURL *)dislikedRetailer1
{
    return [NSURL URLWithString:@"http://localhost/retailers/1-disliked"];
}

- (NSURL *)dislikedRetailer2
{
    return [NSURL URLWithString:@"http://localhost/retailers/2-disliked"];
}

- (NSURL *)dislikedRetailer6
{
    return [NSURL URLWithString:@"http://localhost/retailers/6-disliked"];
}

- (NSURL *)likedRetailer3
{
    return [NSURL URLWithString:@"http://localhost/retailers/3-liked"];
}

- (NSURL *)likedRetailer4
{
    return [NSURL URLWithString:@"http://localhost/retailers/4-liked"];
}

- (NSURL *)likedRetailer5
{
    return [NSURL URLWithString:@"http://localhost/retailers/5-liked"];
}

- (id<CSLikeList>)someLikes
{
    return [FakeList fakeListWithLikedURLs:@[
            [self likedRetailer3],
            [self likedRetailer4],
            [self likedRetailer5]]];
}

- (id<CSPrice>)lowestEffectivePrice:(NSURL *)retailerURL
{
    return [FakePrice priceWithEffectivePrice:@"15.00"
                                 stickerPrice:@"14.00"
                                  retailerURL:retailerURL];
}

- (id<CSPrice>)lowestStickerPrice:(NSURL *)retailerURL
{
    return [FakePrice priceWithEffectivePrice:@"16.00"
                                 stickerPrice:@"13.00"
                                  retailerURL:retailerURL];
}

- (id<CSPrice>)highestPrice:(NSURL *)retailerURL
{
    return [FakePrice priceWithEffectivePrice:@"17.00"
                                 stickerPrice:@"16.50"
                                  retailerURL:retailerURL];
}

- (void)testRemembersLikeList
{
    id<CSLikeList> likeList = [self noLikes];
    CSPriceContext *context = [[CSPriceContext alloc] initWithLikeList:likeList];
    STAssertEquals(context.likeList, likeList, nil);
    STAssertNil(context.retailer, @"%@", context.retailer);
}

- (id<CSRetailer>)retailerWithURL:(NSURL *)url
{
    id result = [OCMockObject mockForProtocol:@protocol(CSRetailer)];
    [[[result stub] andReturn:url] URL];
    return result;
}

- (void)testRemembersLikeListAndRetailer
{
    id<CSLikeList> likeList = [self noLikes];
    id<CSRetailer> retailer = [self retailerWithURL:[self likedRetailer3]];
    CSPriceContext *context = [[CSPriceContext alloc] initWithLikeList:likeList
                                                              retailer:retailer];
    STAssertEquals(context.likeList, likeList, nil);
    STAssertEqualObjects(context.retailer, retailer, nil);
}

- (void)testChoosesNilWhenNilPrices
{
    id likeList = [self noLikes];
    id<CSRetailer> retailer = [self retailerWithURL:[self likedRetailer3]];
    CSPriceContext *context = [[CSPriceContext alloc] initWithLikeList:likeList
                                                              retailer:retailer];
    
    __block id bestPrice = @"NOT CALLED";
    
    CALL_AND_WAIT(^(void (^done)()) {
        [context getBestPrice:nil callback:^(id<CSPrice> result) {
            bestPrice = result;
            done();
        }];
    });
    STAssertNil(bestPrice, @"%@", bestPrice);
}

- (void)testChoosesNilWhenNoPrices
{
    id likeList = [self noLikes];
    id<CSRetailer> retailer = [self retailerWithURL:[self likedRetailer3]];
    CSPriceContext *context = [[CSPriceContext alloc] initWithLikeList:likeList
                                                              retailer:retailer];

    __block id bestPrice = @"NOT CALLED";
    
    CALL_AND_WAIT(^(void (^done)()) {
        [context getBestPrice:[self noPrices] callback:^(id<CSPrice> result) {
            bestPrice = result;
            done();
        }];
    });
    
    STAssertNil(bestPrice, @"%@", bestPrice);
}

- (void)testChoosesLowestEffectivePriceWhenNoRetailerAndNoLikes
{
    id likeList = [self noLikes];
    CSPriceContext *context = [[CSPriceContext alloc] initWithLikeList:likeList];
    
    id expectedPrice = [self lowestEffectivePrice:[self dislikedRetailer1]];
    id prices = [FakeList fakeListWithThings:
                 @[
                   [self highestPrice:[self dislikedRetailer0]],
                   expectedPrice,
                   [self lowestStickerPrice:[self dislikedRetailer2]]
                 ]];
    
    __block id bestPrice = @"NOT CALLED";
    
    CALL_AND_WAIT(^(void (^done)()) {
        [context getBestPrice:prices callback:^(id<CSPrice> result) {
            bestPrice = result;
            done();
        }];
    });
    
    STAssertEqualObjects(bestPrice, expectedPrice, nil);
}

- (void)testChoosesLowestEffectivePriceWhenNoPriceForRetailerAndNoLikes
{
    id likeList = [self noLikes];
    id<CSRetailer> retailer = [self retailerWithURL:[self dislikedRetailer6]];
    CSPriceContext *context = [[CSPriceContext alloc] initWithLikeList:likeList
                                                              retailer:retailer];
    
    id expectedPrice = [self lowestEffectivePrice:[self dislikedRetailer1]];
    id prices = [FakeList fakeListWithThings:
                 @[
                 [self highestPrice:[self dislikedRetailer0]],
                 expectedPrice,
                 [self lowestStickerPrice:[self dislikedRetailer2]]
                 ]];
    
    __block id bestPrice = @"NOT CALLED";
    
    CALL_AND_WAIT(^(void (^done)()) {
        [context getBestPrice:prices callback:^(id<CSPrice> result) {
            bestPrice = result;
            done();
        }];
    });
    
    STAssertEqualObjects(bestPrice, expectedPrice, nil);
}

- (void)testChoosesRetailerPriceWhenRetailerButNoLikes
{
    id likeList = [self noLikes];
    id<CSRetailer> retailer = [self retailerWithURL:[self dislikedRetailer0]];
    CSPriceContext *context = [[CSPriceContext alloc] initWithLikeList:likeList
                                                              retailer:retailer];
    
    id expectedPrice = [self highestPrice:retailer.URL];
    id prices = [FakeList fakeListWithThings:
                 @[
                 expectedPrice,
                 [self lowestEffectivePrice:[self dislikedRetailer1]],
                 [self lowestStickerPrice:[self dislikedRetailer2]]
                 ]];
    
    __block id bestPrice = @"NOT CALLED";
    
    CALL_AND_WAIT(^(void (^done)()) {
        [context getBestPrice:prices callback:^(id<CSPrice> result) {
            bestPrice = result;
            done();
        }];
    });
    
    STAssertEqualObjects(bestPrice, expectedPrice, nil);
}

// TODO: test for multiple prices for selected retailer

- (void)testChoosesLowestEffectivePriceWhenNoRetailerAndNilLikes
{
    id likeList = nil;
    CSPriceContext *context = [[CSPriceContext alloc] initWithLikeList:likeList];
    
    id expectedPrice = [self lowestEffectivePrice:[self dislikedRetailer1]];
    id prices = [FakeList fakeListWithThings:
                 @[
                 [self highestPrice:[self dislikedRetailer0]],
                 expectedPrice,
                 [self lowestStickerPrice:[self dislikedRetailer2]]
                 ]];
    
    __block id bestPrice = @"NOT CALLED";
    
    CALL_AND_WAIT(^(void (^done)()) {
        [context getBestPrice:prices callback:^(id<CSPrice> result) {
            bestPrice = result;
            done();
        }];
    });
    
    STAssertEqualObjects(bestPrice, expectedPrice, nil);
}

- (void)testChoosesLowestEffectivePriceWhenNoPricesForRetailerAndNilLikes
{
    id likeList = nil;
    id<CSRetailer> retailer = [self retailerWithURL:[self dislikedRetailer6]];
    CSPriceContext *context = [[CSPriceContext alloc] initWithLikeList:likeList
                                                              retailer:retailer];
    
    id expectedPrice = [self lowestEffectivePrice:[self dislikedRetailer1]];
    id prices = [FakeList fakeListWithThings:
                 @[
                 [self highestPrice:[self dislikedRetailer0]],
                 expectedPrice,
                 [self lowestStickerPrice:[self dislikedRetailer2]]
                 ]];
    
    __block id bestPrice = @"NOT CALLED";
    
    CALL_AND_WAIT(^(void (^done)()) {
        [context getBestPrice:prices callback:^(id<CSPrice> result) {
            bestPrice = result;
            done();
        }];
    });
    
    STAssertEqualObjects(bestPrice, expectedPrice, nil);
}

- (void)testChoosesRetailerPriceWhenRetailerButNilLikes
{
    id likeList = nil;
    id<CSRetailer> retailer = [self retailerWithURL:[self dislikedRetailer0]];
    CSPriceContext *context = [[CSPriceContext alloc] initWithLikeList:likeList
                                                              retailer:retailer];
    
    id expectedPrice = [self highestPrice:retailer.URL];
    id prices = [FakeList fakeListWithThings:
                 @[
                 expectedPrice,
                 [self lowestEffectivePrice:[self dislikedRetailer1]],
                 [self lowestStickerPrice:[self dislikedRetailer2]]
                 ]];
    
    __block id bestPrice = @"NOT CALLED";
    
    CALL_AND_WAIT(^(void (^done)()) {
        [context getBestPrice:prices callback:^(id<CSPrice> result) {
            bestPrice = result;
            done();
        }];
    });
    
    STAssertEqualObjects(bestPrice, expectedPrice, nil);
}

- (void)testChoosesLowestEffectivePriceWhenNoRetailerAndAllPricesDisliked
{
    id likeList = [self someLikes];
    CSPriceContext *context = [[CSPriceContext alloc] initWithLikeList:likeList];
    
    id expectedPrice = [self lowestEffectivePrice:[self dislikedRetailer1]];
    id prices = [FakeList fakeListWithThings:
                 @[
                 [self highestPrice:[self dislikedRetailer0]],
                 expectedPrice,
                 [self lowestStickerPrice:[self dislikedRetailer2]]
                 ]];
    
    __block id bestPrice = @"NOT CALLED";
    
    CALL_AND_WAIT(^(void (^done)()) {
        [context getBestPrice:prices callback:^(id<CSPrice> result) {
            bestPrice = result;
            done();
        }];
    });
    
    STAssertEqualObjects(bestPrice, expectedPrice, nil);
}

- (void)testChoosesLowestEffectivePriceWhenNoPriceForRetailerAndAllPricesDisliked
{
    id likeList = [self someLikes];
    id<CSRetailer> retailer = [self retailerWithURL:[self dislikedRetailer6]];
    CSPriceContext *context = [[CSPriceContext alloc] initWithLikeList:likeList
                                                              retailer:retailer];
    
    id expectedPrice = [self lowestEffectivePrice:[self dislikedRetailer1]];
    id prices = [FakeList fakeListWithThings:
                 @[
                 [self highestPrice:[self dislikedRetailer0]],
                 expectedPrice,
                 [self lowestStickerPrice:[self dislikedRetailer2]]
                 ]];
    
    __block id bestPrice = @"NOT CALLED";
    
    CALL_AND_WAIT(^(void (^done)()) {
        [context getBestPrice:prices callback:^(id<CSPrice> result) {
            bestPrice = result;
            done();
        }];
    });
    
    STAssertEqualObjects(bestPrice, expectedPrice, nil);
}

- (void)testChoosesRetailerPriceWhenRetailerAndAllPricesDisliked
{
    id likeList = [self someLikes];
    id<CSRetailer> retailer = [self retailerWithURL:[self dislikedRetailer0]];
    CSPriceContext *context = [[CSPriceContext alloc] initWithLikeList:likeList
                                                              retailer:retailer];
    
    id expectedPrice = [self highestPrice:retailer.URL];
    id prices = [FakeList fakeListWithThings:
                 @[
                 expectedPrice,
                 [self lowestEffectivePrice:[self dislikedRetailer1]],
                 [self lowestStickerPrice:[self dislikedRetailer2]]
                 ]];
    
    __block id bestPrice = @"NOT CALLED";
    
    CALL_AND_WAIT(^(void (^done)()) {
        [context getBestPrice:prices callback:^(id<CSPrice> result) {
            bestPrice = result;
            done();
        }];
    });
    
    STAssertEqualObjects(bestPrice, expectedPrice, nil);
}

- (void)testChoosesOnlyLikeWhenNoRetailerEvenWhenNotLowestEffectivePrice
{
    id likeList = [self someLikes];
    CSPriceContext *context = [[CSPriceContext alloc] initWithLikeList:likeList];
    
    id expectedPrice = [self highestPrice:[self likedRetailer3]];
    id prices = [FakeList fakeListWithThings:
                 @[
                 expectedPrice,
                 [self lowestEffectivePrice:[self dislikedRetailer1]],
                 [self lowestStickerPrice:[self dislikedRetailer2]]
                 ]];
    
    __block id bestPrice = @"NOT CALLED";
    
    CALL_AND_WAIT(^(void (^done)()) {
        [context getBestPrice:prices callback:^(id<CSPrice> result) {
            bestPrice = result;
            done();
        }];
    });
    
    STAssertEqualObjects(bestPrice, expectedPrice, nil);
}

- (void)testChoosesOnlyLikeWhenNoPriceForRetailerEvenWhenNotLowestEffectivePrice
{
    id likeList = [self someLikes];
    id<CSRetailer> retailer = [self retailerWithURL:[self dislikedRetailer6]];
    CSPriceContext *context = [[CSPriceContext alloc] initWithLikeList:likeList
                                                              retailer:retailer];
    
    id expectedPrice = [self highestPrice:[self likedRetailer3]];
    id prices = [FakeList fakeListWithThings:
                 @[
                 expectedPrice,
                 [self lowestEffectivePrice:[self dislikedRetailer1]],
                 [self lowestStickerPrice:[self dislikedRetailer2]]
                 ]];
    
    __block id bestPrice = @"NOT CALLED";
    
    CALL_AND_WAIT(^(void (^done)()) {
        [context getBestPrice:prices callback:^(id<CSPrice> result) {
            bestPrice = result;
            done();
        }];
    });
    
    STAssertEqualObjects(bestPrice, expectedPrice, nil);
}

- (void)testChoosesLikeWithLowestEffectivePriceWhenNoRetailer
{
    id likeList = [self someLikes];
    CSPriceContext *context = [[CSPriceContext alloc] initWithLikeList:likeList];
    
    id expectedPrice = [self lowestStickerPrice:[self likedRetailer3]];
    id prices = [FakeList fakeListWithThings:
                 @[
                 [self highestPrice:[self likedRetailer4]],
                 expectedPrice,
                 [self lowestEffectivePrice:[self dislikedRetailer0]]
                 ]];
    
    __block id bestPrice = @"NOT CALLED";
    
    CALL_AND_WAIT(^(void (^done)()) {
        [context getBestPrice:prices callback:^(id<CSPrice> result) {
            bestPrice = result;
            done();
        }];
    });
    
    STAssertEqualObjects(bestPrice, expectedPrice, nil);
}

- (void)testChoosesLikeWithLowestEffectivePriceWhenNoPriceForRetailer
{
    id likeList = [self someLikes];
    id<CSRetailer> retailer = [self retailerWithURL:[self dislikedRetailer6]];
    CSPriceContext *context = [[CSPriceContext alloc] initWithLikeList:likeList
                                                              retailer:retailer];
    
    id expectedPrice = [self lowestStickerPrice:[self likedRetailer3]];
    id prices = [FakeList fakeListWithThings:
                 @[
                 [self highestPrice:[self likedRetailer4]],
                 expectedPrice,
                 [self lowestEffectivePrice:[self dislikedRetailer0]]
                 ]];
    
    __block id bestPrice = @"NOT CALLED";
    
    CALL_AND_WAIT(^(void (^done)()) {
        [context getBestPrice:prices callback:^(id<CSPrice> result) {
            bestPrice = result;
            done();
        }];
    });
    
    STAssertEqualObjects(bestPrice, expectedPrice, nil);
}

- (void)testChoosesRetailerWhenLastPrice
{
    id likeList = [self someLikes];
    id<CSRetailer> retailer = [self retailerWithURL:[self dislikedRetailer1]];
    CSPriceContext *context = [[CSPriceContext alloc] initWithLikeList:likeList
                                                              retailer:retailer];
    
    id expectedPrice = [self highestPrice:retailer.URL];
    id prices = [FakeList fakeListWithThings:
                 @[
                 [self highestPrice:[self likedRetailer4]],
                 [self lowestStickerPrice:[self likedRetailer3]],
                 [self lowestEffectivePrice:[self dislikedRetailer0]],
                 expectedPrice
                 ]];
    
    __block id bestPrice = @"NOT CALLED";
    
    CALL_AND_WAIT(^(void (^done)()) {
        [context getBestPrice:prices callback:^(id<CSPrice> result) {
            bestPrice = result;
            done();
        }];
    });
    
    STAssertEqualObjects(bestPrice, expectedPrice, nil);
}

@end
