//
//  CSTabBarView.h
//  SimplyShop
//
//  Created by Will Harris on 02/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSTabArrowView;

@protocol CSTabBarViewDelegate <NSObject>

- (void)selectDescription;
- (void)selectStats;

@end

@interface CSTabBarView : UIView

@property (weak, nonatomic) IBOutlet CSTabArrowView *arrowView;
@property (weak, nonatomic) IBOutlet UIButton *defaultButton;
@property (weak, nonatomic) IBOutlet id<CSTabBarViewDelegate> delegate;

- (IBAction)didSelectTab:(UIButton *)sender;

@end
