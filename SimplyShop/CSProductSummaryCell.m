//
//  CSProductSummaryCell.m
//  SimplyShop
//
//  Created by Will Harris on 09/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductSummaryCell.h"
#import <QuartzCore/QuartzCore.h>
#import <CSApi/CSAPI.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "CSTheme.h"
#import "CSCTAButton.h"
#import "CSProductWrapper.h"
#import "CSPriceContext.h"
#import "NSNumber+CSStringForCurrency.h"

@interface CSProductSummaryCell ()

@property (strong, nonatomic) UIImageView *backgroundView;
@property (strong, nonatomic) CSProductWrapper *wrapper;
@property (strong, nonatomic) NSError *error;
@property (assign, nonatomic) SEL nameTransform;
@property (strong, nonatomic) UIView *subview;

- (void)updateContent;
- (void)initialize;

@end

@implementation CSProductSummaryCell

@synthesize theme;

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

- (NSString *)nibName
{
    return @"CSProductSummaryCell";
}

- (void)initialize
{
    self.subview = [[[NSBundle mainBundle]
                       loadNibNamed:[self nibName]
                       owner:self
                       options:nil]
                      objectAtIndex:0];
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.layer.shouldRasterize = YES;

    self.subview.frame = self.bounds;
    [self addSubview:self.subview];
    
    self.nameTransform = @selector(self);
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.selected = NO;
    self.productImageView.hidden = YES;
    self.retryButton.hidden = YES;
    [self.productImageView cancelCurrentImageLoad];
    
    self.productNameLabel.text = @"";
    
    self.productDescriptionLabel.text = @"";
    
    self.priceLabel.text = @"";
    
    self.address = nil;
    self.wrapper = nil;
}

- (void)setTheme:(id<CSTheme>)newTheme
{
    theme = newTheme;
    UIImage *backgroundImage = [theme collectionViewCellBackgroundImage];
    
    if ( ! self.backgroundView) {
        self.backgroundView = [[UIImageView alloc]
                               initWithFrame:self.contentView.bounds];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView insertSubview:self.backgroundView atIndex:0];
    }
    
    [self.backgroundView setImage:backgroundImage];
    self.nameTransform = [theme producNameTransform];
    
    [newTheme themeCTAButton:self.retryButton];
}

- (IBAction)didTapRetryButton:(id)sender {
    [self.delegate productSummaryCell:self
               needsReloadWithAddress:self.address];
}

- (void)setLoadingAddress:(NSObject *)address
{
    if ([address isEqual:self.address] && self.wrapper) {
        return;
    }
    
    self.wrapper = nil;
    self.error = nil;
    self.address = address;
    [self updateContent];
}

- (void)setWrapper:(CSProductWrapper *)wrapper
           address:(NSObject *)address
{
    if (self.wrapper) {
        // A product is already set.
        return;
    }
    
    if (self.error) {
        // An error is already set.
        return;
    }
    
    if ( ! [address isEqual:self.address]) {
        // The view has been reused with another address.
        return;
    }
    
    self.error = nil;
    self.wrapper = wrapper;
    [self updateContent];
}


- (void)setError:(NSError *)error address:(NSObject *)address
{
    if (self.wrapper) {
        // A product is already set.
        return;
    }
    
    if (self.error) {
        // An error is already set.
        return;
    }
    
    if ( ! [address isEqual:self.address]) {
        // The view has been reused with another address.
        return;
    }
    
    self.error = error;
    self.wrapper = nil;
    [self updateContent];
}

- (NSString *)transformedName:(NSString *)name
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [name performSelector:self.nameTransform];
#pragma clang diagnostic pop
}

- (void)showLoadingState
{
    self.productNameLabel.text = [self transformedName:@"Loading"];
    self.productDescriptionLabel.text = @"...";
    self.priceLabel.text = @"";
    self.productImageView.hidden = YES;
    self.retryButton.hidden = YES;
}

- (void)showError
{
    self.productNameLabel.text = [self transformedName:@"Error"];
    self.productDescriptionLabel.text = @"...";
    self.priceLabel.text = @"";
    self.productImageView.hidden = YES;
    self.retryButton.hidden = NO;
}

- (void)loadPrice
{
    id priceAddress = self.address;

    [self.wrapper getPrices:^(id<CSPriceListPage> firstPage, NSError *error) {
        if (priceAddress != self.address) {
            return;
        }
        
        if (error) {
            // TODO: better error handling
            self.priceLabel.text = nil;
            return;
        }
        
        [self.priceContext getBestPrice:firstPage.priceList
                               callback:^(id<CSPrice> bestPrice)
         {
             if (priceAddress != self.address) {
                 return;
             }
             
             NSNumber *value = bestPrice.effectivePrice;
             NSString *symbol = bestPrice.currencySymbol;
             NSString *code = bestPrice.currencyCode;
             self.priceLabel.text = [value stringForCurrencySymbol:symbol
                                                              code:code];
         }];
    }];
}

- (void)loadPicture
{
    id pictureAddress = self.address;
    
    [self.wrapper getPictures:^(id<CSPictureListPage> firstPage,
                                NSError *error)
     {
         if (firstPage.count == 0) {
             self.productImageView.hidden = YES;
             return;
         }
         
         [firstPage.pictureList getPictureAtIndex:0
                                         callback:^(id<CSPicture> picture,
                                                    NSError *error)
          {
              if (pictureAddress != self.address) {
                  return;
              }
              
              if (error) {
                  /// Ignore picture error.
                  return;
              };
              
              id<CSImageList> images = picture.imageList;
              
              __block id<CSImage> bestImage = nil;
              for (NSInteger i = 0 ; i < images.count; ++i) {
                  id imageAddress = self.address;
                  
                  [images getImageAtIndex:i
                                 callback:^(id<CSImage> image, NSError *error)
                   {
                       if (imageAddress != self.address) {
                           return;
                       }
                       
                       if (error) {
                           // Ignore image error.
                           return;
                       }
                       
                       if ([image.width doubleValue]
                           > [bestImage.width doubleValue]) {
                           bestImage = image;
                       }
                       
                       if (i == images.count - 1 && bestImage) {
                           [self.productImageView
                            setImageWithURL:bestImage.enclosureURL
                            completed:^(UIImage *image,
                                        NSError *error,
                                        SDImageCacheType cacheType)
                            {
                                if ( ! image) {
                                    return;
                                }
                                self.productImageView.hidden = NO;
                            }];
                       }
                   }];
              }
          }];
         
     }];
}

- (void)showProduct
{
    self.retryButton.hidden = YES;
    self.productNameLabel.text = [self transformedName:self.wrapper.name];
    if (self.wrapper.description_ != (id) [NSNull null]) {
        self.productDescriptionLabel.text = self.wrapper.description_;
    }
    
    if (self.priceLabel) {
        [self loadPrice];
    }
    
    if (self.productImageView) {
        [self loadPicture];
    }
}


- (void)updateContent
{
    if (self.wrapper) {
        [self showProduct];
        return;
    }
    
    if (self.error) {
        [self showError];
        return;
    }
    
    [self showLoadingState];
}

- (void)layoutSubviews
{
    self.subview.frame = self.bounds;
}

@end
