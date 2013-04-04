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
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (strong, nonatomic) id<CSTheme> theme UI_APPEARANCE_SELECTOR;

- (void)setLoadingURL:(NSURL *)URL;
- (void)setRetailer:(id<CSRetailer>)retailer URL:(NSURL *)URL;

@end
