//
//  CSNarrowCell.h
//  SimplyShop
//
//  Created by Will Harris on 13/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSNarrowList;
@protocol CSNarrow;

@interface CSNarrowCell : UITableViewCell

- (void)setNarrowList:(id<CSNarrowList>)list index:(NSUInteger)index;


@end
