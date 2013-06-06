//
//  CSRetailerSelectionCell.m
//  SimplyShop
//
//  Created by Will Harris on 28/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRetailerSelectionCell.h"
#import "CSTheme.h"
#import <CSApi/CSAPI.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+CSImageSelection.h"

@interface CSRetailerSelectionCell ()

@property (nonatomic, strong) NSObject *address;
@property (nonatomic, strong) NSObject<CSRetailer> *retailer;

- (void)initialize;
- (void)updateContent;

@end

@implementation CSRetailerSelectionCell

@synthesize theme;
@synthesize isReady;
@synthesize logoImageView;

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
    [self addSubview:[[[NSBundle mainBundle]
                       loadNibNamed:@"CSRetailerSelectionCell"
                       owner:self
                       options:nil]
                      objectAtIndex:0]];
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.layer.shouldRasterize = YES;
    self.address = nil;
    [self updateContent];
}

- (void)setIsReady:(BOOL)newIsReady
{
    if (newIsReady != isReady) {
        [self willChangeValueForKey:@"isReady"];
        isReady = newIsReady;
        [self didChangeValueForKey:@"isReady"];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.selected = NO;
    self.logoImageView.hidden = YES;
    [self.logoImageView cancelCurrentImageLoad];

    self.retailerNameLabel.text = @"";
    self.retailerNameLabel.hidden = NO;
    
    self.address = nil;
    self.retailer = nil;

    self.isReady = NO;
}

- (void)setTheme:(id<CSTheme>)newTheme
{
    if (newTheme == theme) {
        return;
    }
    
    theme = newTheme;
    UIImage *backgroundImage = [theme collectionViewCellBackgroundImage];
    UIImage *selectedBackgroundImage = [theme collectionViewCellSelectedBackgroundImage];
    self.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:selectedBackgroundImage];
}

- (void)setLoadingAddress:(NSObject *)address
{
    self.retailer = nil;
    self.address = address;
    self.isReady = NO;
    [self updateContent];
}

- (void)setRetailer:(NSObject<CSRetailer> *)retailer
            address:(NSObject *)address
{
    if (address != self.address) {
        // We ignore the retailer data because the cell has been reused for a
        // different retailer.
        return;
    }
    
    self.retailer = retailer;
    self.isReady = YES;
    [self updateContent];
}

- (void)updateContent
{
    if (self.retailer) {
        self.retailerNameLabel.text = self.retailer.name;
        
        [self.retailer getLogo:^(id<CSPicture> picture, NSError *error) {
            if (error) {
                // Ignore error.
                return;
            }
            
            [self.logoImageView setImageWithPicture:picture
                                          completed:^(UIImage *image,
                                                      NSError *error)
            {
                if ( ! image) {
                    return;
                }
                self.retailerNameLabel.hidden = YES;
                self.logoImageView.hidden = NO;
            }];
        }];
    } else {
        self.retailerNameLabel.text = @"...";
    }
}

- (void)setModel:(id)model address:(id)address
{
    [self setRetailer:model address:address];
}

- (void)setError:(NSError *)error address:(id)address
{
    // Do nothing
}

@end
