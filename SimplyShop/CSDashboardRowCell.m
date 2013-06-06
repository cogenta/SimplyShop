//
//  CSDashboardRowCell.m
//  SimplyShop
//
//  Created by Will Harris on 05/06/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSDashboardRowCell.h"
#import "CSAddressCell.h"

@implementation CSDashboardRowCell

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
    UIView *subview = [[[NSBundle mainBundle]
                        loadNibNamed:[self cellNibName]
                        owner:self
                        options:nil]
                       objectAtIndex:0];
    self.frame = subview.frame;
    [self addSubview:subview];
    [self registerClasses];
}

- (void)registerClasses
{
    [self.collectionView registerClass:[self itemCellClass]
            forCellWithReuseIdentifier:@"CSDashboardRowItemCell"];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return [self modelCount];
}

- (id)addressForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell<CSAddressCell> *cell =
    [self collectionView:collectionView
        rowCellForItemAtIndexPath:indexPath];
    
    [self  collectionView:collectionView
                  rowCell:cell
   needsReloadWithAddress:[self addressForItemAtIndexPath:indexPath]];
    
    return cell;
}

- (UICollectionViewCell<CSAddressCell> *)collectionView:(UICollectionView *)collectionView
               rowCellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"CSDashboardRowItemCell"
                                                     forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView
               rowCell:(UICollectionViewCell<CSAddressCell> *)cell
needsReloadWithAddress:(NSObject *)address
{
    [cell setLoadingAddress:address];
    [self fetchModelWithAddress:address done:^(id result, NSError *error) {
        if (error) {
            [cell setError:error address:address];
            return;
        }
        
        [cell setModel:result address:address];
    }];
}

- (void)fetchModelWithAddress:(id)address
                         done:(void (^)(id model, NSError *error))done
{
    [self fetchModelAtIndex:((NSIndexPath *)address).row done:done];
}

- (void)reloadData
{
    [self.collectionView reloadData];
}

- (NSString *)cellNibName
{
    return @"CSCategoriesCell";
}

- (Class)itemCellClass
{
    return [UITableViewCell class];
}

- (NSInteger)modelCount
{
    return 0;
}

- (void)fetchModelAtIndex:(NSUInteger)index
                 done:(void (^)(id model, NSError *error))done
{
    done(nil, nil);
}

@end
