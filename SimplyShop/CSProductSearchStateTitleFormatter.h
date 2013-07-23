//
//  CSProductSearchStateTitleFormatter.h
//  SimplyShop
//
//  Created by Will Harris on 23/07/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CSApi/CSAPI.h>

@protocol CSProductSearchStateTitleFormatter <NSObject>

- (NSString *)title;
- (NSString *)titleWithQuery:(NSString *)query;
- (NSString *)titleWithRetailer:(id<CSRetailer>)retailer;
- (NSString *)titleWithRetailer:(id<CSRetailer>)retailer query:(NSString *)query;
- (NSString *)titleWithCategory:(id<CSCategory>)category;
- (NSString *)titleWithCategory:(id<CSCategory>)category query:(NSString *)query;

@end

@interface CSProductSearchStateTitleFormatter : NSObject <CSProductSearchStateTitleFormatter>

+ (id<CSProductSearchStateTitleFormatter>)instance;

@end


