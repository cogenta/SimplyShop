//
//  CSRefineSelectionViewController.h
//  SimplyShop
//
//  Created by Will Harris on 13/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSNarrow;
@protocol CSNarrowList;
@class CSRefineType;

@protocol CSRefineSelectionViewControllerDelegate <NSObject>

- (void)getNarrows:(void (^)(id<CSNarrowList> narrows, NSError *error))callback;
- (void)didSelectNarrowAtIndex:(NSUInteger)index;

@end

@interface CSRefineSelectionViewController : UITableViewController

@property (strong, nonatomic)
id<CSRefineSelectionViewControllerDelegate> selectionDelegate;
@property (strong, nonatomic) CSRefineType *type;

@end
