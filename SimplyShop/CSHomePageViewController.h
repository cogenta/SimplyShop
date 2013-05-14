//
//  CSHomePageViewController.h
//  SimplyShop
//
//  Created by Will Harris on 03/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSUser;
@class CSAPI;
@class CSProductSummariesCell;
@class CSFavoriteStoresCell;

@interface CSHomePageViewController : UITableViewController

@property (strong, nonatomic) CSAPI *api;

@property (weak, nonatomic) IBOutlet CSProductSummariesCell *topProductsCell;
@property (weak, nonatomic) IBOutlet CSFavoriteStoresCell *favoriteStoresCell;

- (IBAction)doneInitialRetailerSelection:(UIStoryboardSegue *)segue;
- (IBAction)doneChangeRetailerSelection:(UIStoryboardSegue *)segue;
- (IBAction)doneShowProduct:(UIStoryboardSegue *)segue;
- (IBAction)doneShowProductsGrid:(UIStoryboardSegue *)segue;

@end
