//
//  CSFavoriteStoresCell.h
//  SimplyShop
//
//  Created by Will Harris on 04/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSAPI;
@class CSFavoriteStoresCell;

@protocol CSFavoriteStoresCellDelegate <NSObject>

- (void)favoriteStoresCell:(CSFavoriteStoresCell *)cell
   failedToLoadRetailerURL:(NSURL *)retailerURL
                     error:(NSError *)error;

@end

@interface CSFavoriteStoresCell : UITableViewCell
<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet id<CSFavoriteStoresCellDelegate> delegate;

@property (strong, nonatomic) CSAPI *api;
@property (strong, nonatomic) NSArray *selectedRetailerURLs;

@end
