//
//  CSProductStatsView.h
//  SimplyShop
//
//  Created by Will Harris on 30/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSProductStats;

@interface CSProductStatsView : UIView

@property (assign, nonatomic) CGFloat heightForRow UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) CGFloat margin UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIFont *labelFont UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *labelColor UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIFont *valueFont UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *valueColor UI_APPEARANCE_SELECTOR;

@property (strong, nonatomic) CSProductStats *stats;

@end
