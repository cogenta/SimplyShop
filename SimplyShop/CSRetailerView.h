//
//  CSRetailerView.h
//  SimplyShop
//
//  Created by Will Harris on 03/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSTheme;
@protocol CSRetailer;

@interface CSRetailerView : UIView

@property (weak, nonatomic) IBOutlet UILabel *retailerNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@property (strong, nonatomic) id<CSTheme> theme UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) id<CSRetailer> retailer;

@end
