//
//  CSProductSummariesCell.h
//  SimplyShop
//
//  Created by Will Harris on 08/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SwipeView/SwipeView.h>

@protocol CSProductSummaryList;

@interface CSProductSummariesCell : UITableViewCell <SwipeViewDataSource>

@property (strong, nonatomic) NSObject<CSProductSummaryList> *productSummaries;

@property (weak, nonatomic) IBOutlet SwipeView *swipeView;

@end
