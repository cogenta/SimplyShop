//
//  CSStockView.h
//  SimplyShop
//
//  Created by Will Harris on 07/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSPrice;

@interface CSStockView : UIView

@property (weak, nonatomic) IBOutlet UILabel *label;

@property (strong, nonatomic) UIImage *inStockImage UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *inStockColor UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIImage *noStockImage UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *noStockColor UI_APPEARANCE_SELECTOR;

@property (nonatomic) id<CSPrice> price;

@end
