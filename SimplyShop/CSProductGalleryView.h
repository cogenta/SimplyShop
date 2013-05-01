//
//  CSProductGalleryView.h
//  SimplyShop
//
//  Created by Will Harris on 01/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSProductGalleryView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *footerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;

@property (strong, nonatomic) UIImage *backgroundImage UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIImage *footerBackgroundImage UI_APPEARANCE_SELECTOR;


@end
