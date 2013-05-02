//
//  CSTabBarView.m
//  SimplyShop
//
//  Created by Will Harris on 02/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSTabBarView.h"
#import "CSTabArrowView.h"

@interface CSTabBarView ()

@property (strong, nonatomic) UIView *subview;
@property (weak, nonatomic) UIButton *selectedButton;

- (void)initialize;

@end

@implementation CSTabBarView

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
    _subview = [[[NSBundle mainBundle] loadNibNamed:@"CSTabBarView"
                                              owner:self
                                            options:nil]
                objectAtIndex:0];
    [self addSubview:_subview];
    [self didSelectTab:self.defaultButton];
}

- (IBAction)didSelectTab:(UIButton *)sender {
    self.selectedButton.selected = NO;
    self.selectedButton = sender;
    self.selectedButton.selected = YES;
    
    self.arrowView.position = CGRectGetMidX(self.selectedButton.frame);
}

- (void)layoutSubviews
{
    self.subview.frame = self.bounds;
}

@end
