//
//  CSCategoryRetailersCell.h
//  SimplyShop
//
//  Created by Will Harris on 12/06/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRetailersCell.h"

@protocol CSRetailerList;
@class CSCategoryRetailersCell;

@protocol CSCategoryRetailersCellDelegate <NSObject>

- (void)categoryRetailersCell:(CSCategoryRetailersCell *)cell
     didSelectRetailerAtIndex:(NSInteger)index;

@end

@interface CSCategoryRetailersCell : CSRetailersCell

@property (nonatomic, weak) IBOutlet id<CSCategoryRetailersCellDelegate> delegate;

@property (nonatomic, strong) IBOutlet id<CSRetailerList> retailers;

@end
