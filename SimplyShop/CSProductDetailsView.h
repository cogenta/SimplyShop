//
//  CSProductDetailsView.h
//  SimplyShop
//
//  Created by Will Harris on 26/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSProductDetailsView : UIScrollView

@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, copy) NSString *description;

@end
