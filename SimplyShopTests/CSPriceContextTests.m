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

#define CALL_AND_WAIT(blk) \
{ \
    if ([self timeoutInterval:(blk)] > 0.0) { \
        STFail(@"timed out"); \
    } \
}

@interface FakeList : NSObject <CSPriceList, CSLikeList>

@property (strong, nonatomic) NSArray *things;

+ (id)fakeListWithThings:(NSArray *)things;

@end

@implementation FakeList

+ (id)fakeListWithThings:(NSArray *)things
{
    FakeList *result = [[FakeList alloc] init];
    result.things = things;
    return result;
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

- (NSTimeInterval)timeoutInterval:(void (^)(void (^done)()))blk;
- (NSTimeInterval)waitForSemaphore:(dispatch_semaphore_t)semaphore;


@end

@implementation CSPriceContextTests

- (NSTimeInterval)waitForSemaphore:(dispatch_semaphore_t)semaphore
{
    NSDate *start = [NSDate date];
    long timedout;
    int maxTries = 16;
    double totalWait = 3.0;
    double delayInSeconds = totalWait / maxTries;
    dispatch_time_t wait_time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    for (int tries = 0; tries < maxTries; tries++) {
        timedout = dispatch_semaphore_wait(semaphore, wait_time);
        if (! timedout) {
            break;
        }
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:delayInSeconds]];
    }
    
    NSDate *end = [NSDate date];
    if (timedout != 0) {
        return [end timeIntervalSinceDate:start];
    } else {
        return 0;
    }
}

- (NSTimeInterval)timeoutInterval:(void (^)(void (^done)()))blk
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    void (^done)() = ^{
        dispatch_semaphore_signal(semaphore);
    };
    
    blk(done);
    
    return [self waitForSemaphore:semaphore];
}

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
    return [FakeList fakeListWithThings:@[
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
}

- (void)testChoosesNilWhenNilPrices
{
    id likeList = [self noLikes];
    CSPriceContext *context = [[CSPriceContext alloc] initWithLikeList:likeList];
    
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
    CSPriceContext *context = [[CSPriceContext alloc] initWithLikeList:likeList];

    __block id bestPrice = @"NOT CALLED";
    
    CALL_AND_WAIT(^(void (^done)()) {
        [context getBestPrice:[self noPrices] callback:^(id<CSPrice> result) {
            bestPrice = result;
            done();
        }];
    });
    
    STAssertNil(bestPrice, @"%@", bestPrice);
}

- (void)testChoosesLowestEffectivePriceWhenNoLikes
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

- (void)testChoosesLowestEffectivePriceWhenNilLikes
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

- (void)testChoosesLowestEffectivePriceWhenAllPricesDisliked
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

- (void)testChoosesOnlyLikeEvenWhenNotLowestEffectivePrice
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

- (void)testChoosesLikeWithLowestEffecticePrice
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

- (void)testChoosesLowestEffectivePriceWhenStickerPriceIsNotLowest
{
}


@end
