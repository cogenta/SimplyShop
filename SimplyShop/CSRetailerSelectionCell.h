//
//  CSRetailerSelectionCell.h
//  SimplyShop
//
//  Created by Will Harris on 28/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSAddressCell.h"

@protocol CSTheme;
@protocol CSRetailer;

@interface CSRetailerSelectionCell : UICollectionViewCell <CSAddressCell>

@property (weak, nonatomic) IBOutlet UILabel *retailerNameLabel;
@property (nonatomic, strong) id<CSTheme> theme UI_APPEARANCE_SELECTOR;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@property (readonly) BOOL isReady;

- (void)setRetailer:(NSObject<CSRetailer> *)retailer
            address:(NSObject *)address;

@end
