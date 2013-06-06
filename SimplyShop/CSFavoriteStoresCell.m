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

@end

@implementation CSFavoriteStoresCell

- (void)initialize
{
    [super initialize];
    
    self.retailers = [NSMutableDictionary dictionary];
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
        [self reloadData];
        return;
    }
}

- (NSString *)cellNibName
{
    return @"CSFavoriteStoresCell";
}

- (Class)itemCellClass
{
    return [CSRetailerSelectionCell class];
}

- (NSInteger)modelCount
{
    return [self.selectedRetailerURLs count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (id)addressForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *retailerURL = [self.selectedRetailerURLs objectAtIndex:indexPath.row];
    return retailerURL;
}

- (void)fetchModelWithAddress:(id)address
                         done:(void (^)(id, NSError *))done
{
    NSURL *retailerURL = address;
    id<CSRetailer> retailer = [self.retailers objectForKey:retailerURL];
    if (retailer) {
        done(retailer, nil);
        return;
    }
    
    [self.api getRetailer:retailerURL
                 callback:^(id<CSRetailer> retailer, NSError *error)
     {
         if (error) {
             done(nil, error);
             [self.delegate favoriteStoresCell:self
                       failedToLoadRetailerURL:retailerURL
                                         error:error];
             return;
         }
         
         [self.retailers setObject:retailer forKey:retailerURL];
         done(retailer, nil);
     }];
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

- (IBAction)didTapChooseStores:(id)sender {
    [self.delegate favoriteStoresCellDidTapChooseButton:self];
}

@end
