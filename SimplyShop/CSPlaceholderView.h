//
//  CSPlaceholderView.h
//  SimplyShop
//
//  Created by Will Harris on 23/07/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSPlaceholderView : UIView

@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (copy, nonatomic) NSString *emptyViewTitle;
@property (copy, nonatomic) NSString *emptyViewDetail;

@property (copy, nonatomic) NSString *errorViewTitle;
@property (copy, nonatomic) NSString *errorViewDetail;

@property (copy, nonatomic) NSString *loadingViewTitle;
@property (copy, nonatomic) NSString *loadingViewDetail;

- (void)showContentView;
- (void)showEmptyView;
- (void)showErrorView;
- (void)showLoadingView;

@end
