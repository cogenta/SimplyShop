//
//  CSPriceContext.m
//  SimplyShop
//
//  Created by Will Harris on 03/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSPriceContext.h"
#import <NSArray+Functional/NSArray+Functional.h>

@interface CSPriceContext ()

- (void)allPrices:(id<CSPriceList>)prices
         callback:(void (^)(NSArray *))callback;
- (void)allLikes:(id<CSLikeList>)likes
        callback:(void (^)(NSArray *))callback;

@end

@implementation CSPriceContext

- (id)initWithLikeList:(id<CSLikeList>)likeList
{
    self = [super init];
    if (self) {
        _likeList = likeList;
    }
    return self;
}

- (void)getBestPrice:(id<CSPriceList>)prices
            callback:(void (^)(id<CSPrice>))callback
{
    NSLog(@"Best price: choosing from %@ for %@", prices, self);
    if (prices.count <= 0) {
        NSLog(@"Best price: choosing nil because there are no prices");
        callback(nil);
        return;
    }
    
    [self allLikes:self.likeList callback:^(NSArray *likesArray) {
        NSArray *likedURLsArray = [likesArray mapUsingBlock:^id(id obj) {
            return [obj likedURL];
        }];
        NSSet *likedURLs = [NSSet setWithArray:likedURLsArray];
        [self allPrices:prices callback:^(NSArray *priceArray) {
            id<CSPrice> bestPrice = nil;
            BOOL bestPriceLiked = NO;
            for (id<CSPrice> price in priceArray) {
                NSLog(@"Best price: evaluating %@ against current best %@ (liked = %@)",
                      price, bestPrice, @(bestPriceLiked));
                BOOL liked = [likedURLs containsObject:price.retailerURL];
                if ( ! bestPrice) {
                    NSLog(@"Best price: new best is %@ (first price seen)", price);
                    bestPrice = price;
                    bestPriceLiked = liked;
                    continue;
                }
                
                if (liked && ! bestPriceLiked) {
                    NSLog(@"Best price: new best is %@ (first liked seen)", price);
                    bestPrice = price;
                    bestPriceLiked = liked;
                    continue;
                }
                
                if (bestPriceLiked && ! liked) {
                    NSLog(@"Best price: rejecting %@ (disliked and current liked)", price);
                    continue;
                }
                
                NSComparisonResult comparison = [[bestPrice effectivePrice]
                                                 compare:[price effectivePrice]];
                if (comparison == NSOrderedDescending) {
                    NSLog(@"Best price: new best is %@ (better effective price)", price);
                    bestPrice = price;
                    continue;
                }
                
                NSLog(@"Best price: rejecting %@ (not better effective price)", price);
            }
            
            NSLog(@"Best price: chose %@", bestPrice);
            callback(bestPrice);
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
    
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:count];
    
    for (NSUInteger i = 0; i < count; ++i) {
        [prices getPriceAtIndex:i callback:^(id<CSPrice> result,
                                             NSError *error) {
            if (error) {
                [results setObject:error atIndexedSubscript:i];
            } else {
                [results setObject:result atIndexedSubscript:i];
            }
            
            pricesLeft--;
            
            if ( ! pricesLeft) {
                callback([NSArray arrayWithArray:results]);
            }
        }];
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
    
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:count];
    
    for (NSUInteger i = 0; i < count; ++i) {
        [likes getLikeAtIndex:i callback:^(id<CSLike> result,
                                           NSError *error) {
            if (error) {
                [results setObject:error atIndexedSubscript:i];
            } else {
                [results setObject:result atIndexedSubscript:i];
            }
            
            likesLeft--;
            
            if ( ! likesLeft) {
                callback([NSArray arrayWithArray:results]);
            }
        }];
    }
}

@end
