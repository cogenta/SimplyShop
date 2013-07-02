//
//  CSStockView.m
//  SimplyShop
//
//  Created by Will Harris on 07/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSStockView.h"
#import <CSApi/CSAPI.h>

@interface CSStockView ()

@property (strong, nonatomic) UIView *subview;
@property (strong, nonatomic) UIImageView *backgroundView;
@property (strong, nonatomic) UIImage *backgroundImage;

- (void)initialize;
- (void)updateContent;

@end

@implementation CSStockView

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
    _subview = [[[NSBundle mainBundle] loadNibNamed:@"CSStockView"
                                              owner:self
                                            options:nil]
                objectAtIndex:0];
    _subview.frame = self.bounds;
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:_subview];
    [self updateContent];
}

- (void)layoutSubviews
{
    self.subview.frame = self.bounds;
    self.backgroundView.frame = self.subview.bounds;
}

- (void)setInStockImage:(UIImage *)inStockImage
{
    _inStockImage = inStockImage;
    [self setStock:self.price.stock];
}

- (void)setInStockColor:(UIColor *)inStockColor
{
    _inStockColor = inStockColor;
    [self setStock:self.price.stock];
}

- (void)setNoStockImage:(UIImage *)noStockImage
{
    _noStockImage = noStockImage;
    [self setStock:self.price.stock];
}

- (void)setNoStockColor:(UIColor *)noStockColor
{
    _noStockColor = noStockColor;
    [self setStock:self.price.stock];
}

- (void)setStock:(NSString *)stock
{
    [self setNeedsDisplay];
    if ([stock isEqualToString:@"IN_STOCK"]) {
        self.label.text = @"IN STOCK";
        self.backgroundImage = self.inStockImage;
        self.label.textColor = self.inStockColor;
        self.hidden = NO;
        return;
    }
    
    if ([stock isEqualToString:@"OUT_OF_STOCK"]) {
        self.label.text = @"NO STOCK";
        self.backgroundImage = self.noStockImage;
        self.label.textColor = self.noStockColor;
        self.hidden = NO;
        return;
    }
    
    self.hidden = YES;
}

- (void)updateContent
{
    self.hidden = self.price == nil;

    [self setStock:self.price.stock];
    
    [self setNeedsLayout];
}

- (void)setPrice:(id<CSPrice>)price
{
    _price = price;
    [self updateContent];
}

- (UIImage *)backgroundImage
{
    return self.backgroundView.image;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    if ( ! backgroundImage) {
        [self.backgroundView removeFromSuperview];
        self.backgroundView = nil;
        return;
    }
    
    if (self.backgroundView) {
        self.backgroundView.image = backgroundImage;
        return;
    }
    
    self.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    self.backgroundView.frame = self.subview.bounds;
    [self.subview insertSubview:self.backgroundView atIndex:0];
    self.subview.backgroundColor = [UIColor clearColor];
    self.subview.opaque = NO;
    [self setNeedsDisplay];
}

@end
