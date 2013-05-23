//
//  CSCategoriesCell.m
//  SimplyShop
//
//  Created by Will Harris on 23/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSCategoriesCell.h"
#import "CSCategoryCell.h"
#import <CSApi/CSAPI.h>

@interface CSCategoriesCell ()

- (void)initialize;
- (void)categoryCell:(CSCategoryCell *)cell
needsReloadWithAddress:(NSObject *)address;

@end

@implementation CSCategoriesCell

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
           forKeyPath:@"categories"
              options:NSKeyValueObservingOptionNew
              context:NULL];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"categories"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"categories"]) {
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
    return self.categories.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CSCategoryCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:@"CSCategoryCell"
                                              forIndexPath:indexPath];
    
    
    [self categoryCell:cell needsReloadWithAddress:indexPath];
    
    return cell;
}

- (void)categoryCell:(CSCategoryCell *)cell needsReloadWithAddress:(NSIndexPath *)address
{
    [cell setLoadingAddress:address];
    [self.categories getCategoryAtIndex:address.row
                               callback:^(id<CSCategory> result, NSError *error)
     {
         if (error) {
             // TODO: handle error properly
//             [cell setError:error address:address];
             return;
         }
         
         [cell setCategory:result address:address];
     }];
}


@end
