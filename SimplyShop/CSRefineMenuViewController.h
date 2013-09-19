//
//  CSRefineMenuViewController.h
//  SimplyShop
//
//  Created by Will Harris on 19/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSSlice;
@protocol CSNarrow;
@class CSRefineMenuViewController;

@protocol CSRefineMenuViewControllerDelegate <NSObject>

- (void)refineMenuViewController:(CSRefineMenuViewController *)controller
                 didSelectNarrow:(id<CSNarrow>)refine;

@end

@interface CSRefineMenuViewController : UITableViewController

@property (strong, nonatomic) id<CSSlice> slice;
@property (weak, nonatomic) id<CSRefineMenuViewControllerDelegate> menuDelegate;

@end
