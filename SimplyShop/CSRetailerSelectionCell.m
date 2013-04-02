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

@interface CSRetailerSelectionCell ()

@property (nonatomic, weak) NSObject<CSRetailerList> *retailerList;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSObject<CSRetailer> *retailer;

- (void)gotRetailer:(NSObject<CSRetailer> *)retailer
           fromList:(NSObject<CSRetailerList> *)list
              index:(NSInteger)index;
- (void)initialize;
- (void)updateContent;

@end

@implementation CSRetailerSelectionCell

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
    self.index = NSNotFound;
    self.retailerList = nil;
    self.retailer = nil;
    self.selected = NO;
    self.retailerNameLabel.hidden = NO;
    self.logoImageView.hidden = YES;
    [self.logoImageView cancelCurrentImageLoad];
    self.logoImageView.image = nil;
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

- (void)setRetailerList:(NSObject<CSRetailerList> *)list
                  index:(NSInteger)newIndex
{
    self.retailerList = list;
    self.index = newIndex;
    
    [self.retailerList getRetailerAtIndex:newIndex
                                 callback:^(id<CSRetailer> retailer,
                                            NSError *error)
    {
        if (error) {
            // TODO: report error to parent view controller
            return;
        }
        
        [self gotRetailer:retailer fromList:list index:newIndex];
    }];
}


- (void)gotRetailer:(NSObject<CSRetailer> *)retailer
           fromList:(NSObject<CSRetailerList> *)list
              index:(NSInteger)index
{
    if (index != self.index || list != self.retailerList) {
        // We ignore the retailer data because the cell has been reused for a
        // different index or list.
        return;
    }
    
    self.retailer = retailer;
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
                    
                    if (image.width >= bestImage.width) {
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
