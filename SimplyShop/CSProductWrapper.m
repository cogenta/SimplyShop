//
//  CSProductWrapper.m
//  SimplyShop
//
//  Created by Will Harris on 09/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductWrapper.h"
#import <CSApi/CSAPI.h>

@interface CSProductWrapper ()

@property id origin;

@end

@implementation CSProductWrapper

- (id)initWithSummary:(id<CSProductSummary>)summary
{
    self = [super init];
    if (self) {
        _origin = summary;
    }
    
    return self;
}

- (id)initWithProduct:(id<CSProduct>)product
{
    self = [super init];
    if (self) {
        _origin = product;
    }
    return self;
}

+ (instancetype)wrapperForSummary:(id<CSProductSummary>)summary
{
    return [[CSProductWrapper alloc] initWithSummary:summary];
}

+ (instancetype)wrapperForProduct:(id<CSProduct>)product
{
    return [[CSProductWrapper alloc] initWithProduct:product];
}

- (NSString *)name
{
    return [_origin name];
}

- (NSString *)description_
{
    return [_origin description_];
}

- (void)getPictures:(void (^)(id<CSPictureListPage>, NSError *))callback
{
    [_origin getPictures:callback];
}

- (void)getPrices:(void (^)(id<CSPriceListPage>, NSError *))callback
{
    if ([_origin respondsToSelector:@selector(getPrices:)]) {
        [_origin getPrices:callback];
        return;
    }
    
    [_origin getProduct:^(id<CSProduct> product, NSError *error) {
        [product getPrices:callback];
    }];
}

- (void)getProduct:(void (^)(id<CSProduct>, NSError *))callback
{
    if ([_origin conformsToProtocol:@protocol(CSProduct)]) {
        callback(_origin, nil);
        return;
    }
    
    if ([_origin respondsToSelector:@selector(getProduct:)]) {
        [_origin getProduct:callback];
        return;
    }
    
    NSString *desc = [NSString stringWithFormat:
                      @"Cannot get product for %@",
                      _origin];
    NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: desc};
    NSError *error = [NSError errorWithDomain:@"CSProductWrapper"
                                         code:0
                                     userInfo:errorInfo];
    callback(nil, error);
}

@end

@implementation CSProductListWrapper

+ (instancetype)wrapperWithProducts:(id<CSProductList>)products
{
    CSProductListWrapper *result = [[CSProductListWrapper alloc] init];
    result.products = products;
    return result;
}

- (NSUInteger)count
{
    return [self.products count];
}

- (void)getProductWrapperAtIndex:(NSUInteger)index
                        callback:(void (^)(CSProductWrapper *, NSError *))callback
{
    [self.products getProductAtIndex:index
                            callback:^(id<CSProduct> result, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         callback([CSProductWrapper wrapperForProduct:result], nil);
     }];
}

- (void)getProductAtIndex:(NSUInteger)index
                 callback:(void (^)(id<CSProduct>, NSError *))callback
{
    [self.products getProductAtIndex:index callback:callback];
}

- (void)getProductSummaryAtIndex:(NSUInteger)index
                        callback:(void (^)(id<CSProductSummary>,
                                           NSError *))callback
{
    [self.products getProductAtIndex:index
                            callback:^(id<CSProduct> result, NSError *error)
    {
        if (error) {
            callback(nil, error);
            return;
        }
        
        CSProductWrapper *wrapper = [CSProductWrapper wrapperForProduct:result];
        callback(wrapper, nil);
    }];
}

@end
