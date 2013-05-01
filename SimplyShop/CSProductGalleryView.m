//
//  CSProductGalleryView.m
//  SimplyShop
//
//  Created by Will Harris on 01/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductGalleryView.h"

@interface CSProductGalleryView ()

@property (nonatomic, strong) UIImageView *backgroundView;
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
    _backgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:_backgroundView];    
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundView.image = backgroundImage;
}

- (UIImage *)backgroundImage
{
    return _backgroundView.image;
}

- (void)layoutSubviews
{
    _backgroundView.frame = self.bounds;
}

@end
