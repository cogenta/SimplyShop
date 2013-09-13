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

@protocol CSRefineSelectionViewControllerDelegate <NSObject>

@property (readonly) id<CSNarrow> selectedNarrow;

- (void)getNarrows:(void (^)(id<CSNarrowList> narrows, NSError *error))callback;
- (void)didSelectNarrowAtIndex:(NSUInteger)index;

@end

@interface CSRefineSelectionViewController : UITableViewController

@property (weak, nonatomic)
id<CSRefineSelectionViewControllerDelegate> selectionDelegate;

@end
