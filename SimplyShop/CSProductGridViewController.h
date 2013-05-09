//
//  CSProductGridViewController.h
//  SimplyShop
//
//  Created by Will Harris on 08/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSProductSummaryList;
@class CSPriceContext;

@interface CSProductGridViewController : UIViewController
<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) id<CSProductSummaryList> productSummaries;
@property (strong, nonatomic) CSPriceContext *priceContext;

- (IBAction)doneShowProduct:(UIStoryboardSegue *)segue;

@end
