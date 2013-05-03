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
#import "CSProductStatsView.h"
#import "CSProductGalleryView.h"
#import "CSTitleBarView.h"
#import "CSTabBarView.h"
#import "CSProductSidebarView.h"
#import "CSRetailerLogoView.h"

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
             UITextAttributeTextColor:[UIColor colorWithHexString:@"#606060"]};
}

- (UIImage *)titleBarBackgroundImage
{
    return [[UIImage imageNamed:@"TitleBarBg"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(4.5, 5.0, 1.0, 5.0)
            resizingMode:UIImageResizingModeStretch];
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
    
    //
        
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
    
    //

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
    
    CSProductStatsView *productStatsView = [CSProductStatsView appearance];
    productStatsView.labelFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    productStatsView.labelColor = [UIColor colorWithHexString:@"#606060"];
    productStatsView.valueFont = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    productStatsView.valueColor = [UIColor colorWithHexString:@"#606060"];
    CGSize marginSize = [@"X" sizeWithFont:productStatsView.labelFont];
    productStatsView.heightForRow = marginSize.height + 2.0;
    productStatsView.margin = marginSize.width;
    
    CSProductGalleryView *productGalleryView = [CSProductGalleryView appearance];
    productGalleryView.backgroundImage = [[UIImage imageNamed:@"GalleryBg"] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0, 6.0, 0.0, 6.0)];
    productGalleryView.footerBackgroundImage = [[UIImage imageNamed:@"GalleryFooter"] resizableImageWithCapInsets:UIEdgeInsetsMake(1.0, 9.0, 10.0, 9.0)];

    CSTitleBarView *titleBarView = [CSTitleBarView appearance];
    titleBarView.titleColor = [UIColor colorWithHexString:@"#000000"];
    titleBarView.titleFont = [UIFont fontWithName:@"Gill Sans" size:15.0];
    titleBarView.backgroundImage = [self titleBarBackgroundImage];
    
    UIButton *tabBarButton = [UIButton appearanceWhenContainedIn:[CSTabBarView class], nil];
    UILabel *tabBarButtonLabel = [UILabel appearanceWhenContainedIn:[UIButton class], [CSTabBarView class], nil];
    tabBarButtonLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:12.5];
    [tabBarButton setTitleColor:[UIColor colorWithHexString:@"#606060"] forState:UIControlStateNormal];
    UIImage *selectedTabBg = [[UIImage imageNamed:@"SelectedTabBg"] resizableImageWithCapInsets:UIEdgeInsetsMake(11.0, 5.0, 6.0, 5.0)];
    [tabBarButton setBackgroundImage:selectedTabBg forState:UIControlStateSelected];
    
    CSProductSidebarView *sidebarView = [CSProductSidebarView appearance];
    sidebarView.backgroundImage = [[UIImage imageNamed:@"ProductRightBg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 1.0, 0.0, 0.0)];
    
    CSRetailerLogoView *retailerLogoView = [CSRetailerLogoView appearance];
    retailerLogoView.backgroundImage = [[UIImage imageNamed:@"BigRetailerBackground"]
                                        resizableImageWithCapInsets:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)];
    retailerLogoView.backgroundColor = [UIColor clearColor];
}

- (void)themeCTAButton:(CSCTAButton *)button
{
    [button setBackgroundImage:[self callToActionButtonBackgroundImage]
                      forState:UIControlStateNormal];
    [button setTitleFont:[self callToActionButtonFont]];
    [button setTitleColor:[self callToActionButtonTextColor]];
}

@end
