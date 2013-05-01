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
@class CSProductDetailsView;
@class CSTitleBarView;

@interface CSProductDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet CSProductDetailsView *productDetailsView;
@property (weak, nonatomic) IBOutlet CSTitleBarView *titleBarView;

@property (nonatomic, strong) id<CSProductSummary> productSummary;
@property (nonatomic, strong) id<CSProduct> product;

@end
