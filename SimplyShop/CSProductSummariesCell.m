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

- (void)initialize;

@end

@implementation CSProductSummariesCell

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
    [self addObserver:self
           forKeyPath:@"productSummaries"
              options:NSKeyValueObservingOptionNew
              context:NULL];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"productSummaries"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"productSummaries"]) {
        [self.collectionView reloadData];
        return;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.productSummaries.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CSProductSummaryCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:@"CSProductSummaryCell"
                                              forIndexPath:indexPath];
    
    
    [self productSummaryCell:cell needsReloadWithAddress:indexPath];
    
    return cell;
}

- (void)productSummaryCell:(CSProductSummaryCell *)cell needsReloadWithAddress:(NSObject *)address
{
    [cell setLoadingAddress:address];
    [self.productSummaries getProductSummaryAtIndex:((NSIndexPath *)address).row
                                           callback:^(id<CSProductSummary> result,
                                                      NSError *error)
     {
         if (error) {
             [cell setError:error address:address];
             return;
         }
         
         [cell setProductSummary:result address:address];
     }];
}

@end
