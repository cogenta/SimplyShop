//
//  CSProductWrapper.h
//  SimplyShop
//
//  Created by Will Harris on 09/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSProductSummary;
@protocol CSProduct;
@protocol CSPictureListPage;
@protocol CSPriceListPage;

@interface CSProductWrapper : NSObject

@property (readonly) NSString *name;
@property (readonly) NSString *description_;

- (void)getPictures:(void (^)(id<CSPictureListPage>, NSError *))callback;
- (void)getPrices:(void (^)(id<CSPriceListPage>, NSError *))callback;

+ (instancetype) wrapperForSummary:(id<CSProductSummary>)summary;
+ (instancetype) wrapperForProduct:(id<CSProduct>)product;

@end

@protocol CSProductListWrapper <NSObject>

@property (readonly) NSUInteger count;

- (void)getProductWrapperAtIndex:(NSUInteger)index
                        callback:(void (^)(CSProductWrapper *result,
                                           NSError *error))callback;
- (void)getProductAtIndex:(NSUInteger)index
                 callback:(void (^)(id<CSProduct>, NSError *))callback;
@end
