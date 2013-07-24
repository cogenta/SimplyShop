//
//  CSHomePageViewController.h
//  SimplyShop
//
//  Created by Will Harris on 03/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSAPI;
@protocol CSCategory;
@protocol CSRetailer;

@interface CSHomePageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *gridView;

@property (strong, nonatomic) CSAPI *api;
@property (strong, nonatomic) id<CSCategory> category;
@property (strong, nonatomic) id<CSRetailer> retailer;

- (IBAction)doneInitialRetailerSelection:(UIStoryboardSegue *)segue;
- (IBAction)doneChangeRetailerSelection:(UIStoryboardSegue *)segue;
- (IBAction)doneShowProduct:(UIStoryboardSegue *)segue;
- (IBAction)doneShowProductsGrid:(UIStoryboardSegue *)segue;

@end
