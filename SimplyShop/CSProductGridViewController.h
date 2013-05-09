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
@class CSPriceContext;

@interface CSProductGridViewController : UIViewController
<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (void)setProductSummaries:(id<CSProductSummaryList>)products;
- (void)setProducts:(id<CSProductList>)products;

@property (strong, nonatomic) CSPriceContext *priceContext;

- (IBAction)doneShowProduct:(UIStoryboardSegue *)segue;

@end
