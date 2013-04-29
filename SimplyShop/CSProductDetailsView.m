//
//  CSProductDetailsView.m
//  SimplyShop
//
//  Created by Will Harris on 26/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductDetailsView.h"

@implementation CSProductDetailsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setDescription:(NSString *)description
{
    _description = [description copy];
    if (description == (id) [NSNull null]) {
        description = @"No Description";
    }
    self.descriptionLabel.text = description;
    [self.descriptionLabel sizeToFit];
    [self sizeToFit];
}   

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize marginSize = CGSizeMake(self.descriptionLabel.frame.size.width - 20.0,
                                   [UIScreen mainScreen].bounds.size.height - 20.0);
    CGSize descriptionSize = [self.descriptionLabel sizeThatFits:marginSize];
    return CGSizeMake(descriptionSize.width + 20.0, descriptionSize.height + 20.0);
}

@end
