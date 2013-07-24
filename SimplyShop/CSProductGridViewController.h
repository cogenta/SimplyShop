//
//  CSProductGridViewController.h
//  SimplyShop
//
//  Created by Will Harris on 08/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSProductSummaryList;
@protocol CSProductList;
@protocol CSRetailer;
@protocol CSLikeList;
@protocol CSGroup;
@protocol CSCategory;

@class CSPlaceholderView;
@class CSPriceContext;
@class CSProductGridDataSource;

@interface CSProductGridViewController : UIViewController
<UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet CSPlaceholderView *placeholderView;
@property (strong, nonatomic) IBOutlet CSProductGridDataSource *dataSource;

- (void)setRetailer:(id<CSRetailer>)retailer
              likes:(id<CSLikeList>)likes
              query:(NSString *)query;
- (void)setGroup:(id<CSGroup>)group
           likes:(id<CSLikeList>)likes
           query:(NSString *)query;
- (void)setCategory:(id<CSCategory>)category
              likes:(id<CSLikeList>)likes
              query:(NSString *)query;
- (void)setProductSummaries:(id<CSProductSummaryList>)products;
- (void)setProducts:(id<CSProductList>)products;

@property (strong, nonatomic) CSPriceContext *priceContext;

- (IBAction)doneShowProduct:(UIStoryboardSegue *)segue;

@end
