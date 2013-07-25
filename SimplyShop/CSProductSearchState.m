//
//  CSProductSearchState.m
//  SimplyShop
//
//  Created by Will Harris on 23/07/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductSearchState.h"

#import "CSProductSearchStateTitleFormatter.h"
#import "CSPriceContext.h"

@implementation CSRetailerProductSearchState

- (id)initWithRetailer:(id<CSRetailer>)retailer
                 likes:(id<CSLikeList>)likes
                 query:(NSString *)query
{
    self = [super init];
    if (self) {
        _retailer = retailer;
        _likes = likes;
        _query = query;
    }
    
    return self;
}

- (id<CSProductSearchState>)stateWithQuery:(NSString *)query
{
    if ( ! [query length] && ! [self.query length]) {
        return self;
    }
    
    if ([query isEqualToString:self.query]) {
        return self;
    }
    
    return [[CSRetailerProductSearchState alloc] initWithRetailer:self.retailer
                                                            likes:self.likes
                                                            query:query];
}

- (NSString *)titleWithFormatter:(id<CSProductSearchStateTitleFormatter>)formatter
{
    if (self.query) {
        return [formatter titleWithRetailer:self.retailer query:self.query];
    }
    
    return [formatter titleWithRetailer:self.retailer];
}

- (CSPriceContext *)priceContext
{
    return [[CSPriceContext alloc] initWithLikeList:self.likes
                                           retailer:self.retailer];
}

- (id<CSAPIRequest>)getProducts:(void (^)(id<CSProductList>, NSError *))callback
{
    if (self.query) {
        return [self.retailer getProductsWithQuery:self.query
                                   callback:^(id<CSProductListPage> firstPage,
                                              NSError *error)
         {
             callback(firstPage.productList, error);
         }];
    } else {
        return [self.retailer getProducts:^(id<CSProductListPage> firstPage,
                                     NSError *error)
         {
             callback(firstPage.productList, error);
         }];
    }
}

- (BOOL)isEqual:(id)object
{
    if ( ! [object isKindOfClass:[self class]]) {
        return NO;
    }
    
    CSRetailerProductSearchState *state = object;
    return ((state.query == self.query || [state.query isEqual:self.query])
            && [state.retailer.URL isEqual:self.retailer.URL]);
}

@end


@implementation CSGroupProductSearchState

- (id)initWithGroup:(id<CSGroup>)group
              likes:(id<CSLikeList>)likes
              query:(NSString *)query
{
    self = [super init];
    if (self) {
        _group = group;
        _likes = likes;
        _query = query;
    }
    return self;
}

- (id<CSProductSearchState>)stateWithQuery:(NSString *)query
{
    if ( ! [query length] && ! [self.query length]) {
        return self;
    }
    
    if ([query isEqualToString:self.query]) {
        return self;
    }
    
    return [[CSGroupProductSearchState alloc] initWithGroup:self.group
                                                      likes:self.likes
                                                      query:query];
}

- (NSString *)titleWithFormatter:(id<CSProductSearchStateTitleFormatter>)formatter
{
    if (self.query) {
        return [formatter titleWithQuery:self.query];
    }
    
    return [formatter title];
}

- (CSPriceContext *)priceContext
{
    return [[CSPriceContext alloc] initWithLikeList:self.likes];
}

- (id<CSAPIRequest>)getProducts:(void (^)(id<CSProductList>, NSError *))callback
{
    if (self.query) {
        return [self.group getProductsWithQuery:self.query
                                callback:^(id<CSProductListPage> firstPage,
                                           NSError *error)
         {
             callback(firstPage.productList, error);
         }];
    } else {
        return [self.group getProducts:^(id<CSProductListPage> firstPage,
                                  NSError *error)
         {
             callback(firstPage.productList, error);
         }];
    }
}

- (BOOL)isEqual:(id)object
{
    if ( ! [object isKindOfClass:[self class]]) {
        return NO;
    }
    
    CSGroupProductSearchState *state = object;
    return ((state.query == self.query || [state.query isEqual:self.query])
            && [state.group.URL isEqual:self.group.URL]);
}

@end

@implementation CSCategoryProductSearchState

- (id)initWithCategory:(id<CSCategory>)category
                 likes:(id<CSLikeList>)likes
                 query:(NSString *)query
{
    self = [super init];
    if (self) {
        _category = category;
        _likes = likes;
        _query = query;
    }
    return self;
}

- (id<CSProductSearchState>)stateWithQuery:(NSString *)query
{
    if ( ! [query length] && ! [self.query length]) {
        return self;
    }
    
    if ([query isEqualToString:self.query]) {
        return self;
    }
    
    return [[CSCategoryProductSearchState alloc] initWithCategory:self.category
                                                            likes:self.likes
                                                            query:query];
}

- (NSString *)titleWithFormatter:(id<CSProductSearchStateTitleFormatter>)formatter
{
    if (self.query) {
        return [formatter titleWithCategory:self.category query:self.query];
    }
    
    return [formatter titleWithCategory:self.category];
}

- (CSPriceContext *)priceContext
{
    return [[CSPriceContext alloc] initWithLikeList:self.likes];
}

- (id<CSAPIRequest>)getProducts:(void (^)(id<CSProductList>, NSError *))callback
{
    if (self.query) {
        return [self.category getProductsWithQuery:self.query
                                   callback:^(id<CSProductListPage> firstPage,
                                              NSError *error)
         {
             callback(firstPage.productList, error);
         }];
    } else {
        return [self.category getProducts:^(id<CSProductListPage> firstPage,
                                     NSError *error)
         {
             callback(firstPage.productList, error);
         }];
    }
}

- (BOOL)isEqual:(id)object
{
    if ( ! [object isKindOfClass:[self class]]) {
        return NO;
    }
    
    CSCategoryProductSearchState *state = object;
    return ((state.query == self.query || [state.query isEqual:self.query])
            && [state.category.URL isEqual:self.category.URL]);
}

@end

