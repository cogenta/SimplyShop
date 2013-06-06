//
//  CSFavoriteStoresCell.h
//  SimplyShop
//
//  Created by Will Harris on 04/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSDashboardRowCell.h"

@class CSAPI;
@class CSFavoriteStoresCell;
@protocol CSRetailer;

@protocol CSFavoriteStoresCellDelegate <NSObject>

- (void)favoriteStoresCell:(CSFavoriteStoresCell *)cell
   failedToLoadRetailerURL:(NSURL *)retailerURL
                     error:(NSError *)error;

- (void)favoriteStoresCell:(CSFavoriteStoresCell *)cell
         didSelectRetailer:(id<CSRetailer>)retailer
                     index:(NSUInteger)index;

- (void)favoriteStoresCellDidTapChooseButton:(CSFavoriteStoresCell *)cell;

@end

@interface CSFavoriteStoresCell : CSDashboardRowCell

@property (weak, nonatomic) IBOutlet id<CSFavoriteStoresCellDelegate> delegate;

@property (strong, nonatomic) CSAPI *api;
@property (strong, nonatomic) NSArray *selectedRetailerURLs;

- (IBAction)didTapChooseStores:(id)sender;

@end
