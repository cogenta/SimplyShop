//
//  CSRefineBarState.m
//  SimplyShop
//
//  Created by Will Harris on 16/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRefineBarState.h"
#import <CSApi/CSAPI.h>
#import "CSRefine.h"
#import "CSExplicitBlockOperation.h"

@implementation CSRefineBarState

+ (void)getRefineBarStateForSlice:(id<CSSlice>)slice
                         callback:(void (^)(CSRefineBarState *, NSError *))cb
{
    NSMutableArray *refines = [[NSMutableArray alloc] init];
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    NSOperation *authorOp = [CSExplicitBlockOperation
                             operationWithBlock:^(void (^done)())
    {
        [slice getFiltersByAuthor:^(id<CSAuthor> author, NSError *error) {
            if (error) {
                [errors addObject:error];
            }
                        
            if (author) {
                CSRefine *refine = [CSRefine refineWithTypeName:@"author"
                                                      valueName:author.name];
                [refines addObject:refine];
            }
            
            done();
        }];
    }];
    
    NSOperation *coverTypeOp = [CSExplicitBlockOperation
                                operationWithBlock:^(void (^done)())
    {
        [slice getFiltersByCoverType:^(id<CSCoverType> result, NSError *error) {
            if (error) {
                [errors addObject:error];
            }
            
            if (result) {
                CSRefine *refine = [CSRefine refineWithTypeName:@"cover_type"
                                                      valueName:result.name];
                [refines addObject:refine];
            }
            
            done();
        }];
    }];
    
    NSOperation *manufacturerOp = [CSExplicitBlockOperation
                                   operationWithBlock:^(void (^done)())
    {
        [slice getFiltersByManufacturer:^(id<CSManufacturer> result,
                                          NSError *error) {
            if (error) {;
                [errors addObject:error];
            }
            
            if (result) {
                CSRefine *refine = [CSRefine refineWithTypeName:@"manufacturer"
                                                      valueName:result.name];
                [refines addObject:refine];
            }
            
            done();
        }];
    }];

    NSOperation *platformOp = [CSExplicitBlockOperation
                               operationWithBlock:^(void (^done)())
    {
        [slice getFiltersBySoftwarePlatform:^(id<CSSoftwarePlatform> result,
                                              NSError *error) {
            if (error) {;
                [errors addObject:error];
            }
            
            if (result) {
                CSRefine *refine = [CSRefine
                                    refineWithTypeName:@"software_platform"
                                    valueName:result.name];
                [refines addObject:refine];
            }
            
            done();
        }];
    }];
    
    NSOperation *finishOperation = [NSBlockOperation blockOperationWithBlock:^{
        if ([errors count] > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cb(nil, errors[0]);
            });
            return;
        }

        [refines sortUsingComparator:^NSComparisonResult(CSRefine *obj1,
                                                         CSRefine *obj2) {
            return [[obj1 name] localizedCaseInsensitiveCompare:[obj2 name]];
        }];
        
        CSRefineBarState *result = [[CSRefineBarState alloc] init];
        result.refines = refines;
        result.canRefineMore = (slice.authorNarrowsURL != nil ||
                                slice.coverTypeNarrowsURL != nil ||
                                slice.manufacturerNarrowsURL != nil ||
                                slice.softwarePlatformNarrowsURL != nil);

        dispatch_async(dispatch_get_main_queue(), ^{
            cb(result, nil);
        });
    }];
    
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

@end
