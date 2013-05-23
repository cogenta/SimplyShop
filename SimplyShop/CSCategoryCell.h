//
//  CSCategoryCell.h
//  SimplyShop
//
//  Created by Will Harris on 23/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSCategory;
@protocol CSTheme;

@interface CSCategoryCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;
@property (nonatomic, strong) id<CSTheme> theme UI_APPEARANCE_SELECTOR;


- (void)setLoadingAddress:(NSObject *)address;
- (void)setCategory:(NSObject<CSCategory> *)category
            address:(NSObject *)address;

@end
