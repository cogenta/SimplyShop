//
//  CSEmptyProductGridView.h
//  SimplyShop
//
//  Created by Will Harris on 15/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSEmptyProductGridView : UIView

@property (strong, nonatomic) NSDictionary *headerTextAttributes UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) NSDictionary *detailTextAttributes UI_APPEARANCE_SELECTOR;

@property (copy, nonatomic) NSString *headerText;
@property (copy, nonatomic) NSString *detailText;
@property (nonatomic) BOOL active;

@end
