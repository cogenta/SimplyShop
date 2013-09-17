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
#import "CSExplicitBlockOperation.h"

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

@end

typedef void (^done_blk_t)(NSString *value, NSError *error);

@implementation CSProductStats

@synthesize product = _product;

- (NSOperation *)operationForLabel:(NSString *)label
                             stats:(NSMutableArray *)stats
                             block:(void (^)(done_blk_t))blk
{
    return [CSExplicitBlockOperation operationWithBlock:^(void (^done)()) {
        blk(^(NSString *value, NSError *error) {
            if (error || ! value) {
                // If there is an error fetching the author, we still want to
                // return the rest of the stats.
                done();
                return;
            }
            
            CSProductStat *stat = [[CSProductStat alloc] initWithLabel:label
                                                                 value:value];
            [stat addToStats:stats];
            done();
        });
    }];
}

- (void)loadStats:(void (^)(NSArray *stats, NSError *error))cb
{
    NSMutableArray *stats = [[NSMutableArray alloc]
                              initWithCapacity:4];
    
    NSDate *start = [NSDate date];
    
    void (^sortAndReturn)() = ^() {
        [stats sortUsingComparator:^NSComparisonResult(CSProductStat *obj1,
                                                       CSProductStat *obj2) {
            return [[obj1 label] localizedCaseInsensitiveCompare:[obj2 label]];
        }];
        
        NSDate *end = [NSDate date];
        NSTimeInterval took = [end timeIntervalSinceDate:start];
        NSLog(@"Took %@s", @(took));
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cb(stats, nil);
        });
    };
    
    NSOperation *authorOp = [self operationForLabel:@"Author"
                                              stats:stats
                                              block:^(done_blk_t done)
    {
        [_product getAuthor:^(id<CSAuthor> result, NSError *error) {
            done(result.name, error);
        }];
    }];
    
    NSOperation *coverTypeOp = [self operationForLabel:@"Cover"
                                                 stats:stats
                                                 block:^(done_blk_t done)
    {
        [_product getCoverType:^(id<CSCoverType> result, NSError *error) {
            done(result.name, error);
        }];
    }];
    
    NSOperation *manufacturerOp = [self operationForLabel:@"Manufacturer"
                                                    stats:stats
                                                    block:^(done_blk_t done)
    {
        [_product getManufacturer:^(id<CSManufacturer> result, NSError *error) {
            done(result.name, error);
        }];
    }];
    
    NSOperation *platformOp = [self operationForLabel:@"Platform"
                                                stats:stats
                                                block:^(done_blk_t done)
    {
        [_product getSoftwarePlatform:^(id<CSSoftwarePlatform> result,
                                        NSError *error)
        {
            done(result.name, error);
        }];
    }];
    
    NSBlockOperation *finishOperation = [NSBlockOperation
                                         blockOperationWithBlock:sortAndReturn];
    [finishOperation addDependency:authorOp];
    [finishOperation addDependency:coverTypeOp];
    [finishOperation addDependency:manufacturerOp];
    [finishOperation addDependency:platformOp];
    
    NSOperationQueue *stuffQueue = [[NSOperationQueue alloc] init];
    [stuffQueue setMaxConcurrentOperationCount:4];
    
    [stuffQueue addOperation:authorOp];
    [stuffQueue addOperation:coverTypeOp];
    [stuffQueue addOperation:manufacturerOp];
    [stuffQueue addOperation:platformOp];
    [stuffQueue addOperation:finishOperation];
}


+ (void)loadProduct:(id<CSProduct>)product
           callback:(void (^)(CSProductStats *, NSError *))callback
{
    CSProductStats *result = [[CSProductStats alloc] init];
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
