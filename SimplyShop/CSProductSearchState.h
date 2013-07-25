//
//  CSProductSearchState.h
//  SimplyShop
//
//  Created by Will Harris on 23/07/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <CSApi/CSAPI.h>

@class CSPriceContext;
@protocol CSProductSearchStateTitleFormatter;

@protocol CSProductSearchState <NSObject>

@property (readonly) NSString *query;
@property (readonly) CSPriceContext *priceContext;

- (NSString *)titleWithFormatter:(id<CSProductSearchStateTitleFormatter>)formatter;

- (id<CSProductSearchState>)stateWithQuery:(NSString *)query;
- (id<CSAPIRequest>)getProducts:(void (^)(id<CSProductList>, NSError *))callback;

@end

@interface CSRetailerProductSearchState : NSObject <CSProductSearchState>

@property (readonly) id<CSRetailer> retailer;
@property (readonly) id<CSLikeList> likes;
@property (readonly) NSString *query;

- (id)initWithRetailer:(id<CSRetailer>)retailer
                 likes:(id<CSLikeList>)likes
                 query:(NSString *)query;

@end

@interface CSGroupProductSearchState : NSObject <CSProductSearchState>

@property (readonly) id<CSGroup> group;
@property (readonly) id<CSLikeList> likes;
@property (readonly) NSString *query;

- (id)initWithGroup:(id<CSGroup>)group
              likes:(id<CSLikeList>)likes
              query:(NSString *)query;

@end

@interface CSCategoryProductSearchState : NSObject <CSProductSearchState>

@property (readonly) id<CSCategory>category;
@property (readonly) id<CSLikeList>likes;
@property (readonly) NSString *query;

- (id)initWithCategory:(id<CSCategory>)category
                 likes:(id<CSLikeList>)likes
                 query:(NSString *)query;

@end


