//
//  CSCategoriesCell.h
//  SimplyShop
//
//  Created by Will Harris on 23/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSDashboardRowCell.h"

@protocol CSCategory;
@protocol CSCategoryList;
@protocol CSCategoriesCellDelegate;

@interface CSCategoriesCell : CSDashboardRowCell

@property (weak, nonatomic) IBOutlet id<CSCategoriesCellDelegate> delegate;

@property (nonatomic, retain) NSObject<CSCategoryList> *categories;

@end

@protocol CSCategoriesCellDelegate <NSObject>

@optional

- (void)categoriesCell:(CSCategoriesCell *)cell
     didSelectCategory:(id<CSCategory>)category
               atIndex:(NSUInteger)index;

@end

