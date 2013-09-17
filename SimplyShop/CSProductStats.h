//
//  CSProductStats.h
//  SimplyShop
//
//  Created by Will Harris on 30/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSProduct;

@interface CSProductStat : NSObject

@property (readonly) NSString *label;
@property (readonly) NSString *value;

- (id)initWithLabel:(NSString *)label value:(NSString *)value;

@end

@interface CSProductStats : NSObject

@property (readonly) NSArray *stats;

+ (void)loadProduct:(id<CSProduct>)product
           callback:(void (^)(CSProductStats *stats, NSError *error))callback;

@end
