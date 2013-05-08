//
//  CSPriceView.h
//  SimplyShop
//
//  Created by Will Harris on 07/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSPrice;
@class CSStockView;

@interface CSPriceView : UIView

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *deliveryLabel;
@property (weak, nonatomic) IBOutlet CSStockView *stockView;

@property (strong, nonatomic) UIFont *priceLabelFont UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *priceLabelColor UI_APPEARANCE_SELECTOR;

@property (strong, nonatomic) UIFont *deliveryLabelFont UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *deliveryLabelColor UI_APPEARANCE_SELECTOR;

@property (nonatomic) id<CSPrice> price;

- (NSString *)deliveryText;

@end
