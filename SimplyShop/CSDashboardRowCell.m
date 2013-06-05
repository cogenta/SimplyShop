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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell<CSAddressCell> *cell =
    [self collectionView:collectionView rowCellForItemAtIndexPath:indexPath];
    
    [self rowCell:cell needsReloadWithAddress:indexPath];
    
    return cell;
}

- (UICollectionViewCell<CSAddressCell> *)
collectionView:(UICollectionView *)collectionView
rowCellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)rowCell:(id<CSAddressCell>)cell needsReloadWithAddress:(NSObject *)address
{
    [cell setLoadingAddress:address];
    [self reloadRowCell:cell withAddress:address done:^(id result, NSError *error) {
        if (error) {
            [cell setError:error address:address];
            return;
        }
        
        [cell setModel:result address:address];
    }];
}

- (NSInteger)modelCount
{
    return 0;
}

- (void)reloadRowCell:(id<CSAddressCell>)cell withAddress:(NSObject *)address done:(void (^)(id model, NSError *error))done
{
    done(nil, [NSError errorWithDomain:@"not implemented" code:0 userInfo:nil]);
}

@end
