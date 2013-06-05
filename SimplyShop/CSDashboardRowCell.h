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
- (void)reloadRowCell:(id<CSAddressCell>)cell withAddress:(NSObject *)address done:(void (^)(id result, NSError *error))done;
- (NSInteger)modelCount;
- (void)rowCell:(id<CSAddressCell>)cell needsReloadWithAddress:(NSObject *)address;
- (UICollectionViewCell<CSAddressCell> *)
collectionView:(UICollectionView *)collectionView
rowCellForItemAtIndexPath:(NSIndexPath *)indexPath;


@end
