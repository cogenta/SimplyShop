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

@interface CSProductDetailViewController : UIViewController

@property (nonatomic, strong) id<CSProductSummary> productSummary;
@property (nonatomic, strong) id<CSProduct> product;

@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

@end
