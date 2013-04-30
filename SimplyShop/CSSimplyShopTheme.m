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
#import "CSProductSummariesCell.h"
#import "CSProductSummaryCell.h"
#import "CSCTAButton.h"
#import "CSAppearanceButton.h"
#import "CSTabArrowView.h"
#import "CSTabFooterView.h"

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

- (UIColor *)tableViewBackgroundColor
{
    return [self collectionViewBackgroundColor];
}

- (UIImage *)callToActionButtonBackgroundImage
{
    return [[UIImage imageNamed:@"CallToAction"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 7.0, 0.0, 7.0)
            resizingMode:UIImageResizingModeStretch];
}

- (UIFont *)callToActionButtonFont
{
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
}

- (UIColor *)callToActionButtonTextColor
{
    return [UIColor colorWithHexString:@"#ffffff"];
}

- (UIFont *)homePageSmallButtonTitleFont
{
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
}

- (UIColor *)homePageSmallButtonTitleColor
{
    return [UIColor colorWithHexString:@"#606060"];
}

- (UIColor *)homePageSmallButtonTitleShadowColor
{
    return [UIColor colorWithHexString:@"#ffffff"];
}

- (CGSize)homePageSmallButtonTitleShadowOffset
{
    return CGSizeMake(0.0, 1.0);
}

- (SEL)producNameTransform
{
    return @selector(uppercaseString);
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
    
    CSProductSummaryCell *productSummaryCell = [CSProductSummaryCell appearance];
    [productSummaryCell setTheme:self];
    
    CSCTAButton *ctaButton = [CSCTAButton appearance];
    [self themeCTAButton:ctaButton];
    
    UITableView *tableView = [UITableView appearance];
    [tableView setBackgroundColor:[self tableViewBackgroundColor]];
    
    CSAppearanceButton *
    retailerEditButton = [CSAppearanceButton appearanceWhenContainedIn:
                          [UITableViewCell class], nil];
    [retailerEditButton setTitleFont:[self homePageSmallButtonTitleFont]];
    [retailerEditButton setTitleColor:[self homePageSmallButtonTitleColor]];
    [retailerEditButton setTitleShadowColor:[self homePageSmallButtonTitleShadowColor]];
    [retailerEditButton setTitleLabelShadowOffset:[self homePageSmallButtonTitleShadowOffset]];
    
    CSTabArrowView *tabArrowView = [CSTabArrowView appearance];
    tabArrowView.leftImage = [[UIImage imageNamed:@"TabUnderline"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 7.0, 0.0)];
    tabArrowView.arrowImage = [UIImage imageNamed:@"TabArrow"];
    tabArrowView.rightImage = [[UIImage imageNamed:@"TabUnderline"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 7.0, 0.0)];
    
    CSTabFooterView *tabFooterView = [CSTabFooterView appearance];
    tabFooterView.backgroundImage = [[UIImage imageNamed:@"TabBottom"] resizableImageWithCapInsets:UIEdgeInsetsMake(7.0, 0.0, 0.0, 0.0)];
}

- (void)themeCTAButton:(CSCTAButton *)button
{
    [button setBackgroundImage:[self callToActionButtonBackgroundImage]
                      forState:UIControlStateNormal];
    [button setTitleFont:[self callToActionButtonFont]];
    [button setTitleColor:[self callToActionButtonTextColor]];

}

@end
