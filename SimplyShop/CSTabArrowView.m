//
//  CSTabArrowView.m
//  SimplyShop
//
//  Created by Will Harris on 29/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSTabArrowView.h"

#define kArrowOffset (11.0 / 2.0)
#define kArrowWidth (23.0 / 2.0)
#define kArrowHeight (18.0 / 2.0)

@interface CSTabArrowView ()

@property (readonly) CGFloat normalizedPosition;
@property (weak, nonatomic) UIView *subview;

- (void)load;

@end

@implementation CSTabArrowView

@synthesize position;

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
                     loadNibNamed:@"CSTabArrowView"
                     owner:self
                     options:nil]
                    objectAtIndex:0];
    [self addSubview:self.subview];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setLeftImage:(UIImage *)image
{
    self.leftImageView.image = image;
}

- (UIImage *)leftImage
{
    return self.leftImageView.image;
}

- (void)setArrowImage:(UIImage *)image
{
    self.arrowImageView.image = image;
}

- (UIImage *)arrowImage
{
    return self.arrowImageView.image;
}

- (void)setRightImage:(UIImage *)image
{
    self.rightImageView.image = image;
}

- (UIImage *)rightImage
{
    return self.rightImageView.image;
}

- (void)layoutSubviews
{
    [self sizeToFit];
    self.subview.frame = self.bounds;
    CGFloat arrowLeft = self.normalizedPosition - kArrowOffset;
    CGFloat arrowRight = arrowLeft + kArrowWidth;
    CGFloat rightWidth = self.bounds.size.width - arrowRight;
    CGRect arrowFrame = CGRectMake(arrowLeft, 0.0,
                                   kArrowWidth, kArrowHeight);
    CGRect leftFrame = CGRectMake(0.0, 0.0,
                                  arrowLeft, kArrowHeight);
    CGRect rightFrame = CGRectMake(arrowRight, 0.0,
                                   rightWidth, kArrowHeight);
    
    self.leftImageView.frame = leftFrame;
    self.arrowImageView.frame = arrowFrame;
    self.rightImageView.frame = rightFrame;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(MAX(kArrowWidth + 2.0, size.width),
                      MAX(kArrowHeight, size.height));
}

- (CGFloat)normalizedPosition
{
    return MAX(self.position, kArrowOffset + 2.0);
}

- (CGFloat)position
{
    return position;
}

- (void)setPosition:(CGFloat)newPosition
{
    [self setPosition:newPosition animated:NO];
}

- (void)setPosition:(CGFloat)newPosition animated:(BOOL)animated
{
    if (animated) {
        [UIView beginAnimations:@"MoveArrow" context:NULL];
        [UIView setAnimationDuration:0.25];
    }
    position = newPosition;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    if (animated) {
        [UIView commitAnimations];
    }
}

@end
