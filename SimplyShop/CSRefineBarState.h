//
//  CSRefineBarState.h
//  SimplyShop
//
//  Created by Will Harris on 16/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSSlice;

@interface CSRefineBarState : NSObject

@property (nonatomic, assign) BOOL canRefineMore;
@property (nonatomic, strong) NSArray *refines;

+ (void)getRefineBarStateForSlice:(id<CSSlice>)slice
                         callback:(void (^)(CSRefineBarState *state,
                                            NSError *error))cb;

@end
