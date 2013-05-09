//
//  CSProductSummaryCell.h
//  SimplyShop
//
//  Created by Will Harris on 09/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSTheme;
@protocol CSProductSummary;

@class CSCTAButton;
@class CSProductSummaryCell;
@class CSProductWrapper;
@class CSPriceContext;

@protocol CSProductSummaryCellDelegate <NSObject>
- (void)productSummaryCell:(CSProductSummaryCell *)cell
    needsReloadWithAddress:(NSObject *)address;
@end

@interface CSProductSummaryCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet CSCTAButton *retryButton;

@property (strong, nonatomic) id<CSTheme> theme UI_APPEARANCE_SELECTOR;

@property (weak, nonatomic) IBOutlet id<CSProductSummaryCellDelegate> delegate;

@property (strong, nonatomic) CSPriceContext *priceContext;

- (IBAction)didTapRetryButton:(id)sender;
- (void)setLoadingAddress:(NSObject *)address;
- (void)setWrapper:(CSProductWrapper *)wrapper
           address:(NSObject *)address;
- (void)setError:(NSError *)error address:(NSObject *)address;

- (NSString *)nibName;

@end
