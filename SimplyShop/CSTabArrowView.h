//
//  CSTabArrowView.h
//  SimplyShop
//
//  Created by Will Harris on 29/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSTabArrowView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;

@property (strong, nonatomic) UIImage *leftImage UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIImage *arrowImage UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIImage *rightImage UI_APPEARANCE_SELECTOR;

@property (nonatomic) CGFloat position;

- (void)setPosition:(CGFloat)position animated:(BOOL)animated;

@end
