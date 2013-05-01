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
@class CSProductStatsView;
@class CSProductStats;
@class CSProductGalleryView;
@protocol CSPictureList;

@interface CSProductDetailsView : UIScrollView

@property (weak, nonatomic) IBOutlet CSProductGalleryView *galleryView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet CSTabArrowView *descriptionTabArrowView;
@property (weak, nonatomic) IBOutlet CSTabFooterView *tabFooterView;

@property (weak, nonatomic) IBOutlet UILabel *producStatsTabLabel;
@property (weak, nonatomic) IBOutlet CSTabArrowView *productStatsTabArrowView;
@property (weak, nonatomic) IBOutlet CSProductStatsView *productStatsView;

@property (nonatomic, copy) NSString *description;
@property (nonatomic, strong) CSProductStats *stats;
@property (nonatomic, strong) id<CSPictureList> pictures;

@end
