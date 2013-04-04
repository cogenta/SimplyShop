//
//  CSAppearanceButton.m
//  SimplyShop
//
//  Created by Will Harris on 04/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSAppearanceButton.h"

@implementation CSAppearanceButton

- (void)setTitleFont:(UIFont *)font
{
    self.titleLabel.font = font;
}

- (void)setTitleColor:(UIColor *)color
{
    [self setTitleColor:color forState:UIControlStateNormal];
}

- (void)setTitleShadowColor:(UIColor *)color
{
    [self setTitleShadowColor:color forState:UIControlStateNormal];
}

- (void)setTitleLabelShadowOffset:(CGSize)offset
{
    [self.titleLabel setShadowOffset:offset];
}

@end
