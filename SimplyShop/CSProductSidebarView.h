//
//  CSProductSidebarView.h
//  SimplyShop
//
//  Created by Will Harris on 02/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSPrice;
@class  CSRetailerLogoView;
@class CSPriceView;
@class CSProductSidebarView;

@protocol CSProductSidebarViewDelegate <NSObject>

- (void)sidebarView:(CSProductSidebarView *)view
     didSelectPrice:(id<CSPrice>)price;

@end

@interface CSProductSidebarView : UIView

@property (weak, nonatomic) IBOutlet CSRetailerLogoView *logoView;
@property (weak, nonatomic) IBOutlet CSPriceView *priceView;
@property (weak, nonatomic) IBOutlet UIButton *buyNowButton;
@property (weak, nonatomic) IBOutlet id<CSProductSidebarViewDelegate> delegate;

@property (strong, nonatomic) UIImage *backgroundImage UI_APPEARANCE_SELECTOR;

@property (strong, nonatomic) id<CSPrice> price;

@end
