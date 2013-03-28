//
//  CSRetailerSelectionCell.m
//  SimplyShop
//
//  Created by Will Harris on 28/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRetailerSelectionCell.h"


@implementation CSRetailerSelectionCell

@synthesize theme;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setTheme:(id<CSTheme>)newTheme
{
    theme = newTheme;
    self.backgroundView = [[UIImageView alloc]
                           initWithImage:[theme collectionViewCellBackgroundImage]];
}

@end
