//
//  CSPriceContext.m
//  SimplyShop
//
//  Created by Will Harris on 03/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSPriceContext.h"
#import <NSArray+Functional/NSArray+Functional.h>
#import "CSExplicitBlockOperation.h"

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

@interface CSPriceContext ()

- (void)allPrices:(id<CSPriceList>)prices
         callback:(void (^)(NSArray *))callback;
- (void)allLikes:(void (^)(NSArray *))callback;

- (void)allItemsInListWithCount:(NSUInteger)count
                         getter:(void (^)(NSUInteger index,
                                          void (^got)(id item)))getter
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
    
    [self allLikes:^(NSArray *likesArray) {
        NSArray *likedURLsArray = [likesArray mapUsingBlock:^id(id obj) {
            if ([obj respondsToSelector:@selector(likedURL)]) {
                return [obj likedURL];
            } else {
                return [NSNull null];
            }
        }];
        
        NSSet *likedURLs = [NSSet setWithArray:likedURLsArray];
        [self allPrices:prices callback:^(NSArray *priceArray) {
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
        }];
    }];
}

- (void)allPrices:(id<CSPriceList>)prices callback:(void (^)(NSArray *))callback
{
    [self allItemsInListWithCount:[prices count]
                           getter:^(NSUInteger index, void (^got)(id item)) {
        [prices getPriceAtIndex:index callback:^(id<CSPrice> result,
                                                 NSError *error) {
            if (error) {
                got(error);
            } else {
                got(result);
            }
        }];
    } callback:callback];

    return;
    
    NSUInteger count = [prices count];
    if (count == 0) {
        callback([NSArray array]);
        return;
    }
    
    __block NSUInteger pricesLeft = count;
    
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:count];
    
    for (NSUInteger i = 0; i < count; ++i) {
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
    }
}

- (void)allLikes:(void (^)(NSArray *))callback
{
    [self allItemsInListWithCount:[_likeList count]
                           getter:^(NSUInteger index, void (^got)(id item)) {
        [_likeList getLikeAtIndex:index callback:^(id<CSLike> result,
                                                   NSError *error) {
            if (error) {
                got(error);
            } else {
                got(result);
            }
        }];
    } callback:callback];
}

- (void)allItemsInListWithCount:(NSUInteger)count
                         getter:(void (^)(NSUInteger index,
                                          void (^got)(id item)))getter
                       callback:(void (^)(NSArray *))callback
{
    if (count == 0) {
        callback([NSArray array]);
        return;
    }
    
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:count];
    
    NSOperation *returnOp = [NSBlockOperation blockOperationWithBlock:^{
        callback([NSArray arrayWithArray:results]);
    }];
    
    NSOperationQueue *q = [[NSOperationQueue alloc] init];
    q.maxConcurrentOperationCount = count;
    
    NSOperationQueue *syncResultsQueue = [[NSOperationQueue alloc] init];
    syncResultsQueue.maxConcurrentOperationCount = 1;
    
    for (NSUInteger i = 0; i < count; ++i) {
        NSOperation *itemOp = [CSExplicitBlockOperation operationWithBlock:^(void (^done)()) {
            getter(i, ^(id item) {
                NSOperation *putOp = [NSBlockOperation blockOperationWithBlock:^{
                    [results putObject:item atIndexedSubscript:i];
                    done();
                }];
                [syncResultsQueue addOperation:putOp];
            });
        }];
        [returnOp addDependency:itemOp];
        [q addOperation:itemOp];
    }
    
    [q addOperation:returnOp];
}

- (void)sortAndFilterPrices:(id<CSPriceList>)prices
                      block:(BOOL(^)(id<CSPrice>price, NSSet *likedURLs))blk
                   callback:(void (^)(NSArray *, NSError *))callback
{
    [self allLikes:^(NSArray *likesArray) {
        NSArray *likedURLsArray = [likesArray mapUsingBlock:^id(id obj) {
            if ([obj respondsToSelector:@selector(likedURL)]) {
                return [obj likedURL];
            } else {
                return [NSNull null];
            }
        }];
        NSSet *likedURLs = [NSSet setWithArray:likedURLsArray];
        [self allPrices:prices callback:^(NSArray *prices) {
            NSArray *filtered = [prices filterUsingBlock:^BOOL(id obj) {
                if ( ! [obj conformsToProtocol:@protocol(CSPrice)]) {
                    return NO;
                }
                return blk(obj, likedURLs);
            }];
            NSArray *sorted =
            [filtered sortedArrayUsingComparator:^NSComparisonResult(id obj1,
                                                                     id obj2)
            {
                return [[obj1 effectivePrice]
                        compare:[obj2 effectivePrice]];
            }];
            callback(sorted, nil);
        }];
    }];
}

- (void)getFavoritePrices:(id<CSPriceList>)prices
                 callback:(void (^)(NSArray *, NSError *))callback
{
    [self sortAndFilterPrices:prices
                        block:^BOOL(id<CSPrice> price, NSSet *likedURLs)
    {
        return [likedURLs containsObject:price.retailerURL];
    } callback:^(NSArray *result, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(result, error);
        });
    }];
}

- (void)getOtherPrices:(id<CSPriceList>)prices
              callback:(void (^)(NSArray *, NSError *))callback
{
    [self sortAndFilterPrices:prices
                        block:^BOOL(id<CSPrice> price, NSSet *likedURLs)
     {
         return ! [likedURLs containsObject:price.retailerURL];
     } callback:^(NSArray *result, NSError *error) {
         dispatch_async(dispatch_get_main_queue(), ^{
             callback(result, error);
         });
     }];
}

@end
