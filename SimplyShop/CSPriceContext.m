//
//  CSPriceContext.m
//  SimplyShop
//
//  Created by Will Harris on 03/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSPriceContext.h"
#import <NSArray+Functional/NSArray+Functional.h>

@interface NSMutableArray (CSExpand)
- (void)putObject:(id)obj atIndexedSubscript:(NSUInteger)idx;
@end

@implementation NSMutableArray (CSExpand)

- (void)putObject:(id)obj atIndexedSubscript:(NSUInteger)idx
{
    while ([self count] < idx) {
        [self addObject:[NSNull null]];
    }
    
    [self setObject:obj atIndexedSubscript:idx];
}

@end

dispatch_queue_t
CSPriceContext_best_price_queue() {
    static dispatch_queue_t q = NULL;
    if (q) {
        return q;
    }
    
    q = dispatch_queue_create("com.cogenta.CSPriceContext.best_price_queue",
                              NULL);
    return q;
}

@interface CSPriceContext ()

- (void)allPrices:(id<CSPriceList>)prices
         callback:(void (^)(NSArray *))callback;
- (void)allLikes:(id<CSLikeList>)likes
        callback:(void (^)(NSArray *))callback;

@end

@implementation CSPriceContext

- (id)initWithLikeList:(id<CSLikeList>)likeList
{
    return [self initWithLikeList:likeList retailer:nil];
}

- (id)initWithLikeList:(id<CSLikeList>)likeList retailer:(id<CSRetailer>)retailer
{
    self = [super init];
    if (self) {
        _likeList = likeList;
        _retailer = retailer;
    }
    return self;
}

- (void)getBestPrice:(id<CSPriceList>)prices
            callback:(void (^)(id<CSPrice>))callback
{
    if (prices.count <= 0) {
        callback(nil);
        return;
    }
    
    [self allLikes:self.likeList callback:^(NSArray *likesArray) {
        NSArray *likedURLsArray = [likesArray mapUsingBlock:^id(id obj) {
            return [obj likedURL];
        }];
        NSSet *likedURLs = [NSSet setWithArray:likedURLsArray];
        [self allPrices:prices callback:^(NSArray *priceArray) {
            dispatch_async(CSPriceContext_best_price_queue(), ^{
                id<CSPrice> bestPrice = nil;
                BOOL bestPriceLiked = NO;
                for (id<CSPrice> price in priceArray) {
                    if ([self.retailer.URL isEqual:price.retailerURL]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            callback(price);
                        });
                        return;
                    }
                    BOOL liked = [likedURLs containsObject:price.retailerURL];
                    if ( ! bestPrice) {
                        bestPrice = price;
                        bestPriceLiked = liked;
                        continue;
                    }
                    
                    if (liked && ! bestPriceLiked) {
                        bestPrice = price;
                        bestPriceLiked = liked;
                        continue;
                    }
                    
                    if (bestPriceLiked && ! liked) {
                        continue;
                    }
                    
                    NSComparisonResult comparison = [[bestPrice effectivePrice]
                                                     compare:[price effectivePrice]];
                    if (comparison == NSOrderedDescending) {
                        bestPrice = price;
                        continue;
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(bestPrice);
                });
            });
        }];
    }];
}

- (void)allPrices:(id<CSPriceList>)prices callback:(void (^)(NSArray *))callback
{
    NSUInteger count = [prices count];
    if (count == 0) {
        callback([NSArray array]);
        return;
    }
    
    __block NSUInteger pricesLeft = count;
    
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:count];
    
    for (NSUInteger i = 0; i < count; ++i) {
        dispatch_async(CSPriceContext_best_price_queue(), ^{
            [prices getPriceAtIndex:i callback:^(id<CSPrice> result,
                                                 NSError *error) {
                if (error) {
                    [results putObject:error atIndexedSubscript:i];
                } else {
                    [results putObject:result atIndexedSubscript:i];
                }
                
                pricesLeft--;
                
                if ( ! pricesLeft) {
                    callback([NSArray arrayWithArray:results]);
                }
            }];
        });
    }
}


- (void)allLikes:(id<CSLikeList>)likes callback:(void (^)(NSArray *))callback
{
    NSUInteger count = [likes count];
    if (count == 0) {
        callback([NSArray array]);
        return;
    }
    
    __block NSUInteger likesLeft = count;
    
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:count];
    
    for (NSUInteger i = 0; i < count; ++i) {
        [likes getLikeAtIndex:i callback:^(id<CSLike> result,
                                           NSError *error) {
            if (error) {
                [results putObject:error atIndexedSubscript:i];
            } else {
                [results putObject:result atIndexedSubscript:i];
            }
            
            likesLeft--;
            
            if ( ! likesLeft) {
                callback([NSArray arrayWithArray:results]);
            }
        }];
    }
}

@end
