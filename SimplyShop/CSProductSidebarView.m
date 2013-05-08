//
//  CSProductSidebarView.m
//  SimplyShop
//
//  Created by Will Harris on 02/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductSidebarView.h"
#import "CSRetailerLogoView.h"
#import "CSPriceView.h"
#import <CSApi/CSAPI.h>

@interface CSProductSidebarView ()

@property (strong, nonatomic) UIView *subview;
@property (strong, nonatomic) UIImageView *backgroundView;

- (void)initialize;
- (void)updateContent;

@end

@implementation CSProductSidebarView

@synthesize price;

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
    _subview = [[[NSBundle mainBundle] loadNibNamed:@"CSProductSidebarView"
                                              owner:self
                                            options:nil]
                objectAtIndex:0];
    _subview.frame = self.bounds;
    [self addSubview:_subview];
    [self updateContent];
}

- (UIImage *)backgroundImage
{
    return self.backgroundView.image;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    if (self.backgroundView) {
        self.backgroundView.image = backgroundImage;
        return;
    }
    
    self.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    self.backgroundView.frame = self.subview.bounds;
    [self.subview insertSubview:self.backgroundView atIndex:0];
}

- (void)layoutSubviews
{
    self.backgroundView.frame = self.subview.bounds;
    [self.subview insertSubview:self.backgroundView atIndex:0];
}

- (id<CSPrice>)price
{
    return price;
}

- (void)setPrice:(id<CSPrice>)newPrice
{
    price = newPrice;
    [self updateContent];
}

- (void)updateContent
{
    if ( ! self.price) {
        self.logoView.retailer = nil;
        self.priceView.price = nil;
        return;
    }
    
    self.priceView.price = self.price;
    
    [self.price getRetailer:^(id<CSRetailer> retailer, NSError *error) {
        if (error) {
            // TODO: handle error better
            self.logoView.retailer = nil;
            return;
        }
        
        self.logoView.retailer = retailer;
    }];
}

- (IBAction)didTapBuyNow:(id)sender {
    [self.delegate sidebarView:self didSelectPrice:self.price];
}

@end
