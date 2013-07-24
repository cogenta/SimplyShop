//
//  CSTabFooterView.m
//  SimplyShop
//
//  Created by Will Harris on 29/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSTabFooterView.h"

@interface CSTabFooterView ()

@property (readonly) UIImageView *backgroundImageView;
- (void)load;

@end

@implementation CSTabFooterView

@synthesize backgroundImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self load];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self load];
    }
    return self;
}

- (void)load
{
    backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:self.backgroundImageView];
}

- (void)setBackgroundImage:(UIImage *)image
{
    self.backgroundImageView.image = image;
}

- (UIImage *)backgroundImage
{
    return self.backgroundImageView.image;
}

- (void)layoutSubviews
{
    [self sizeToFit];
    self.backgroundImageView.frame = self.bounds;
}

@end
