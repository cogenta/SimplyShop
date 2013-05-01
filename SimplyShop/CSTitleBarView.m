//
//  CSTitleBarView.m
//  SimplyShop
//
//  Created by Will Harris on 01/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSTitleBarView.h"

@implementation CSTitleBarView

@synthesize title;

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImageView.image = backgroundImage;
}

- (UIImage *)backgroundImage
{
    return _backgroundImageView.image;
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleLabel.font = titleFont;
}

- (UIFont *)titleFont
{
    return _titleLabel.font;
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleLabel.textColor = titleColor;
}

- (UIColor *)titleColor
{
    return _titleLabel.textColor;
}

- (void)setTitle:(NSString *)newTitle
{
    title = newTitle;
    _titleLabel.text = [title uppercaseString];
}

- (NSString *)title
{
    return title;
}

@end
