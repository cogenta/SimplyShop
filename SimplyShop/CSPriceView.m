//
//  CSPriceView.m
//  SimplyShop
//
//  Created by Will Harris on 07/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSPriceView.h"
#import "CSStockView.h"
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

- (NSString *)stringForCurrency:(NSNumber *)value
                         symbol:(NSString *)symbol
                           code:(NSString *)code
{
    if ( ! value) {
        return nil;
    }
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setCurrencySymbol:symbol];
    [formatter setCurrencyCode:code];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:[NSLocale autoupdatingCurrentLocale]];
    
    NSNumber *roundedValue = [NSNumber numberWithInteger:[value integerValue]];
    BOOL isIntegerValue = [value isEqualToNumber:roundedValue];
    
    if (isIntegerValue) {
        [formatter setMaximumFractionDigits:0];
    }
    
    return [formatter stringFromNumber:value];
}

- (NSString *)formattedPrice
{
    if ( ! self.price.price) {
        return nil;
    }
    
    return [self stringForCurrency:self.price.price
                            symbol:self.price.currencySymbol
                              code:self.price.currencyCode];
}

- (void)updateContent
{
    self.hidden = self.price == nil;
    self.priceLabel.text = [self formattedPrice];
    
    self.deliveryLabel.text = [self deliveryText];
    self.stockView.price = self.price;
    
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
    
    NSString *symbol = self.price.currencySymbol;
    NSString *code = self.price.currencyCode;
    NSString *formattedDelvery = [self stringForCurrency:deliveryPrice
                                                  symbol:symbol
                                                    code:code];
    
    return [NSString stringWithFormat:@"+ %@ delivery", formattedDelvery];
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
