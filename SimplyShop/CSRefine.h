//
//  CSRefine.h
//  SimplyShop
//
//  Created by Will Harris on 16/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSSlice;

@interface CSRefine : NSObject <NSCopying>

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *valueName;

- (void)getSliceWithoutRefine:(id<CSSlice>)slice
                     callback:(void (^)(id<CSSlice> result,
                                        NSError *error))callback;

@end
