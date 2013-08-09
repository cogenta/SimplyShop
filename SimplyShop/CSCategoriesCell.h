//
//  CSCategoriesCell.h
//  SimplyShop
//
//  Created by Will Harris on 23/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSDashboardRowCell.h"

@protocol CSNarrowList;
@protocol CSNarrow;
@protocol CSCategoriesCellDelegate;

@interface CSCategoriesCell : CSDashboardRowCell

@property (weak, nonatomic) IBOutlet id<CSCategoriesCellDelegate> delegate;

@property (nonatomic, retain) NSObject<CSNarrowList> *narrows;

@end

@protocol CSCategoriesCellDelegate <NSObject>

@optional

- (void)categoriesCell:(CSCategoriesCell *)cell
       didSelectNarrow:(id<CSNarrow>)narrow
               atIndex:(NSUInteger)index;

@end

