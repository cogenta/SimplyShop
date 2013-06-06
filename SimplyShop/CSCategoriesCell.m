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

@implementation CSCategoriesCell

- (void)initialize
{
    [super initialize];

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
        [self reloadData];
        return;
    }
}

- (NSString *)cellNibName
{
    return @"CSCategoriesCell";
}

- (Class)itemCellClass
{
    return [CSCategoryCell class];
}


- (void)fetchModelAtIndex:(NSUInteger)index
                     done:(void (^)(id, NSError *))done
{
    [self.categories getCategoryAtIndex:index callback:done];
}

- (NSInteger)modelCount
{
    return self.categories.count;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SEL sel = @selector(categoriesCell:didSelectItemAtIndex:);
    if ( ! [self.delegate respondsToSelector:sel]) {
        return;
    }
    
    [self.delegate categoriesCell:self didSelectItemAtIndex:indexPath.row];
}

@end
