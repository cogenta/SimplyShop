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

@property (strong, nonatomic) NSMutableDictionary *categoryCache;
@property (strong, nonatomic) NSMutableDictionary *narrowCache;

@end

@implementation CSCategoriesCell

- (void)initialize
{
    [super initialize];
    self.categoryCache = [[NSMutableDictionary alloc] init];
    self.narrowCache = [[NSMutableDictionary alloc] init];

    [self addObserver:self
           forKeyPath:@"narrows"
              options:NSKeyValueObservingOptionNew
              context:NULL];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"narrows"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"narrows"]) {
        self.categoryCache = [[NSMutableDictionary alloc] init];
        self.narrowCache = [[NSMutableDictionary alloc] init];
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

- (void)fetchNarrowAtIndex:(NSUInteger)index
                      done:(void (^)(id<CSNarrow>, NSError *))done
{
    id<CSNarrow> cachedNarrow = self.narrowCache[@(index)];
    if (cachedNarrow) {
        done(cachedNarrow, nil);
        return;
    }
    
    [self.narrows getNarrowAtIndex:index
                          callback:^(id<CSNarrow> narrow, NSError *error)
    {
        if (error) {
            done(nil, error);
            return;
        }
        
        if (narrow) {
            self.narrowCache[@(index)] = narrow;
        }
        
        done(narrow, nil);
    }];
}


- (void)fetchModelAtIndex:(NSUInteger)index
                     done:(void (^)(id, NSError *))done
{
    id cachedModel = self.categoryCache[@(index)];
    if (cachedModel) {
        done(cachedModel, nil);
        return;
    }
    
    [self fetchNarrowAtIndex:index done:^(id<CSNarrow> narrow, NSError *error)
    {
        if (error) {
            done(nil, error);
            return;
        }
        
        [narrow getNarrowsByCategory:^(id<CSCategory> result, NSError *error)
        {
            if (error) {
                done(nil, error);
                return;
            }
            
            if ( ! result) {
                NSString *msg = [NSString stringWithFormat:
                                 @"%s:%d: narrow %@ lacks a category",
                                 __FILE__, __LINE__, narrow];
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: msg};
                NSError *error = [NSError errorWithDomain:@"com.cogenta.SimplyShop.error"
                                                     code:0
                                                 userInfo:userInfo];
                done(nil, error);
                return;
            }
            
            self.categoryCache[@(index)] = result;
            
            done(result, nil);
        }];
    }];
}

- (void)fetchModelWithAddress:(id)address
                         done:(void (^)(id model, NSError *error))done
{
    if ( ! [address isKindOfClass:[NSIndexPath class]]) {
        NSString *msg = [NSString stringWithFormat:
                         @"%s:%d: Bad address %@",
                         __FILE__, __LINE__, address];
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: msg};
        NSError *error = [NSError errorWithDomain:@"com.cogenta.SimplyShop.error"
                                             code:0
                                         userInfo:userInfo];
        done(nil, error);
        return;
    }
    
    [self fetchModelAtIndex:((NSIndexPath *)address).row done:done];
}

- (NSInteger)modelCount
{
    return self.narrows.count;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SEL sel = @selector(categoriesCell:didSelectNarrow:atIndex:);
    if ( ! [self.delegate respondsToSelector:sel]) {
        return;
    }
    
    [self fetchNarrowAtIndex:indexPath.row
                        done:^(id<CSNarrow> narrow, NSError *error)
    {
        if (error) {
            NSLog(@"Ignoring selection. Error getting narrow: %@", error);
            return;
        }
        
        [self.delegate categoriesCell:self
                      didSelectNarrow:narrow
                              atIndex:indexPath.row];
    }];
}

@end
