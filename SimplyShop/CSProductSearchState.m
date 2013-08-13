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

@interface CSRetailerProductSearchState : CSProductSearchState

@property (readonly) id<CSRetailer> retailer;
@property (readonly) id<CSLikeList> likes;
@property (readonly) NSString *query;

- (id)initWithRetailer:(id<CSRetailer>)retailer
                 likes:(id<CSLikeList>)likes
                 query:(NSString *)query;

@end

@interface CSGroupProductSearchState : CSProductSearchState

@property (readonly) id<CSGroup> group;
@property (readonly) id<CSLikeList> likes;
@property (readonly) NSString *query;

- (id)initWithGroup:(id<CSGroup>)group
              likes:(id<CSLikeList>)likes
              query:(NSString *)query;

@end

@interface CSCategoryProductSearchState : CSProductSearchState

@property (readonly) id<CSCategory>category;
@property (readonly) id<CSLikeList>likes;
@property (readonly) NSString *query;

- (id)initWithCategory:(id<CSCategory>)category
                 likes:(id<CSLikeList>)likes
                 query:(NSString *)query;

@end

@implementation CSProductSearchState

@synthesize query = _query;

- (id)initWithQuery:(NSString *)query;
{
    self = [super init];
    if (self) {
        _query = query;
    }
    return self;
}

- (CSPriceContext *)priceContext
{
    @throw [NSException
            exceptionWithName:NSInternalInconsistencyException
            reason:(@"failed to override CSProductSearchState's "
                    "priceContext method")
            userInfo:nil];
}

- (NSString *)titleWithFormatter:(id<CSProductSearchStateTitleFormatter>)formatter
{
    @throw [NSException
            exceptionWithName:NSInternalInconsistencyException
            reason:(@"failed to override CSProductSearchState's "
                    "titleWithFormatter: method")
            userInfo:nil];
}

- (id<CSProductSearchState>)stateWithQuery:(NSString *)query
{
    @throw [NSException
            exceptionWithName:NSInternalInconsistencyException
            reason:(@"failed to override CSProductSearchState's "
                    "stateWithQuery: method")
            userInfo:nil];
}

- (id<CSAPIRequest>)getProducts:(void (^)(id<CSProductList>, NSError *))callback
{
    @throw [NSException
            exceptionWithName:NSInternalInconsistencyException
            reason:(@"failed to override CSProductSearchState's "
                    "getProducts: method")
            userInfo:nil];
}

+ (id)stateWithRetailer:(id<CSRetailer>)retailer
                  likes:(id<CSLikeList>)likes
                  query:(NSString *)query
{
    return [[CSRetailerProductSearchState alloc] initWithRetailer:retailer
                                                            likes:likes
                                                            query:query];
}

+ (id)stateWithGroup:(id<CSGroup>)group
               likes:(id<CSLikeList>)likes
               query:(NSString *)query
{
    return [[CSGroupProductSearchState alloc] initWithGroup:group
                                                      likes:likes
                                                      query:query];
}

+ (id)stateWithCategory:(id<CSCategory>)category
                  likes:(id<CSLikeList>)likes
                  query:(NSString *)query
{
    return [[CSCategoryProductSearchState alloc] initWithCategory:category
                                                            likes:likes
                                                            query:query];
}

@end

@implementation CSRetailerProductSearchState

- (id)initWithRetailer:(id<CSRetailer>)retailer
                 likes:(id<CSLikeList>)likes
                 query:(NSString *)query
{
    self = [super initWithQuery:query];
    if (self) {
        _retailer = retailer;
        _likes = likes;
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
    self = [super initWithQuery:query];
    if (self) {
        _group = group;
        _likes = likes;
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
    self = [super initWithQuery:query];
    if (self) {
        _category = category;
        _likes = likes;
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

