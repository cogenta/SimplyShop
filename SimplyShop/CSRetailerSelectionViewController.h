//
//  CSRetailerSelectionViewController.h
//  SimplyShop
//
//  Created by Will Harris on 28/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSRetailerList;

@interface CSRetailerSelectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSObject<CSRetailerList> *retailerList;
@property (nonatomic, weak)  IBOutlet UICollectionView *collectionView;

@end
