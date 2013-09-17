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

@interface CSProductStat ()

- (void)addToStats:(NSMutableArray *)stats;

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

- (void)addToStats:(NSMutableArray *)stats
{
    if ( ! self.value) {
        return;
    }
    
    if ([self.value isKindOfClass:[NSNull class]]) {
        return;
    }

    [stats addObject:self];
}

@end

@interface CSProductStats ()

@property (strong, nonatomic) id<CSProduct> product;
@property (readonly) NSDictionary *mappings;

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

- (void)loadStats:(void (^)(NSArray *stats, NSError *error))cb
{
    NSMutableArray *result = [[NSMutableArray alloc]
                              initWithCapacity:[_mappings count]];
    [_mappings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *label = obj;
        NSString *value = [(NSObject *) _product valueForKey:key];
        
        CSProductStat *stat = [[CSProductStat alloc] initWithLabel:label
                                                             value:value];
        [stat addToStats:result];
    }];
    
    void (^sortAndReturn)() = ^() {
        [result sortUsingComparator:^NSComparisonResult(CSProductStat *obj1,
                                                        CSProductStat *obj2) {
            return [[obj1 label] localizedCaseInsensitiveCompare:[obj2 label]];
        }];
        
        cb(result, nil);
    };
    
    [_product getAuthor:^(id<CSAuthor> author, NSError *error) {
        // If there is an error fetching the author, we still want to return
        // the rest of the stats.
        if (author && ! error) {
            NSString *value = author.name;
            
            CSProductStat *stat = [[CSProductStat alloc] initWithLabel:@"Author"
                                                                 value:value];
            [stat addToStats:result];
        }
        
        sortAndReturn();
    }];
}

+ (void)loadProduct:(id<CSProduct>)product callback:(void (^)(CSProductStats *, NSError *))callback
{
    NSDictionary *defaultMappings = @{@"softwarePlatform": @"Platform",
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
    [result loadStats:^(NSArray *stats, NSError *error) {
        if (error) {
            callback(nil, error);
            return;
        }
        
        result->_stats = stats;
        callback(result, nil);
    }];
}

@end
