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

@interface CSProductSearchState : NSObject <CSProductSearchState>

+ (id)stateWithRetailer:(id<CSRetailer>)retailer
                  likes:(id<CSLikeList>)likes
                  query:(NSString *)query;

+ (id)stateWithGroup:(id<CSGroup>)group
               likes:(id<CSLikeList>)likes
               query:(NSString *)query;

+ (id)stateWithCategory:(id<CSCategory>)category
                  likes:(id<CSLikeList>)likes
                  query:(NSString *)query;

@end

