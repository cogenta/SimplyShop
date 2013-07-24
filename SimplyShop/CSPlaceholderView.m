//
//  CSPlaceholderView.m
//  SimplyShop
//
//  Created by Will Harris on 23/07/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSPlaceholderView.h"
#import "CSEmptyProductGridView.h"

@interface CSPlaceholderView ()

@property (strong, nonatomic) CSEmptyProductGridView *emptyView;
@property (strong, nonatomic) CSEmptyProductGridView *errorView;
@property (strong, nonatomic) CSEmptyProductGridView *loadingView;

- (void)hideAllPlaceholderViews;
- (void)hideEmptyView;
- (void)hideErrorView;
- (void)hideLoadingView;

- (void)initialize;

@end

@implementation CSPlaceholderView

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

- (void)initialize
{
    if ( ! self.emptyViewTitle) {
        self.emptyViewTitle = @"No Content";
    }
    
    if ( ! self.errorViewTitle) {
        self.errorViewTitle = @"Error";
    }
    
    if ( ! self.loadingViewTitle) {
        self.loadingViewTitle = @"Loading";
    }
    
    [self showContentView];
}

- (void)showContentView
{
    [self hideAllPlaceholderViews];
    self.contentView.frame = self.bounds;
    [self addSubview:self.contentView];
}

- (void)showEmptyView
{
    [self hideAllPlaceholderViews];
    
    self.emptyView = [[CSEmptyProductGridView alloc]
                      initWithFrame:self.bounds];
    
    self.emptyView.frame = self.bounds;
    self.emptyView.headerText = self.emptyViewTitle;
    self.emptyView.detailText = self.emptyViewDetail;
    [self addSubview:self.emptyView];
}

- (void)showErrorView
{
    [self hideAllPlaceholderViews];
    
    self.errorView = [[CSEmptyProductGridView alloc]
                      initWithFrame:self.bounds];
    
    self.errorView.frame = self.bounds;
    self.errorView.headerText = self.errorViewTitle;
    self.errorView.detailText = self.errorViewDetail;
    [self addSubview:self.errorView];
}

- (void)showLoadingView
{
    [self hideAllPlaceholderViews];
    
    self.loadingView = [[CSEmptyProductGridView alloc]
                        initWithFrame:self.bounds];
    
    self.loadingView.frame = self.bounds;
    self.loadingView.headerText = self.loadingViewTitle;
    self.loadingView.detailText = self.loadingViewDetail;
    self.loadingView.active = YES;
    [self addSubview:self.loadingView];
}

- (void)hideContentView
{
    [self.contentView removeFromSuperview];
}

- (void)hideEmptyView
{
    [self.emptyView removeFromSuperview];
    self.emptyView = nil;
}

- (void)hideErrorView
{
    [self.errorView removeFromSuperview];
    self.errorView = nil;
}

- (void)hideLoadingView
{
    [self.loadingView removeFromSuperview];
    self.loadingView = nil;
}


- (void)hideAllPlaceholderViews
{
    [self hideContentView];
    [self hideEmptyView];
    [self hideErrorView];
    [self hideLoadingView];
}

- (void)centerSubviews
{
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds),
                                 CGRectGetMidY(self.bounds));
    self.contentView.center = center;
    self.loadingView.center = center;
    self.errorView.center = center;
    self.emptyView.center = center;
}

- (void)sizeSubviews
{
    self.contentView.frame = self.bounds;
    self.loadingView.frame = self.bounds;
    self.errorView.frame = self.bounds;
    self.emptyView.frame = self.bounds;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self centerSubviews];
    [self sizeSubviews];
}

@end
