//
//  CSProductSummariesCell.m
//  SimplyShop
//
//  Created by Will Harris on 08/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductSummariesCell.h"
#import "CSProductSummaryCell.h"
#import <CSApi/CSAPI.h>

@interface CSProductSummariesCell () <CSProductSummaryCellDelegate>

@end

@implementation CSProductSummariesCell

- (void)initialize
{
    [super initialize];
    
    [self addObserver:self
           forKeyPath:@"products"
              options:NSKeyValueObservingOptionNew
              context:NULL];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"products"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"products"]) {
        self.seeAllButton.enabled = [object products] != nil;
        [self.collectionView reloadData];
        return;
    }
}

- (NSString *)cellNibName
{
    return @"CSProductSummariesCell";
}

- (Class)itemCellClass
{
    return [CSProductSummaryCell class];
}

- (NSInteger)modelCount
{
    return self.products.count;
}

- (void)fetchModelWithAddress:(id)address done:(void (^)(id, NSError *))done
{
    [self.products getProductAtIndex:((NSIndexPath *)address).row
                            callback:done];
}

- (UICollectionViewCell<CSAddressCell> *)collectionView:(UICollectionView *)collectionView
                              rowCellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CSProductSummaryCell *cell = (id)[super collectionView:collectionView
                                 rowCellForItemAtIndexPath:indexPath];
    cell.delegate = self;
    return cell;
}

- (void)productSummaryCell:(CSProductSummaryCell *)cell needsReloadWithAddress:(NSObject *)address
{
    [self rowCellNeedsReload:cell withAddress:address];
}

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SEL sel = @selector(productSummariesCell:didSelectItemAtIndex:);
    if ( ! [self.delegate respondsToSelector:sel]) {
        return;
    }
    
    [self.delegate productSummariesCell:self
                   didSelectItemAtIndex:indexPath.row];
}

- (void)didTapSeeAllButton:(id)sender
{
    SEL sel = @selector(productSummariesCellDidTapSeeAllButton:);
    if ( ! [self.delegate respondsToSelector:sel]) {
        return;
    }
    
    [self.delegate productSummariesCellDidTapSeeAllButton:self];
}

@end
