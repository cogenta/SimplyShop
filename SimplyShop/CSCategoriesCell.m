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

@property (strong, nonatomic) NSMutableDictionary *cache;

@end

@implementation CSCategoriesCell

- (void)initialize
{
    [super initialize];
    self.cache = [[NSMutableDictionary alloc] init];

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
        self.cache = [[NSMutableDictionary alloc] init];
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

- (void)fetchModelWithAddress:(id)address
                         done:(void (^)(id model, NSError *error))done
{
    id model = [self.cache objectForKey:address];
    if ( ! model) {
        [self fetchModelAtIndex:((NSIndexPath *)address).row done:^(id model, NSError *error) {
            if ( ! model) {
                done(model, error);
                return;
            }
            [self.cache setObject:model forKey:address];
            done(model, error);
        }];
    }
    
    done(model, nil);
}

- (NSInteger)modelCount
{
    return self.categories.count;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SEL sel = @selector(categoriesCell:didSelectCategory:atIndex:);
    if ( ! [self.delegate respondsToSelector:sel]) {
        return;
    }
    
    [self fetchModelWithAddress:[self addressForItemAtIndexPath:indexPath]
                           done:^(id<CSCategory> category, NSError *error)
    {
        if (error) {
            NSLog(@"Ignoring selection. Error getting category: %@", error);
            return;
        }
        [self.delegate categoriesCell:self
                    didSelectCategory:category
                              atIndex:indexPath.row];
    }];
    
}

@end
