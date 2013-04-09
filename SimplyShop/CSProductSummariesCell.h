//
//  CSProductSummariesCell.h
//  SimplyShop
//
//  Created by Will Harris on 08/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSProductSummaryList;

@interface CSProductSummariesCell : UITableViewCell
<UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) NSObject<CSProductSummaryList> *productSummaries;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
