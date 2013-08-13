//
//  CSProductGridViewController.h
//  SimplyShop
//
//  Created by Will Harris on 08/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSProductList;
@protocol CSProductSearchState;

@class CSPlaceholderView;
@class CSProductGridDataSource;

@interface CSProductGridViewController : UIViewController
<UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet CSPlaceholderView *placeholderView;
@property (strong, nonatomic) IBOutlet CSProductGridDataSource *dataSource;

- (void)setProducts:(id<CSProductList>)products;

@property (strong, nonatomic) id<CSProductSearchState> searchState;

- (IBAction)doneShowProduct:(UIStoryboardSegue *)segue;

@end
