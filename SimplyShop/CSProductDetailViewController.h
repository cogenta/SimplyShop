//
//  CSProductDetailViewController.h
//  SimplyShop
//
//  Created by Will Harris on 25/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSProduct;
@protocol CSProductSummary;
@class CSTitleBarView;
@class CSProductDetailsView;
@class CSProductSidebarView;
@class CSPriceContext;

@interface CSProductDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet CSTitleBarView *titleBarView;
@property (weak, nonatomic) IBOutlet CSProductDetailsView *productDetailsView;
@property (weak, nonatomic) IBOutlet CSProductSidebarView *sidebarView;

@property (nonatomic, strong) id<CSProductSummary> productSummary;
@property (nonatomic, strong) id<CSProduct> product;
@property (nonatomic, strong) CSPriceContext *priceContext;

@end
