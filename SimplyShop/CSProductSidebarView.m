//
//  CSProductSidebarView.m
//  SimplyShop
//
//  Created by Will Harris on 02/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductSidebarView.h"

@interface CSProductSidebarView ()

@property (nonatomic, strong) UIImageView *backgroundView;

@end

@implementation CSProductSidebarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (UIImage *)backgroundImage
{
    return self.backgroundView.image;
}

- (void)setBackgroundImage:(UIImage *)newBackgroundImage
{
    if ( ! self.backgroundView) {
        self.backgroundView = [[UIImageView alloc] initWithImage:newBackgroundImage];
        [self insertSubview:self.backgroundView atIndex:0];
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}

- (void)layoutSubviews
{
    self.backgroundView.frame = self.bounds;
}

@end
