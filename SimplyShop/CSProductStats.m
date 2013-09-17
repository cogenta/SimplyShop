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

@interface CSProductStats ()

@property (strong, nonatomic) id<CSProduct> product;
@property (readonly) NSDictionary *mappings;

@end

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

@synthesize product = _product;

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
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:(@"-init is not a valid initializer "
                                           "for the class CSProductStats")
                                 userInfo:nil];
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

+ (void)loadProduct:(id<CSProduct>)product callback:(void (^)(CSProductStats *, NSError *))callback
{
    NSDictionary *defaultMappings = @{@"author": @"Author",
                                      @"softwarePlatform": @"Platform",
                                      @"manufacturer": @"Manufacturer",
                                      @"coverType": @"Cover"};
    [CSProductStats loadProduct:product
                       mappings:defaultMappings
                       callback:callback];
}

+ (void)loadProduct:(id<CSProduct>)product
           mappings:(NSDictionary *)mappings
           callback:(void (^)(CSProductStats *, NSError *))callback
{
    CSProductStats *result = [[CSProductStats alloc] initWithMappings:mappings];
    result.product = product;
    callback(result, nil);
}

@end
