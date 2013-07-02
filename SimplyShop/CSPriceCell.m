//
//  CSPriceCell.m
//  SimplyShop
//
//  Created by Will Harris on 02/07/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSPriceCell.h"
#import "CSStockView.h"
#import <CSApi/CSAPI.h>
#import "NSNumber+CSStringForCurrency.h"

@interface CSPriceCell ()

@property (strong, nonatomic) UIView *subview;

- (void)initialize;
- (void)updateContent;
- (NSString *)deliveryText;

@end

@implementation CSPriceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithStyle:UITableViewCellStyleDefault
               reuseIdentifier:@"CSPriceCell"];
}

- (void)initialize
{
    _subview = [[[NSBundle mainBundle] loadNibNamed:@"CSPriceCell"
                                              owner:self
                                            options:nil]
                objectAtIndex:0];
    _subview.frame = self.contentView.bounds;
    [self.contentView addSubview:_subview];
//    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self updateContent];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.subview.frame = self.contentView.bounds;
}

- (NSString *)stringForCurrency:(NSNumber *)value
                         symbol:(NSString *)symbol
                           code:(NSString *)code
{
    return [value stringForCurrencySymbol:symbol code:code];
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

    [self.contentView setNeedsDisplay];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setPrice:(id<CSPrice>)price
{
    _price = price;
    [price getRetailer:^(id<CSRetailer> retailer, NSError *error) {
        if (error) {
            // TODO: handler error
            return;
        }
        self.retailerNameLabel.text = retailer.name;
    }];
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

- (void)setPriceLabelColor:(UIColor *)color
{
    _priceLabelColor = color;
    self.priceLabel.textColor = _priceLabelColor;
}

- (UIFont *)deliveryLabelFont
{
    return self.deliveryLabel.font;
}

- (void)setDeliveryLabelFont:(UIFont *)font
{
    self.deliveryLabel.font = font;
}

- (void)setDeliveryLabelColor:(UIColor *)color
{
    _deliveryLabelColor = color;
    self.deliveryLabel.textColor = _deliveryLabelColor;
}

- (UIFont *)retailerNameLabelFont
{
    return self.retailerNameLabel.font;
}

- (void)setRetailerNameLabelFont:(UIFont *)font
{
    self.retailerNameLabel.font = font;
}

- (void)setRetailerNameLabelColor:(UIColor *)color
{
    _retailerNameLabelColor = color;
    self.retailerNameLabel.textColor = _retailerNameLabelColor;
}

- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor
{
    _selectedBackgroundColor = selectedBackgroundColor;
    self.selectedBackgroundView = [[UIView alloc] init];
    self.selectedBackgroundView.backgroundColor = selectedBackgroundColor;
}

- (void)setSelectedForegroundColor:(UIColor *)selectedForegroundColor
{
    _selectedForegroundColor = selectedForegroundColor;
    self.retailerNameLabel.highlightedTextColor = selectedForegroundColor;
    self.priceLabel.highlightedTextColor = selectedForegroundColor;
    self.deliveryLabel.highlightedTextColor = selectedForegroundColor;
}

@end
