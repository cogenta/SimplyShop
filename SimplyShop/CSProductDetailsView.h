//
//  CSProductDetailsView.h
//  SimplyShop
//
//  Created by Will Harris on 26/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSTabArrowView;
@class CSTabFooterView;

@interface CSProductDetailsView : UIScrollView

@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet CSTabArrowView *descriptionTabArrowView;
@property (nonatomic, weak) IBOutlet CSTabFooterView *tabFooterView;

@property (weak, nonatomic) IBOutlet UILabel *producStatsTabLabel;
@property (weak, nonatomic) IBOutlet CSTabArrowView *productStatsTabArrowView;

@property (nonatomic, copy) NSString *description;

@end
