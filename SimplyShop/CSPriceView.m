//
//  CSPriceView.m
//  SimplyShop
//
//  Created by Will Harris on 07/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSPriceView.h"
#import <CSApi/CSAPI.h>

@interface CSPriceView ()

@property (strong, nonatomic) UIView *subview;

- (void)initialize;
- (void)updateContent;

@end

@implementation CSPriceView

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
    _subview = [[[NSBundle mainBundle] loadNibNamed:@"CSPriceView"
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
}

- (void)updateContent
{
    self.hidden = self.price == nil;
    self.priceLabel.text = [NSString stringWithFormat:@"%@%@",
                            self.price.currencySymbol,
                            self.price.price];
    
    self.deliveryLabel.text = [self deliveryText];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setPrice:(id<CSPrice>)price
{
    _price = price;
    [self updateContent];
}

- (NSString *)deliveryText
{
    NSNumber *deliveryPrice = self.price.deliveryPrice;
    if ( ! [deliveryPrice respondsToSelector:@selector(isEqualToNumber:)]) {
        return @"+ delivery";
    }
    
    if ([deliveryPrice isEqualToNumber:@(0.00)]) {
        return @"incl. delivery";
    }
    
    return [NSString stringWithFormat:@"+ %@%@ delivery",
            self.price.currencySymbol, deliveryPrice];
}

- (UIFont *)priceLabelFont
{
    return self.priceLabel.font;
}

- (void)setPriceLabelFont:(UIFont *)font
{
    self.priceLabel.font = font;
}

- (UIColor *)priceLabelColor
{
    return self.priceLabel.textColor;
}

- (void)setPriceLabelColor:(UIColor *)color
{
    self.priceLabel.textColor = color;
}

- (UIFont *)deliveryLabelFont
{
    return self.deliveryLabel.font;
}

- (void)setDeliveryLabelFont:(UIFont *)font
{
    self.deliveryLabel.font = font;
}

- (UIColor *)deliveryLabelColor
{
    return self.deliveryLabel.textColor;
}

- (void)setDeliveryLabelColor:(UIColor *)color
{
    self.deliveryLabel.textColor = color;
}

@end
