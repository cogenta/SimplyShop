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
#import <MBCategory/MBCategory.h>

@interface CSProductSidebarView () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIView *clippingView;
@property (strong, nonatomic) UIView *singlePriceView;
@property (strong, nonatomic) UIView *priceListView;
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
    [self.tableView reloadData];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.prices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if ( ! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.backgroundView = [[UIView alloc] init];
    }
    cell.textLabel.text = @"Loading";
    
    if (indexPath.row % 2 == 0) {
        cell.backgroundView.backgroundColor = [UIColor whiteColor];
    } else {
        cell.backgroundView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    }
    cell.textLabel.backgroundColor = cell.backgroundView.backgroundColor;
    
    [self.prices getPriceAtIndex:indexPath.row
                        callback:^(id<CSPrice> result, NSError *error)
    {
        if (error) {
            cell.textLabel.text = @"Error";
            return;
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%@", result.effectivePrice];
        
        [result getRetailer:^(id<CSRetailer> retailer, NSError *error) {
            if (error) {
                // TODO: better error handling
                return;
            }
            cell.detailTextLabel.text = retailer.name;
            cell.detailTextLabel.backgroundColor = cell.backgroundView.backgroundColor;
        }];
    }];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.prices getPriceAtIndex:indexPath.row
                        callback:^(id<CSPrice> result, NSError *error)
     {
         if (error) {
             // TODO: better error handling
             return;
         }
         self.price = result;
         [self showSinglePriceAnimated:YES];
     }];
}

@end
