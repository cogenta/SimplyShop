//
//  CSProductSummariesCell.m
//  SimplyShop
//
//  Created by Will Harris on 08/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductSummariesCell.h"
#import "CSProductSummaryCell.h"
#import "CSProductWrapper.h"
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
    [self addSubview:[[[NSBundle mainBundle]
                       loadNibNamed:@"CSProductSummariesCell"
                       owner:self
                       options:nil]
                      objectAtIndex:0]];
    
    [self.collectionView registerClass:[CSProductSummaryCell class]
            forCellWithReuseIdentifier:@"CSProductSummaryCell"];
    
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
        self.seeAllButton.enabled = [object productSummaries] != nil;
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
         
         [cell setWrapper:[CSProductWrapper wrapperForSummary:result]
                  address:address];
     }];
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
