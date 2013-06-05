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
    
    UIView *subview = [[[NSBundle mainBundle]
                        loadNibNamed:@"CSCategoriesCell"
                        owner:self
                        options:nil]
                       objectAtIndex:0];
    self.frame = subview.frame;
    [self addSubview:subview];
    
    [self.collectionView registerClass:[CSCategoryCell class]
            forCellWithReuseIdentifier:@"CSCategoryCell"];
    
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  rowCellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"CSCategoryCell"
                                                     forIndexPath:indexPath];
    
}

- (void)reloadRowCell:(id<CSAddressCell>)cell withAddress:(NSObject *)address done:(void (^)(id, NSError *))done
{
    [self.categories getCategoryAtIndex:((NSIndexPath *)address).row
                               callback:done];
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
