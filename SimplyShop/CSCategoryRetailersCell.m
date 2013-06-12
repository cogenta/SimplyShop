//
//  CSCategoryRetailersCell.m
//  SimplyShop
//
//  Created by Will Harris on 12/06/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSCategoryRetailersCell.h"

@implementation CSCategoryRetailersCell

- (void)initialize
{
    [super initialize];
    
    [self addObserver:self
           forKeyPath:@"retailers"
              options:NSKeyValueObservingOptionNew
              context:NULL];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"retailers"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self && [keyPath isEqualToString:@"retailers"]) {
        [self reloadData];
    }
}

- (NSString *)cellNibName
{
    return @"CSCategoryRetailersCell";
}

- (NSInteger)retailerCount
{
    return self.retailers.count;
}

- (id)addressForRetailerAtIndex:(NSInteger)index
{
    return @(index);
}

- (void)getRetailerWithAddress:(id)address
                      callback:(void (^)(id<CSRetailer>, NSError *))callback
{
    [self.retailers getRetailerAtIndex:[address integerValue]
                              callback:callback];
}

- (BOOL)collectionView:(UICollectionView *)collectionView
shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.delegate != nil;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self.delegate categoryRetailersCell:self
                didSelectRetailerAtIndex:indexPath.row];
}

@end
