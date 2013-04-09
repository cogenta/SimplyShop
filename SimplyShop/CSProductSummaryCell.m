//
//  CSProductSummaryCell.m
//  SimplyShop
//
//  Created by Will Harris on 09/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductSummaryCell.h"
#import <CSApi/CSAPI.h>
#import <UIImageView+WebCache.h>
#import "CSTheme.h"

@interface CSProductSummaryCell ()

@property (strong, nonatomic) UIImageView *backgroundView;
@property (strong, nonatomic) NSObject *address;
@property (strong, nonatomic) id<CSProductSummary> productSummary;
@property (assign, nonatomic) SEL nameTransform;

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

- (void)initialize
{
    [self addSubview:[[[NSBundle mainBundle]
                       loadNibNamed:@"CSProductSummaryCell"
                       owner:self
                       options:nil]
                      objectAtIndex:0]];
    
    self.nameTransform = @selector(self);
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.selected = NO;
    self.productImageView.hidden = YES;
    [self.productImageView cancelCurrentImageLoad];
    
    self.productNameLabel.text = @"";
    
    self.productDescriptionLabel.text = @"";
    
    self.address = nil;
    self.productSummary = nil;
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
}

- (void)setLoadingAddress:(NSObject *)address
{
    if ([address isEqual:self.address]) {
        return;
    }
    
    self.productSummary = nil;
    self.address = address;
    [self updateContent];
}

- (void)setProductSummary:(id<CSProductSummary>)productSummary
                  address:(NSObject *)address
{
    if (self.productSummary) {
        // A product summary is already set.
        return;
    }
    
    if ( ! [address isEqual:self.address]) {
        // The view has been reused with another address.
        return;
    }
    
    self.productSummary = productSummary;
    [self updateContent];
}

- (NSString *)transformedName:(NSString *)name
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [name performSelector:self.nameTransform];
#pragma clang diagnostic pop
}

- (void)updateContent
{
    if ( ! self.productSummary) {
        self.productNameLabel.text = [self transformedName:@"Loading"];
        self.productDescriptionLabel.text = @"...";
        self.productImageView.hidden = YES;
        return;
    }
    
    self.productNameLabel.text = [self transformedName:self.productSummary.name];
    if (self.productSummary.description != (id) [NSNull null]) {
        self.productDescriptionLabel.text = self.productSummary.description;
    }
    
    [self.productSummary getPictures:^(id<CSPictureListPage> firstPage,
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
              if (error) {
                  // TODO: Handle error
                  return;
              };
              
              id<CSImageList> images = picture.imageList;
              
              __block id<CSImage> bestImage = nil;
              for (NSInteger i = 0 ; i < images.count; ++i) {
                  [images getImageAtIndex:i
                                 callback:^(id<CSImage> image, NSError *error)
                   {
                       if (error) {
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



@end
