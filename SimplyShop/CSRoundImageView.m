//
//  CSRoundImageView.m
//  SimplyShop
//
//  Created by Will Harris on 05/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRoundImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface CSRoundImageView ()

- (void)initialize;

@end

@implementation CSRoundImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.shouldRasterize = YES;
    self.clipsToBounds = YES;
    self.layer.opaque = NO;
    self.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 5.0;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
}

@end
