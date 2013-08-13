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

- (id)initWithSlice:(id<CSSlice>)slice
           retailer:(id<CSRetailer>)retailer
              likes:(id<CSLikeList>)likes
              query:(NSString *)query;

@end

@interface CSGroupProductSearchState : CSProductSearchState

@end

@interface CSCategoryProductSearchState : CSProductSearchState

@end

@interface CSProductSearchState ()

@property (readonly) id<CSCategory>category;
@property (readonly) id<CSLikeList>likes;

@end

@implementation CSProductSearchState

@synthesize slice = _slice;
@synthesize query = _query;

- (id)initWithSlice:(id<CSSlice>)slice
           category:(id<CSCategory>)category
              likes:(id<CSLikeList>)likes
              query:(NSString *)query
{
    self = [super init];
    if (self) {
        _slice = slice;
        _category = category;
        _likes = likes;
        _query = query;
    }
    return self;
}

- (CSPriceContext *)priceContext
{
    return [[CSPriceContext alloc] initWithLikeList:self.likes];
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
    if (self.query) {
        return [self.slice getProductsWithQuery:self.query
                                       callback:^(id<CSProductListPage> page,
                                                  NSError *error)
         {
             callback(page.productList, error);
         }];
    } else {
        return [self.slice getProducts:^(id<CSProductListPage> page,
                                         NSError *error)
         {
             callback(page.productList, error);
         }];
    }
}

+ (id)stateWithSlice:(id<CSSlice>)slice
            retailer:(id<CSRetailer>)retailer
               likes:(id<CSLikeList>)likes
               query:(NSString *)query
{
    return [[CSRetailerProductSearchState alloc] initWithSlice:slice
                                                      retailer:retailer
                                                         likes:likes
                                                         query:query];
}

+ (id)stateWithSlice:(id<CSSlice>)slice
               likes:(id<CSLikeList>)likes
               query:(NSString *)query
{
    return [[CSGroupProductSearchState alloc] initWithSlice:slice
                                                   category:nil
                                                      likes:likes
                                                      query:query];
}

+ (id)stateWithSlice:(id<CSSlice>)slice
            category:(id<CSCategory>)category
               likes:(id<CSLikeList>)likes
               query:(NSString *)query
{
    return [[CSCategoryProductSearchState alloc] initWithSlice:slice
                                                      category:category
                                                         likes:likes
                                                         query:query];
}

+ (id)stateWithSlice:(id<CSSlice>)slice
            retailer:(id<CSRetailer>)retailer
            category:(id<CSCategory>)category
               likes:(id<CSLikeList>)likes
               query:(NSString *)query
{
    if (retailer) {
        return [[CSRetailerProductSearchState alloc] initWithSlice:slice
                                                          retailer:retailer
                                                             likes:likes
                                                             query:query];
    } else if (category) {
        return [[CSCategoryProductSearchState alloc] initWithSlice:slice
                                                          category:category
                                                             likes:likes
                                                             query:query];
    } else {
        return [[CSGroupProductSearchState alloc] initWithSlice:slice
                                                       category:nil
                                                          likes:likes
                                                          query:query];
    }
}

- (BOOL)isEqual:(id)object
{
    if ( ! [object isKindOfClass:[self class]]) {
        return NO;
    }
    
    CSGroupProductSearchState *state = object;
    return ((state.query == self.query || [state.query isEqual:self.query]) &&
            (state.category.URL == self.category.URL ||
             [state.category.URL isEqual:self.category.URL]));
}

@end

@implementation CSRetailerProductSearchState

- (id)initWithSlice:(id<CSSlice>)slice
           retailer:(id<CSRetailer>)retailer
              likes:(id<CSLikeList>)likes
              query:(NSString *)query
{
    self = [super initWithSlice:slice category:nil likes:likes query:query];
    if (self) {
        _retailer = retailer;
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
    
    return [[CSRetailerProductSearchState alloc] initWithSlice:self.slice
                                                      retailer:self.retailer
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

- (id<CSProductSearchState>)stateWithQuery:(NSString *)query
{
    if ( ! [query length] && ! [self.query length]) {
        return self;
    }
    
    if ([query isEqualToString:self.query]) {
        return self;
    }
    
    return [[CSGroupProductSearchState alloc] initWithSlice:self.slice
                                                   category:self.category
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

@end

@implementation CSCategoryProductSearchState

- (id<CSProductSearchState>)stateWithQuery:(NSString *)query
{
    if ( ! [query length] && ! [self.query length]) {
        return self;
    }
    
    if ([query isEqualToString:self.query]) {
        return self;
    }
    
    return [[CSCategoryProductSearchState alloc] initWithSlice:self.slice
                                                      category:self.category
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

@end

