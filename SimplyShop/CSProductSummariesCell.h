//
//  CSProductSummariesCell.h
//  SimplyShop
//
//  Created by Will Harris on 08/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSDashboardRowCell.h"

@protocol CSProductList;
@protocol CSProductSummariesCellDelegate;

@interface CSProductSummariesCell : CSDashboardRowCell

@property (strong, nonatomic) NSObject<CSProductList> *products;
@property (assign, nonatomic) BOOL isRoot;

@property (weak, nonatomic) IBOutlet UIButton *seeAllButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet id<CSProductSummariesCellDelegate> delegate;

- (IBAction)didTapSeeAllButton:(id)sender;

@end

@protocol CSProductSummariesCellDelegate <NSObject>

@optional

- (void)productSummariesCell:(CSProductSummariesCell *)cell
        didSelectItemAtIndex:(NSUInteger)index;
- (void)productSummariesCellDidTapSeeAllButton:(CSProductSummariesCell *)cell;

@end


