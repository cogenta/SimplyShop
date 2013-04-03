//
//  CSHomePageViewController.h
//  SimplyShop
//
//  Created by Will Harris on 03/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SwipeView/SwipeView.h>

@protocol CSUser;
@class CSAPI;

@interface CSHomePageViewController : UITableViewController <SwipeViewDataSource>

@property (weak, nonatomic) IBOutlet SwipeView *retailersSwipeView;
@property (strong, nonatomic) CSAPI *api;

- (IBAction)doneInitialRetailerSelection:(UIStoryboardSegue *)segue;

@end
