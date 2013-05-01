//
//  CSProductGalleryView.m
//  SimplyShop
//
//  Created by Will Harris on 01/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductGalleryView.h"

@interface CSProductGalleryView ()

@property (nonatomic, strong) UIView *subview;

- (void)initialize;

@end

@implementation CSProductGalleryView

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
    self.subview = [[[NSBundle mainBundle]
                     loadNibNamed:@"CSProductGalleryView"
                     owner:self
                     options:nil]
                    objectAtIndex:0];
    [self addSubview:self.subview];
    [self layoutSubviews];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImageView.image = backgroundImage;
}

- (UIImage *)backgroundImage
{
    return _backgroundImageView.image;
}

- (void)setFooterBackgroundImage:(UIImage *)footerBackgroundImage
{
    _footerImageView.image = footerBackgroundImage;
}

- (UIImage *)footerBackgroundImage
{
    return _footerImageView.image;
}

@end
