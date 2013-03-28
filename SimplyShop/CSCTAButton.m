//
//  CSCTAButton.m
//  SimplyShop
//
//  Created by Will Harris on 28/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSCTAButton.h"

@implementation CSCTAButton

- (void)setTextFont:(UIFont *)titleFont
{
    self.titleLabel.font = titleFont;
}

- (void)setTextColor:(UIColor *)color
{
    [self setTitleColor:color forState:UIControlStateNormal];
}

@end
