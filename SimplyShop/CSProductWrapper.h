//
//  CSProductWrapper.h
//  SimplyShop
//
//  Created by Will Harris on 09/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <CSApi/CSAPI.h>

@interface CSProductWrapper : NSObject <CSProductSummary>

@property (readonly) NSString *name;
@property (readonly) NSString *description_;

- (void)getPictures:(void (^)(id<CSPictureListPage>, NSError *))callback;
- (void)getPrices:(void (^)(id<CSPriceListPage>, NSError *))callback;

+ (instancetype) wrapperForSummary:(id<CSProductSummary>)summary;
+ (instancetype) wrapperForProduct:(id<CSProduct>)product;

@end

@protocol CSProductListWrapper <CSProductList, CSProductSummaryList>

@property (readonly) NSUInteger count;

- (void)getProductWrapperAtIndex:(NSUInteger)index
                        callback:(void (^)(CSProductWrapper *result,
                                           NSError *error))callback;
@end


@interface CSProductListWrapper : NSObject <CSProductListWrapper>

@property id<CSProductList> products;

+ (instancetype) wrapperWithProducts:(id<CSProductList>)products;

@end


@interface CSProductSummaryListWrapper : NSObject <CSProductListWrapper>

@property id<CSProductSummaryList> products;

+ (instancetype) wrapperWithProducts:(id<CSProductSummaryList>)products;

@end
