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

@class CSPriceContext;

@interface CSProductGridViewController : UIViewController
<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (void)setRetailer:(id<CSRetailer>)retailer likes:(id<CSLikeList>)likes;
- (void)setGroup:(id<CSGroup>)group likes:(id<CSLikeList>)likes;
- (void)setCategory:(id<CSCategory>)category likes:(id<CSLikeList>)likes;
- (void)setProductSummaries:(id<CSProductSummaryList>)products;
- (void)setProducts:(id<CSProductList>)products;
- (void)setErrorState;
- (void)setLoadingState;

@property (strong, nonatomic) CSPriceContext *priceContext;

- (IBAction)doneShowProduct:(UIStoryboardSegue *)segue;

@end
