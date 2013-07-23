//
//  CSProductGridDataSource.m
//  SimplyShop
//
//  Created by Will Harris on 23/07/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductGridDataSource.h"
#import "CSProductWrapper.h"

@implementation CSProductGridDataSource


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.productListWrapper.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CSProductSummaryCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:@"CSProductSummaryPriceCell"
                                              forIndexPath:indexPath];
    
    if (cell.address != indexPath) {
        [self productSummaryCell:cell needsReloadWithAddress:indexPath];
    }
    
    return cell;
}

- (void)productSummaryCell:(CSProductSummaryCell *)cell
    needsReloadWithAddress:(NSObject *)address
{
    cell.priceContext = self.priceContext;
    [cell setLoadingAddress:address];
    [self.productListWrapper getProductWrapperAtIndex:((NSIndexPath *)address).row
                                             callback:^(CSProductWrapper *result,
                                                        NSError *error)
     {
         if (error) {
             [cell setError:error address:address];
             return;
         }
         
         [cell setWrapper:result address:address];
     }];
}

@end

