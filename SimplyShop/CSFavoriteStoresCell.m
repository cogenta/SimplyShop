//
//  CSFavoriteStoresCell.m
//  SimplyShop
//
//  Created by Will Harris on 04/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSFavoriteStoresCell.h"
#import "CSRetailerView.h"
#import <CSApi/CSAPI.h>
#import <SwipeView/SwipeView.h>

@interface CSFavoriteStoresCell ()

- (void)initialize;

@end

@implementation CSFavoriteStoresCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.retailersSwipeView.truncateFinalPage = YES;
    self.retailersSwipeView.pagingEnabled = NO;
    
    [self addObserver:self
           forKeyPath:@"selectedRetailerURLs"
              options:NSKeyValueObservingOptionNew
              context:NULL];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"selectedRetailerURLs"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"selectedRetailerURLs"]) {
        [self.retailersSwipeView reloadData];
        return;
    }
}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return [self.selectedRetailerURLs count];
}


- (UIView *)swipeView:(SwipeView *)swipeView
   viewForItemAtIndex:(NSInteger)index
          reusingView:(UIView *)view
{
    CSRetailerView *retailerView = nil;
    if (view) {
        retailerView = (CSRetailerView *)view;
    }
    
    if ( ! retailerView) {
        retailerView = [[[NSBundle mainBundle]
                         loadNibNamed:@"CSRetailerView"
                         owner:nil
                         options:nil]
                        objectAtIndex:0];
    }
    
    NSURL *retailerURL = [self.selectedRetailerURLs objectAtIndex:index];
    [retailerView setLoadingURL:retailerURL];
    [self.api getRetailer:retailerURL
                 callback:^(id<CSRetailer> retailer, NSError *error)
     {
         if (error) {
             // TODO: handle error
             return;
         }
         
         [retailerView setRetailer:retailer URL:retailerURL];
     }];
    return retailerView;
}

@end
