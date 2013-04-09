//
//  CSProductSummariesCell.m
//  SimplyShop
//
//  Created by Will Harris on 08/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductSummariesCell.h"
#import "CSProductSummaryView.h"
#import <CSApi/CSAPI.h>
#import <SwipeView/SwipeView.h>

@interface CSProductSummariesCell ()

- (void)initialize;

@end

@implementation CSProductSummariesCell

@synthesize swipeView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initialize];
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)setSwipeView:(SwipeView *)newSwipeView
{
    swipeView = newSwipeView;
    self.swipeView.truncateFinalPage = YES;
    self.swipeView.pagingEnabled = NO;
}

- (void)initialize
{
    [self addObserver:self
           forKeyPath:@"productSummaries"
              options:NSKeyValueObservingOptionNew
              context:NULL];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"productSummaries"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"productSummaries"]) {
        [self.swipeView reloadData];
        return;
    }
}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return self.productSummaries.count;
}


- (UIView *)swipeView:(SwipeView *)swipeView
   viewForItemAtIndex:(NSInteger)index
          reusingView:(UIView *)view
{
    CSProductSummaryView *productSummaryView = nil;
    if (view) {
        productSummaryView = (CSProductSummaryView *)view;
    }
    
    if ( ! productSummaryView) {
        productSummaryView = [[[NSBundle mainBundle]
                               loadNibNamed:@"CSProductSummaryView"
                               owner:nil
                               options:nil]
                              objectAtIndex:0];
    }
    
    [productSummaryView setLoadingAddress:@(index)];
    [self.productSummaries getProductSummaryAtIndex:index
                                           callback:^(id<CSProductSummary> result, NSError *error)
    {
        if (error) {
            // TODO: handle error
            return;
        }
        
        [productSummaryView setProductSummary:result address:@(index)];
    }];
    
    return productSummaryView;
}

@end
