//
//  CSPriceContext.h
//  SimplyShop
//
//  Created by Will Harris on 03/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CSApi/CSAPI.h>

@interface CSPriceContext : NSObject

- (id)initWithLikeList:(id<CSLikeList>)likeList;
- (id)initWithLikeList:(id<CSLikeList>)likeList
              retailer:(id<CSRetailer>)retailer;

- (void)getBestPrice:(id<CSPriceList>)prices
            callback:(void (^)(id<CSPrice>))callback;

- (void)getFavoritePrices:(id<CSPriceList>)prices
                 callback:(void (^)(NSArray *, NSError *))callback;
- (void)getOtherPrices:(id<CSPriceList>)prices
              callback:(void (^)(NSArray *, NSError *))callback;

@property (readonly) id<CSLikeList> likeList;
@property (readonly) id<CSRetailer> retailer;

@end
