//
//  CSRetailerLogoView.m
//  SimplyShop
//
//  Created by Will Harris on 03/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRetailerLogoView.h"
#import <CSApi/CSAPI.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface CSRetailerLogoView ()

@property (strong, nonatomic) UIView *subview;
@property (strong, nonatomic) UIImageView *backgroundView;

- (void)initialize;
- (void)updateContent;

@end

@implementation CSRetailerLogoView

@synthesize retailer;

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
    _subview = [[[NSBundle mainBundle] loadNibNamed:@"CSRetailerLogoView"
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
    self.subview.backgroundColor = [UIColor clearColor];
    self.subview.opaque = NO;
}

- (void)layoutSubviews
{
    self.subview.frame = self.bounds;
    self.backgroundView.frame = self.subview.bounds;
}

- (void)updateContent
{
    if ( ! self.retailer) {
        self.logoImageView.hidden = YES;
        self.retailerNameLabel.text = @"Loading...";
        self.retailerNameLabel.hidden = NO;
        return;
    }
    
    self.logoImageView.hidden = YES;
    self.retailerNameLabel.text = self.retailer.name;
    self.retailerNameLabel.hidden = NO;
    
    self.retailerNameLabel.text = self.retailer.name;
    
    [self.retailer getLogo:^(id<CSPicture> picture, NSError *error) {
        if (error) {
            // Ignore error.
            return;
        }
        
        id<CSImageList> images = picture.imageList;
        
        CGSize targetSize = self.logoImageView.frame.size;
        targetSize.width *= 2.0;
        targetSize.height *= 2.0;
        
        __block id<CSImage> bestImage = nil;
        for (NSInteger i = 0 ; i < images.count; ++i) {
            [images getImageAtIndex:i
                           callback:^(id<CSImage> image, NSError *error)
             {
                 if (error) {
                     return;
                 }
                 
                 if ( ! bestImage) {
                     bestImage = image;
                 }
                 
                 if ([image.width doubleValue] <= targetSize.width &&
                     [image.height doubleValue] <= targetSize.height &&
                     ([image.width doubleValue] > [bestImage.width doubleValue] ||
                      [image.height doubleValue] > [bestImage.height doubleValue])) {
                     bestImage = image;
                 }
                 
                 if (i == images.count - 1 && bestImage) {
                     [self.logoImageView setImageWithURL:bestImage.enclosureURL
                                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
                      {
                          if ( ! image) {
                              return;
                          }
                          self.retailerNameLabel.hidden = YES;
                          self.logoImageView.hidden = NO;
                      }];
                 }
             }];
        }
    }];

    
}

- (void)setRetailer:(id<CSRetailer>)newRetailer
{
    retailer = newRetailer;
    [self updateContent];
}

@end
