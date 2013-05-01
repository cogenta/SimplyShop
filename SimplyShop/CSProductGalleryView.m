//
//  CSProductGalleryView.m
//  SimplyShop
//
//  Created by Will Harris on 01/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductGalleryView.h"
#import <CSApi/CSAPI.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface CSProductGalleryView ()

@property (nonatomic, strong) UIView *subview;

- (void)initialize;

@end

@implementation CSProductGalleryView

@synthesize pictures;

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
    self.subview = [[[NSBundle mainBundle]
                     loadNibNamed:@"CSProductGalleryView"
                     owner:self
                     options:nil]
                    objectAtIndex:0];
    [self addSubview:self.subview];
    [self layoutSubviews];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImageView.image = backgroundImage;
}

- (UIImage *)backgroundImage
{
    return _backgroundImageView.image;
}

- (void)setFooterBackgroundImage:(UIImage *)footerBackgroundImage
{
    _footerImageView.image = footerBackgroundImage;
}

- (UIImage *)footerBackgroundImage
{
    return _footerImageView.image;
}

- (void)setPictures:(id<CSPictureList>)newPictures
{
    pictures = newPictures;
    
    [pictures getPictureAtIndex:0
                       callback:^(id<CSPicture> picture,
                                  NSError *error)
     {
         if (error) {
             /// Ignore picture error.
             return;
         };
         
         id<CSImageList> images = picture.imageList;
         
         __block id<CSImage> bestImage = nil;
         for (NSInteger i = 0 ; i < images.count; ++i) {
             [images getImageAtIndex:i
                            callback:^(id<CSImage> image, NSError *error)
              {
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
}

- (id<CSPictureList>)pictures
{
    return pictures;
}

@end
