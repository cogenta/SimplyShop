//
//  CSRetailerSelectionCell.h
//  SimplyShop
//
//  Created by Will Harris on 28/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSTheme;
@protocol CSRetailerList;

@interface CSRetailerSelectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *retailerNameLabel;
@property (nonatomic, strong) id<CSTheme> theme UI_APPEARANCE_SELECTOR;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

- (void)setRetailerList:(NSObject<CSRetailerList> *)list
                  index:(NSInteger)index;

@end
