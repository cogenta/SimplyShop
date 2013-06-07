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

@interface CSHomePageViewController : UITableViewController

@property (strong, nonatomic) CSAPI *api;
@property (strong, nonatomic) id<CSCategory> category;

- (IBAction)doneInitialRetailerSelection:(UIStoryboardSegue *)segue;
- (IBAction)doneChangeRetailerSelection:(UIStoryboardSegue *)segue;
- (IBAction)doneShowProduct:(UIStoryboardSegue *)segue;
- (IBAction)doneShowProductsGrid:(UIStoryboardSegue *)segue;

@end
