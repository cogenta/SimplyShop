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
#import "CSPriceContext.h"
#import "CSPriceCell.h"
#import <CSApi/CSAPI.h>
#import <MBCategory/MBCategory.h>

@interface CSProductSidebarView () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIView *clippingView;
@property (strong, nonatomic) UIView *singlePriceView;
@property (strong, nonatomic) UIView *priceListView;
@property (strong, nonatomic) UIImageView *backgroundView;

@property (strong, nonatomic) NSArray *favoritePrices;
@property (strong, nonatomic) NSArray *otherPrices;

- (void)initialize;
- (void)updateContent;
- (void)updatePriceList;

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
    CGRect clippingFrame = self.bounds;
    clippingFrame.origin.x += 1.0;
    clippingFrame.size.width -= 1.0;
    _clippingView = [[UIView alloc] initWithFrame:clippingFrame];
    _clippingView.translatesAutoresizingMaskIntoConstraints = YES;
    _clippingView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _clippingView.backgroundColor = [UIColor clearColor];
    _clippingView.clipsToBounds = YES;
    [self addSubview:_clippingView];
    
    _singlePriceView = [[[NSBundle mainBundle] loadNibNamed:@"CSProductSidebarView_Single"
                                                      owner:self
                                                    options:nil]
                        objectAtIndex:0];
    _singlePriceView.opaque = NO;
    _singlePriceView.backgroundColor = [UIColor clearColor];
    _singlePriceView.frame = _clippingView.bounds;
    [_clippingView addSubview:_singlePriceView];
    
    _priceListView = [[[NSBundle mainBundle] loadNibNamed:@"CSProductSidebarView_List"
                                                    owner:self
                                                  options:nil]
                      objectAtIndex:0];
    _priceListView.opaque = YES;
    _priceListView.backgroundColor = [UIColor whiteColor];
    CGRect pricelistViewFrame = _clippingView.bounds;
    pricelistViewFrame.origin.x += _clippingView.bounds.size.width;
    _priceListView.frame = pricelistViewFrame;
    [_clippingView addSubview:_priceListView];
    
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
    self.backgroundView.frame = self.bounds;
    [self insertSubview:self.backgroundView atIndex:0];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect clippingFrame = self.bounds;
    clippingFrame.origin.x += 1.0;
    clippingFrame.size.width -= 1.0;
    _clippingView.frame = clippingFrame;
    
    _singlePriceView.frame = _clippingView.bounds;
    
    CGRect pricelistViewFrame = _clippingView.bounds;
    pricelistViewFrame.origin.x += _clippingView.bounds.size.width;
    _priceListView.frame = pricelistViewFrame;
    
    self.backgroundView.frame = self.bounds;
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

- (void)setPrices:(id<CSPriceList>)prices
{
    _prices = prices;
    if (self.prices && self.priceContext) {
        [self updatePriceList];
    }
}

- (void)setPriceContext:(CSPriceContext *)priceContext
{
    _priceContext = priceContext;
    if (self.prices && self.priceContext) {
        [self updatePriceList];
    }
}

- (void)updateContent
{
    if ( ! self.price) {
        self.logoView.retailer = nil;
        self.priceView.price = nil;
        self.buyNowButton.hidden = YES;
        return;
    }
    
    self.buyNowButton.hidden = NO;
    
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

- (void)updatePriceList
{
    if ( ! self.priceContext || ! self.prices) {
        self.favoritePrices = nil;
        self.otherPrices = nil;
        return;
    }
    
    [self.priceContext getFavoritePrices:self.prices
                                callback:^(NSArray *prices, NSError *error)
    {
        if (error) {
            // TODO: handle error
            return;
        }
        
        self.favoritePrices = prices;
    }];
    
    [self.priceContext getOtherPrices:self.prices
                             callback:^(NSArray *prices, NSError *error)
     {
         if (error) {
             // TODO: handle error
             return;
         }
         
         self.otherPrices = prices;
     }];
}

- (void)setFavoritePrices:(NSArray *)favoritePrices
{
    _favoritePrices = favoritePrices;
    if (self.favoritePrices && self.otherPrices) {
        [self.tableView reloadData];
    }
}

- (void)setOtherPrices:(NSArray *)otherPrices
{
    _otherPrices = otherPrices;
    if (self.favoritePrices && self.otherPrices) {
        [self.tableView reloadData];
    }
}

- (IBAction)didTapBuyNow:(id)sender
{
    [self.delegate sidebarView:self didSelectPrice:self.price];
}

- (IBAction)didTapViewAll:(id)sender
{
    [self showAllPricesAnimated:YES];
}

- (IBAction)didTapViewBest:(id)sender
{
    [self showSinglePriceAnimated:YES];
}

- (void)showAllPricesAnimated:(BOOL)animated
{
    void (^animation)() = ^{
        CGRect frame = self.clippingView.bounds;
        frame.origin.x = -frame.size.width - 1.0;
        self.singlePriceView.frame = frame;
        
        _priceListView.frame = self.clippingView.bounds;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.25 animations:animation];
    } else {
        animation();
    }
    
}

- (void)showSinglePriceAnimated:(BOOL)animated
{
    void (^animation)() = ^{
        self.singlePriceView.frame = self.clippingView.bounds;
        
        CGRect frame = self.clippingView.bounds;
        frame.origin.x = frame.size.width + 1.0;
        self.priceListView.frame = frame;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.25 animations:animation];
    } else {
        animation();
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.favoritePrices && self.otherPrices) {
        return 2;
    }
    
    return 0;
}

- (NSArray *)priceListForSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return self.favoritePrices;
            
        case 1:
            return self.otherPrices;
            
        default:
            return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self priceListForSection:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Favourites";
            
        case 1:
            return @"Other stores";
            
        default:
            return @"";
    }
}

- (id<CSPrice>)priceForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *priceList = [self priceListForSection:indexPath.section];
    return priceList[indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CSPriceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CSPriceCell"];
    if ( ! cell) {
        cell = [[CSPriceCell alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 39.0)];
        cell.backgroundView = [[UIView alloc] init];
    }
    
    if (indexPath.row % 2 == 0) {
        cell.backgroundView.backgroundColor = [UIColor whiteColor];
    } else {
        cell.backgroundView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    }
    cell.textLabel.backgroundColor = cell.backgroundView.backgroundColor;
    
    id<CSPrice> result = [self priceForRowAtIndexPath:indexPath];
    cell.price = result;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 39.0;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.price = [self priceForRowAtIndexPath:indexPath];
     [self showSinglePriceAnimated:YES];
}

@end
