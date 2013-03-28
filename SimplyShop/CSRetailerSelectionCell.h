//
//  CSRetailerSelectionCell.h
//  SimplyShop
//
//  Created by Will Harris on 28/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSTheme.h"

@interface CSRetailerSelectionCell : UICollectionViewCell

@property (nonatomic, strong) id<CSTheme> theme UI_APPEARANCE_SELECTOR;

@end
