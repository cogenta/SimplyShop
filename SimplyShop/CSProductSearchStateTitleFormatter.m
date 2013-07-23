//
//  CSProductSearchStateTitleFormatter.m
//  SimplyShop
//
//  Created by Will Harris on 23/07/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductSearchStateTitleFormatter.h"

@implementation CSProductSearchStateTitleFormatter

+ (id)instance
{
    static id<CSProductSearchStateTitleFormatter> instance = nil;
    
    if ( ! instance) {
        instance = [[CSProductSearchStateTitleFormatter alloc] init];
    }
    
    return instance;
}

- (NSString *)title
{
    return @"Top Products";
}

- (NSString *)titleWithQuery:(NSString *)query
{
    return [NSString stringWithFormat:@"Search for '%@'", query];
}

- (NSString *)titleWithRetailer:(id<CSRetailer>)retailer
{
    return retailer.name;
}

- (NSString *)titleWithRetailer:(id<CSRetailer>)retailer query:(NSString *)query
{
    return [NSString stringWithFormat:@"Search for '%@' at %@",
            query, retailer.name];
}

- (NSString *)titleWithCategory:(id<CSCategory>)category
{
    return category.name;
}

- (NSString *)titleWithCategory:(id<CSCategory>)category query:(NSString *)query
{
    return [NSString stringWithFormat:@"Search for '%@' in %@",
            query, category.name];
}

@end


