//
//  CSFavoriteStoresCell.m
//  SimplyShop
//
//  Created by Will Harris on 04/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSFavoriteStoresCell.h"
#import "CSRetailerSelectionCell.h"
#import <CSApi/CSAPI.h>

@interface CSFavoriteStoresCell ()

@property (strong, nonatomic) NSMutableDictionary *retailers;
- (void)initialize;

@end

@implementation CSFavoriteStoresCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
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

- (void)awakeFromNib
{
    [self initialize];
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
    self.retailers = [NSMutableDictionary dictionary];
    [self addObserver:self
           forKeyPath:@"selectedRetailerURLs"
              options:NSKeyValueObservingOptionNew
              context:NULL];
    self.collectionView.alwaysBounceHorizontal = YES;
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
        [self.collectionView reloadData];
        return;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.selectedRetailerURLs count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CSRetailerSelectionCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:@"CSRetailerSelectionCell"
                                              forIndexPath:indexPath];
    
    NSURL *retailerURL = [self.selectedRetailerURLs objectAtIndex:indexPath.row];
    
    id<CSRetailer> retailer = [self.retailers objectForKey:retailerURL];
    [cell setLoadingAddress:retailerURL];
    if (retailer) {
        [cell setRetailer:retailer address:retailerURL];
    } else {
        [self.api getRetailer:retailerURL
                     callback:^(id<CSRetailer> retailer, NSError *error)
         {
             if (error) {
                 [self.delegate favoriteStoresCell:self
                           failedToLoadRetailerURL:retailerURL
                                             error:error];
                 return;
             }
             
             [self.retailers setObject:retailer forKey:retailerURL];
             [cell setRetailer:retailer address:retailerURL];
         }];
    }
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView
shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *URL = [self.selectedRetailerURLs objectAtIndex:indexPath.row];
    return URL && [self.retailers objectForKey:URL];
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    SEL sel = @selector(favoriteStoresCell:didSelectRetailer:index:);
    if ( ! [self.delegate respondsToSelector:sel]) {
        return;
    }
    
    NSURL *URL = [self.selectedRetailerURLs objectAtIndex:indexPath.row];
    id<CSRetailer> retailer = [self.retailers objectForKey:URL];

    [self.delegate favoriteStoresCell:self
                    didSelectRetailer:retailer
                                index:indexPath.row];
}

@end
