//
//  CSCategoryCell.h
//  SimplyShop
//
//  Created by Will Harris on 23/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSAddressCell.h"

@protocol CSCategory;
@protocol CSTheme;

@interface CSCategoryCell : UICollectionViewCell <CSAddressCell>

@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;
@property (nonatomic, strong) id<CSTheme> theme UI_APPEARANCE_SELECTOR;

@end
