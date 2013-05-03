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

@interface CSProductSidebarView : UIView

@property (weak, nonatomic) IBOutlet CSRetailerLogoView *logoView;

@property (strong, nonatomic) UIImage *backgroundImage UI_APPEARANCE_SELECTOR;

@property (strong, nonatomic) id<CSPrice> price;

@end
