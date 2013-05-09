//
//  CSProductDetailsView.m
//  SimplyShop
//
//  Created by Will Harris on 26/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductDetailsView.h"
#import "CSTabBarView.h"
#import "CSProductStatsView.h"
#import "CSProductGalleryView.h"
#import "CSTabFooterView.h"

@interface CSProductDetailsView () <CSTabBarViewDelegate>

@property (weak, nonatomic) UIView *subview;
@property (weak, nonatomic) UIView *selectedView;

- (void)load;

- (void)selectView:(UIView *)newSelectedView;

@end

@implementation CSProductDetailsView

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
    self.subview = [[[NSBundle mainBundle]
                     loadNibNamed:@"CSProductDetailsView"
                     owner:self
                     options:nil]
                    objectAtIndex:0];
    [self addSubview:self.subview];
    
    [self selectView:self.descriptionLabel];
}

- (void)setDescription_:(NSString *)description
{
    _description_ = [description copy];
    if (description == (id) [NSNull null]) {
        description = @"No Description";
    }
    self.descriptionLabel.text = description;
    [self setNeedsLayout];
}

- (void)setStats:(CSProductStats *)stats
{
    _stats = stats;
    self.productStatsView.stats = stats;
    [self setNeedsLayout];
}

- (void)setPictures:(id<CSPictureList>)pictures
{
    self.galleryView.pictures = pictures;
}

- (id<CSPictureList>)pictures
{
    return self.galleryView.pictures;
}

- (void)layoutSubviews
{
    CGFloat fixedHeight = (self.subview.frame.size.height -
                           self.selectedView.frame.size.height);
    
    CGFloat maxHeight = [UIScreen mainScreen].bounds.size.height - fixedHeight;
    
    CGFloat margin = CGRectGetMinX(self.selectedView.frame);
    
    CGSize size = self.bounds.size;
    CGSize marginSize = CGSizeMake(size.width - 2 * margin, maxHeight);
    
    CGSize selectedSize = [self.selectedView sizeThatFits:marginSize];
    
    CGFloat contentHeight = selectedSize.height + fixedHeight;
    
    CGRect subviewFrame;
    subviewFrame.size = CGSizeMake(size.width, contentHeight);
    subviewFrame.origin = CGPointZero;
    
    self.contentSize = subviewFrame.size;
    self.subview.frame = subviewFrame;
}

- (void)selectView:(UIView *)newSelectedView
{
    self.selectedView.hidden = YES;
    self.selectedView = newSelectedView;
    self.selectedView.hidden = NO;
    [self setNeedsLayout];
}

- (void)selectDescription
{
    [self selectView:self.descriptionLabel];
}

- (void)selectStats
{
    [self selectView:self.productStatsView];
}

@end
