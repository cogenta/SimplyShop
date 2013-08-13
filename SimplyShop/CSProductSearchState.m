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

@interface CSProductSearchState ()

@property (readonly) id<CSRetailer> retailer;
@property (readonly) id<CSCategory> category;
@property (readonly) id<CSLikeList> likes;

@end

@implementation CSProductSearchState

@synthesize slice = _slice;
@synthesize query = _query;

- (id)initWithSlice:(id<CSSlice>)slice
           retailer:(id<CSRetailer>)retailer
           category:(id<CSCategory>)category
              likes:(id<CSLikeList>)likes
              query:(NSString *)query
{
    self = [super init];
    if (self) {
        _slice = slice;
        _retailer = retailer;
        _category = category;
        _likes = likes;
        _query = query;
    }
    return self;
}

- (CSPriceContext *)priceContext
{
    if (self.retailer) {
        return [[CSPriceContext alloc] initWithLikeList:self.likes
                                               retailer:self.retailer];
    } else {
        return [[CSPriceContext alloc] initWithLikeList:self.likes];
    }
}

- (NSString *)titleWithFormatter:(id<CSProductSearchStateTitleFormatter>)formatter
{
    if (self.retailer) {
        if (self.query) {
            return [formatter titleWithRetailer:self.retailer query:self.query];
        }
        
        return [formatter titleWithRetailer:self.retailer];
    } else if (self.category) {
        if (self.query) {
            return [formatter titleWithCategory:self.category query:self.query];
        }
        
        return [formatter titleWithCategory:self.category];
    } else {
        if (self.query) {
            return [formatter titleWithQuery:self.query];
        }
        
        return [formatter title];
    }
}

- (id<CSProductSearchState>)stateWithQuery:(NSString *)query
{
    if ( ! [query length] && ! [self.query length]) {
        return self;
    }
    
    if ([query isEqualToString:self.query]) {
        return self;
    }
    
    return [[CSProductSearchState alloc] initWithSlice:self.slice
                                              retailer:self.retailer
                                              category:self.category
                                                 likes:self.likes
                                                 query:query];
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
            category:(id<CSCategory>)category
               likes:(id<CSLikeList>)likes
               query:(NSString *)query
{
    return [[CSProductSearchState alloc] initWithSlice:slice
                                              retailer:retailer
                                              category:category
                                                 likes:likes
                                                 query:query];
}

- (BOOL)isEqual:(id)object
{
    if ( ! [object isKindOfClass:[CSProductSearchState class]]) {
        return NO;
    }
    
    CSProductSearchState *state = object;
    return ((state.query == self.query || [state.query isEqual:self.query]) &&
            (state.category.URL == self.category.URL ||
             [state.category.URL isEqual:self.category.URL]) &&
            (state.retailer.URL == self.retailer.URL ||
             [state.retailer.URL isEqual:self.retailer.URL]));
}

@end


