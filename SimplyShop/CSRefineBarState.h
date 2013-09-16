//
//  CSRefineBarState.h
//  SimplyShop
//
//  Created by Will Harris on 16/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSRefineBarState : NSObject

@property (nonatomic, assign) BOOL canRefineMore;
@property (nonatomic, strong) NSArray *refines;

@end
