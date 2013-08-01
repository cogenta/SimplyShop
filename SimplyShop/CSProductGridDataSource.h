//
//  CSProductGridDataSource.h
//  SimplyShop
//
//  Created by Will Harris on 23/07/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSProductSummaryCell.h"

@protocol CSProductList;

@interface CSProductGridDataSource : NSObject <
UICollectionViewDataSource,
CSProductSummaryCellDelegate>

@property (strong, nonatomic) CSPriceContext *priceContext;
@property (strong, nonatomic) id<CSProductList> products;

@end
