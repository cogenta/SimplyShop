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

@interface CSRetailerSelectionCell ()

@property (nonatomic, weak) NSObject<CSRetailerList> *retailerList;
@property (nonatomic, weak) NSSet *selectedURLs;
@property (nonatomic, assign) NSInteger index;
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
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.layer.shouldRasterize = YES;
    self.index = NSNotFound;
    [self updateContent];
    [self addObserver:self
           forKeyPath:@"retailer"
              options:NSKeyValueObservingOptionNew
              context:NULL];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"retailer"];
}

- (void)setIsReady:(BOOL)newIsReady
{
    if (newIsReady != isReady) {
        [self willChangeValueForKey:@"isReady"];
        isReady = newIsReady;
        [self didChangeValueForKey:@"isReady"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"retailer"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateContent];
        });
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.index = NSNotFound;
    self.retailerList = nil;
    self.retailer = nil;
    self.selectedURLs = nil;
    self.selected = NO;
    self.retailerNameLabel.hidden = NO;
    self.logoImageView.hidden = YES;
    [self.logoImageView cancelCurrentImageLoad];
    self.logoImageView.image = nil;
    self.isReady = NO;
    [self updateContent];
}

- (void)setTheme:(id<CSTheme>)newTheme
{
    theme = newTheme;
    UIImage *backgroundImage = [theme collectionViewCellBackgroundImage];
    UIImage *selectedBackgroundImage = [theme collectionViewCellSelectedBackgroundImage];
    self.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:selectedBackgroundImage];
}

- (void)setLoadingRetailerForIndex:(NSInteger)index
{
    self.retailer = nil;
    self.index = index;
    self.isReady = NO;
    [self updateContent];
}

- (void)setRetailer:(NSObject<CSRetailer> *)retailer
              index:(NSInteger)index
{
    if (index != self.index) {
        // We ignore the retailer data because the cell has been reused for a
        // different index or list.
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
    } else {
        self.retailerNameLabel.text = @"...";
    }
}

@end
