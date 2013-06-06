//
//  CSDashboardRowCell.h
//  SimplyShop
//
//  Created by Will Harris on 05/06/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSAddressCell;

@interface CSDashboardRowCell : UITableViewCell
<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
- (void)initialize;
- (void)collectionView:(UICollectionView *)collectionView
         reloadRowCell:(id<CSAddressCell>)cell
           withAddress:(NSObject *)address
                  done:(void (^)(id result, NSError *error))done;
- (void)collectionView:(UICollectionView *)collectionView
               rowCell:(id<CSAddressCell>)cell
needsReloadWithAddress:(NSObject *)address;
- (UICollectionViewCell<CSAddressCell> *)
collectionView:(UICollectionView *)collectionView
rowCellForItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)registerClasses;

- (void)reloadData;

- (NSString *)cellNibName;
- (Class)itemCellClass;

- (NSInteger)modelCount;
- (void)fetchModelAtIndex:(NSUInteger)index
                     done:(void (^)(id model, NSError *error))done;

@end
