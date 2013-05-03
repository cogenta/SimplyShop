//
//  CSRetailerLogoView.h
//  SimplyShop
//
//  Created by Will Harris on 03/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSRetailer;

@interface CSRetailerLogoView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *retailerNameLabel;

@property (strong, nonatomic) UIImage *backgroundImage UI_APPEARANCE_SELECTOR;

@property (strong, nonatomic) id<CSRetailer> retailer;

@end
