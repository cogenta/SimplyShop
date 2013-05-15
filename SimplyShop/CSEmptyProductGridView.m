//
//  CSEmptyProductGridView.m
//  SimplyShop
//
//  Created by Will Harris on 15/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSEmptyProductGridView.h"

@interface CSEmptyProductGridView ()

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) UIView *subview;
@property (strong, nonatomic) UIImage *backgroundImage;

- (void)initialize;
- (void)updateContent;
- (void)updateHeader;
- (void)updateDetail;

@end

@implementation CSEmptyProductGridView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _headerText = @"No Products";
    _detailText = @"No products were found for your search.";
    _headerTextAttributes = @{};
    _detailTextAttributes = @{};
    _subview = [[[NSBundle mainBundle] loadNibNamed:@"CSEmptyProductGridView"
                                              owner:self
                                            options:nil]
                objectAtIndex:0];
    _subview.frame = self.bounds;
    [self addSubview:_subview];
    [self updateContent];
}

- (void)layoutSubviews
{
    self.subview.frame = self.bounds;
}

- (void)updateContent
{
    [self updateHeader];
    [self updateDetail];
}

- (void)updateHeader
{
    if ( ! self.headerTextAttributes || ! self.headerText) {
        self.headerLabel.text = self.headerText;
        return;
    }
    self.headerLabel.attributedText = [[NSAttributedString alloc]
                                       initWithString:self.headerText
                                       attributes:self.headerTextAttributes];
}

- (void)updateDetail
{
    if ( ! self.detailTextAttributes || ! self.detailText) {
        self.detailLabel.text = self.detailText;
        return;
    }
    
    self.detailLabel.attributedText = [[NSAttributedString alloc]
                                       initWithString:self.detailText
                                       attributes:self.detailTextAttributes];
}

- (void)setHeaderText:(NSString *)headerText
{
    _headerText = headerText;
    [self updateHeader];
}

- (void)setDetailText:(NSString *)detailText
{
    _detailText = detailText;
    [self updateDetail];
}

- (void)setHeaderTextAttributes:(NSDictionary *)headerTextAttributes
{
    _headerTextAttributes = headerTextAttributes;
    [self updateHeader];
}

- (void)setDetailTextAttributes:(NSDictionary *)detailTextAttributes
{
    _detailTextAttributes = detailTextAttributes;
    [self updateDetail];
}

- (void)setActive:(BOOL)active
{
    if (self.activityIndicator.isAnimating == active) {
        return;
    }
    
    if (active) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
}

@end