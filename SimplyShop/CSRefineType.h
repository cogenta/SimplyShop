//
//  CSRefineType.h
//  SimplyShop
//
//  Created by Will Harris on 19/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSSlice;
@protocol CSNarrowList;
@class CSRefine;

@interface CSRefineType : NSObject

@property (readonly, nonatomic) NSString *name;

+ (void) getRefineTypesForSlice:(id<CSSlice>)slice
                       callback:(void (^)(NSArray *types,
                                          NSError *error))callback;

+ (instancetype)authorRefineType;
+ (instancetype)coverTypeRefineType;
+ (instancetype)manufacturerRefineType;
+ (instancetype)softwarePlatformRefineType;

- (void)getSliceWithoutRefine:(id<CSSlice>)slice
                     callback:(void (^)(id<CSSlice>, NSError *))callback;

- (void)getNarrowsForSlice:(id<CSSlice>)slice
                  callback:(void (^)(id<CSNarrowList> narrows,
                                     NSError *error))callback;

- (CSRefine *)refineWithValueName:(NSString *)valueName;

@end
