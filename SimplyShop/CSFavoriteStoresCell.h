//
//  CSFavoriteStoresCell.h
//  SimplyShop
//
//  Created by Will Harris on 04/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SwipeView/SwipeView.h>

@class CSAPI;

@interface CSFavoriteStoresCell : UITableViewCell <SwipeViewDataSource>

@property (strong, nonatomic) CSAPI *api;
@property (strong, nonatomic) NSArray *selectedRetailerURLs;

@property (weak, nonatomic) IBOutlet SwipeView *swipeView;

@end
