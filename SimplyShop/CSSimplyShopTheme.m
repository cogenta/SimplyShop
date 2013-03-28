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
#import "CSRetailerSelectionCell.h"

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
            resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 6.0, 0.0, 6.0)
            resizingMode:UIImageResizingModeStretch];
}


- (UIImage *)navigationBarButtonDoneBackgroundImage
{
    return [[UIImage imageNamed:@"ButtonDone"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 6.0, 0.0, 6.0)
            resizingMode:UIImageResizingModeStretch];
}

- (UIImage *)navigationBarBackNormalBackgroundImage
{
    return [[UIImage imageNamed:@"BackButtonNormal"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 14.0, 0.0, 5.0)
            resizingMode:UIImageResizingModeStretch];
}

- (UIColor *)collectionViewBackgroundColor
{
    return [UIColor colorWithHexString:@"#f5f5f5"];
}

- (UIImage *)collectionViewCellBackgroundImage
{
    return [[UIImage imageNamed:@"TileBackground"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(9.0, 9.0, 9.0, 9.0)
            resizingMode:UIImageResizingModeStretch];
}

- (UIImage *)collectionViewCellSelectedBackgroundImage
{
    return [[UIImage imageNamed:@"TileBackgroundSelected"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(9.0, 9.0, 9.0, 9.0)
            resizingMode:UIImageResizingModeStretch];
}

- (void)apply
{
    UINavigationBar *navBar = [UINavigationBar appearance];
    [navBar
     setBackgroundImage:[self navigationBarBackgroundImage]
     forBarMetrics:UIBarMetricsDefault];
    [navBar
     setTitleTextAttributes:[self navigationBarTitleTextAttributes]];
    
    UIBarButtonItem *navButtonItem = [UIBarButtonItem
                                      appearanceWhenContainedIn:[UINavigationBar class],
                                      nil];
    [navButtonItem
     setBackgroundImage:[self navigationBarButtonNormalBackgroundImage]
     forState:UIControlStateNormal
     barMetrics:UIBarMetricsDefault];
    [navButtonItem
     setBackgroundImage:[self navigationBarButtonDoneBackgroundImage]
     forState:UIControlStateNormal
     style:UIBarButtonItemStyleDone
     barMetrics:UIBarMetricsDefault];
    [navButtonItem
     setBackButtonBackgroundImage:[self navigationBarBackNormalBackgroundImage]
     forState:UIControlStateNormal
     barMetrics:UIBarMetricsDefault];

    UICollectionView *collectionView = [UICollectionView appearance];
    [collectionView
     setBackgroundColor:[self collectionViewBackgroundColor]];
    
    CSRetailerSelectionCell *retailerCell = [CSRetailerSelectionCell appearance];
    [retailerCell setTheme:self];
}

@end
