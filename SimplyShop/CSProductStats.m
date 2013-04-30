//
//  CSProductStats.m
//  SimplyShop
//
//  Created by Will Harris on 30/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductStats.h"
#import <CSApi/CSAPI.h>
#import <NSArray+Functional/NSArray+Functional.h>

@implementation CSProductStat

- (id)initWithLabel:(NSString *)label value:(NSString *)value
{
    self = [super init];
    if (self) {
        _label = [label copy];
        _value = [value copy];
    }
    return self;
}

@end

@implementation CSProductStats

- (id)initWithMappings:(NSDictionary *)mappings
{
    self = [super init];
    if (self) {
        _mappings = [mappings copy];
    }
    return self;
}

- (id)init
{
    NSDictionary *defaultMappings = @{@"author": @"Author",
                                      @"softwarePlatform": @"Platform",
                                      @"manufacturer": @"Manfacturer",
                                      @"coverType": @"Cover"};
    return [self initWithMappings:defaultMappings];
}

- (NSArray *)stats
{
    NSMutableArray *result = [[NSMutableArray alloc]
                              initWithCapacity:[_mappings count]];
    [_mappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *label = obj;
        NSString *value = [(NSObject *) _product valueForKey:key];
        if ( ! value) {
            return;
        }
        
        if ([value isKindOfClass:[NSNull class]]) {
            return;
        }
        
        CSProductStat *stat = [[CSProductStat alloc] initWithLabel:label
                                                             value:value];
        [result addObject:stat];
    }];
    
    [result sortUsingComparator:^NSComparisonResult(CSProductStat *obj1,
                                                    CSProductStat *obj2) {
        return [[obj1 label] localizedCaseInsensitiveCompare:[obj2 label]];
    }];
    
    return [NSArray arrayWithArray:result];
}

@end
