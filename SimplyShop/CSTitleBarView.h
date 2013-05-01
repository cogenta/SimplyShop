//
//  CSTitleBarView.h
//  SimplyShop
//
//  Created by Will Harris on 01/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSTitleBarView : UIView

@property (strong, nonatomic) UIImage *backgroundImage UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIFont *titleFont UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *titleColor UI_APPEARANCE_SELECTOR;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (copy, nonatomic) NSString *title;

@end
