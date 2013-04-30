//
//  CSProductDetailsView.m
//  SimplyShop
//
//  Created by Will Harris on 26/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductDetailsView.h"
#import "CSTabArrowView.h"
#import "CSTabFooterView.h"
#import "CSProductStatsView.h"

@interface CSProductDetailsView ()

@property (weak, nonatomic) UIView *subview;

- (void)load;

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
    self.descriptionTabArrowView.position = 52.0;
    self.productStatsTabArrowView.position = 58.0;
    
    [self setNeedsLayout];
}

- (void)setDescription:(NSString *)description
{
    _description = [description copy];
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

- (void)layoutSubviews
{
    // Margin on left, right, and bottom description label.
    CGFloat margin = CGRectGetMinX(self.descriptionLabel.frame);

    CGSize statsViewSize = [self.productStatsView
                            sizeThatFits:self.productStatsView.frame.size];
    CGFloat statsHeight = (CGRectGetMaxY(self.productStatsTabArrowView.frame) -
                           CGRectGetMinY(self.tabFooterView.frame) +
                           statsViewSize.height);
    
    // Height in addition to description label's height.
    CGFloat fixedHeight = CGRectGetMinY(self.descriptionLabel.frame) + margin + statsHeight;
    
    // Size of the scroll view.
    CGSize size = self.bounds.size;
    
    // Maximum height of the description label.
    CGFloat maxHeight = [UIScreen mainScreen].bounds.size.height - fixedHeight;
    
    // Size in which to fit the description.
    CGSize marginSize = CGSizeMake(size.width - 2 * margin, maxHeight);
    
    // Size of the description.
    CGSize descriptionSize = [self.descriptionLabel sizeThatFits:marginSize];
    
    // Height for the content.
    CGFloat contentHeight = descriptionSize.height + fixedHeight;

    // Set the content's frame.
    CGRect subviewFrame;
    subviewFrame.size = CGSizeMake(size.width, contentHeight);
    subviewFrame.origin = CGPointZero;
    self.contentSize = subviewFrame.size;
    self.subview.frame = subviewFrame;    
    
    // Set description size.
    CGRect descriptionFrame = self.descriptionLabel.frame;
    descriptionFrame.size = descriptionSize;
    self.descriptionLabel.frame = descriptionFrame;
}

@end
