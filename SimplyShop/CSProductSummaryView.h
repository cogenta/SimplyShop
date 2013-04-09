//
//  CSProductSummaryView.h
//  SimplyShop
//
//  Created by Will Harris on 08/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSTheme;
@protocol CSProductSummary;

@interface CSProductSummaryView : UIView

@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (strong, nonatomic) id<CSTheme> theme UI_APPEARANCE_SELECTOR;

- (void)setLoadingAddress:(NSObject *)address;
- (void)setProductSummary:(id<CSProductSummary>)productSummary
                  address:(NSObject *)address;

@end
