//
//  CSSimplyShopTheme.m
//  SimplyShop
//
//  Created by Will Harris on 27/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSSimplyShopTheme.h"
#import <UIKit/UIKit.h>
#import <MBCategory/MBCategory.h>

@implementation CSSimplyShopTheme

- (UIImage *)navigationBarBackgroundImage
{
    return [[UIImage imageNamed:@"NavigationBarBackground"]
            resizableImageWithCapInsets:UIEdgeInsetsZero
            resizingMode:UIImageResizingModeTile];
}

- (NSDictionary *)navigationBarTitleTextAttributes
{
    return @{UITextAttributeFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0],
             UITextAttributeTextColor: [UIColor colorWithHexString:@"#606060"]};
}

- (UIImage *)navigationBarButtonNormalBackgroundImage
{
    return [[UIImage imageNamed:@"ButtonNormal"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 5.5, 0.0, 5.5)
            resizingMode:UIImageResizingModeStretch];
}

- (UIImage *)navigationBarBackNormalBackgroundImage
{
    return [[UIImage imageNamed:@"BackButtonNormal"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 14.0, 0.0, 5.5)
            resizingMode:UIImageResizingModeStretch];
}

- (UIColor *)collectionViewBackgroundColor
{
    return [UIColor colorWithHexString:@"#f5f5f5"];
}


- (void)apply
{
    [(UINavigationBar *)[UINavigationBar appearance]
     setBackgroundImage:[self navigationBarBackgroundImage]
     forBarMetrics:UIBarMetricsDefault];
    [(UINavigationBar *)[UINavigationBar appearance]
     setTitleTextAttributes:[self navigationBarTitleTextAttributes]];
    [(UIBarButtonItem *) [UIBarButtonItem
                          appearanceWhenContainedIn:[UINavigationBar class],
                          nil]
     setBackgroundImage:[self navigationBarButtonNormalBackgroundImage]
     forState:UIControlStateNormal
     barMetrics:UIBarMetricsDefault];
    [(UIBarButtonItem *) [UIBarButtonItem
                          appearanceWhenContainedIn:[UINavigationBar class],
                          nil]
     setBackButtonBackgroundImage:[self navigationBarBackNormalBackgroundImage]
     forState:UIControlStateNormal
     barMetrics:UIBarMetricsDefault];
    [(UICollectionView *) [UICollectionView appearance]
     setBackgroundColor:[self collectionViewBackgroundColor]];
}

@end
