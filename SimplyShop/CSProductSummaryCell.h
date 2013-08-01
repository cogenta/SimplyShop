//
//  CSProductSummaryCell.h
//  SimplyShop
//
//  Created by Will Harris on 09/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSAddressCell.h"

@protocol CSTheme;
@protocol CSProduct;

@class CSCTAButton;
@class CSProductSummaryCell;
@class CSPriceContext;

@protocol CSProductSummaryCellDelegate <NSObject>
- (void)productSummaryCell:(CSProductSummaryCell *)cell
    needsReloadWithAddress:(NSObject *)address;
@end

@interface CSProductSummaryCell : UICollectionViewCell <CSAddressCell>

@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet CSCTAButton *retryButton;

@property (strong, nonatomic) id<CSTheme> theme UI_APPEARANCE_SELECTOR;

@property (weak, nonatomic) IBOutlet id<CSProductSummaryCellDelegate> delegate;

@property (strong, nonatomic) NSObject *address;
@property (strong, nonatomic) CSPriceContext *priceContext;

- (IBAction)didTapRetryButton:(id)sender;
- (void)setLoadingAddress:(NSObject *)address;
- (void)setProduct:(id<CSProduct>)product
           address:(NSObject *)address;
- (void)setError:(NSError *)error address:(NSObject *)address;

- (NSString *)nibName;

@end
