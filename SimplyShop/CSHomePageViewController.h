//
//  CSHomePageViewController.h
//  SimplyShop
//
//  Created by Will Harris on 03/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSAPI;
@class CSPlaceholderView;
@class CSProductGridDataSource;
@protocol CSSlice;
@protocol CSCategory;
@protocol CSRetailer;

@interface CSHomePageViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UICollectionView *gridView;
@property (weak, nonatomic) IBOutlet CSPlaceholderView *placeholderView;
@property (weak, nonatomic) IBOutlet CSProductGridDataSource *gridDataSource;

@property (strong, nonatomic) CSAPI *api;
@property (strong, nonatomic) id<CSSlice> slice;

- (IBAction)doneInitialRetailerSelection:(UIStoryboardSegue *)segue;
- (IBAction)doneChangeRetailerSelection:(UIStoryboardSegue *)segue;
- (IBAction)doneShowProduct:(UIStoryboardSegue *)segue;
- (IBAction)doneShowProductsGrid:(UIStoryboardSegue *)segue;

@end
