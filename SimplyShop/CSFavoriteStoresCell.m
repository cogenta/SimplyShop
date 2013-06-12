//
//  CSFavoriteStoresCell.m
//  SimplyShop
//
//  Created by Will Harris on 04/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSFavoriteStoresCell.h"
#import "CSRetailerSelectionCell.h"

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

- (NSInteger)retailerCount
{
    return [self.selectedRetailerURLs count];
}

- (id)addressForRetailerAtIndex:(NSInteger)index
{
    return self.selectedRetailerURLs[index];
}

- (void)getRetailerWithAddress:(id)address
                      callback:(void (^)(id<CSRetailer>, NSError *))callback
{
    NSURL *retailerURL = address;
    id<CSRetailer> retailer = [self.retailers objectForKey:retailerURL];
    if (retailer) {
        callback(retailer, nil);
        return;
    }
    
    [self.api getRetailer:retailerURL
                 callback:^(id<CSRetailer> retailer, NSError *error)
    {
        if (error) {
            callback(nil, error);
            [self.delegate favoriteStoresCell:self
                      failedToLoadRetailerURL:retailerURL
                                        error:error];
            return;
        }
        
        [self.retailers setObject:retailer forKey:retailerURL];
        callback(retailer, nil);
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
