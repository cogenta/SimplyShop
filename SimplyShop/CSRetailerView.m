//
//  CSRetailerView.m
//  SimplyShop
//
//  Created by Will Harris on 03/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRetailerView.h"
#import <CSApi/CSAPI.h>
#import <UIImageView+WebCache.h>
#import "CSTheme.h"

@interface CSRetailerView ()

@property (strong, nonatomic) UIImageView *backgroundView;
@property (strong, nonatomic) NSURL *URL;
@property (strong, nonatomic) id<CSRetailer> retailer;

- (void)updateContent;
- (void)initialize;

@end

@implementation CSRetailerView

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

- (void)initialize
{
    [self addObserver:self
           forKeyPath:@"retailer"
              options:NSKeyValueObservingOptionNew
              context:NULL];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"retailer"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"retailer"]) {
        [self updateContent];
        return;
    }
}

- (void)setTheme:(id<CSTheme>)newTheme
{
    theme = newTheme;
    UIImage *backgroundImage = [theme collectionViewCellBackgroundImage];
    
    if ( ! self.backgroundView) {
        self.backgroundView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView insertSubview:self.backgroundView atIndex:0];
    }
    
    [self.backgroundView setImage:backgroundImage];
}

- (void)setLoadingURL:(NSURL *)URL
{
    self.retailer = nil;
    self.URL = URL;
}

- (void)setRetailer:(id<CSRetailer>)retailer URL:(NSURL *)URL
{
    if ( ! [URL isEqual:self.URL]) {
        // The view has been reused with another URL.
        return;
    }
    
    self.retailer = retailer;
}

- (void)updateContent
{
    if ( ! self.retailer) {
        self.retailerNameLabel.text = @"...";
        self.retailerNameLabel.hidden = NO;
        self.logoImageView.hidden = YES;
        return;
    }

    self.retailerNameLabel.text = self.retailer.name;
    
    [self.retailer getLogo:^(id<CSPicture> picture, NSError *error) {
        if (error) {
            // TODO: Handle error
            return;
        }
        
        id<CSImageList> images = picture.imageList;
        
        __block id<CSImage> bestImage = nil;
        for (NSInteger i = 0 ; i < images.count; ++i) {
            [images getImageAtIndex:i
                           callback:^(id<CSImage> image, NSError *error)
             {
                 if (error) {
                     return;
                 }
                 
                 if ([image.width doubleValue] > [bestImage.width doubleValue]) {
                     bestImage = image;
                 }
                 
                 if (i == images.count - 1 && bestImage) {
                     [self.logoImageView setImageWithURL:bestImage.enclosureURL
                                               completed:^(UIImage *image,
                                                           NSError *error,
                                                           SDImageCacheType cacheType)
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

@end