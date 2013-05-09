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

@end
