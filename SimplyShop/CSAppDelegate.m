//
//  CSAppDelegate.m
//  SimplyShop
//
//  Created by Will Harris on 27/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSAppDelegate.h"
#import "CSSimplyShopTheme.h"
#import <CSApi/CSAPI.h>
#import "CSRetailerSelectionViewController.h"

#define kAPIBookmark @"http://192.168.1.16:5000/apps/51139a687046797035ad6db6"
#define kAPIUsername @"53a2abd8-5a96-47a8-8a1f-82cf4a462b57"
#define kAPIPassword @"ecd50b80-f1f1-4500-816e-ae16f179dd98"

@interface CSAppDelegate ()
@property (readonly) NSObject<CSTheme> *theme;
@end

@implementation CSAppDelegate

@synthesize api;

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    api = [CSAPI apiWithBookmark:kAPIBookmark
                        username:kAPIUsername
                        password:kAPIPassword];

    [self.theme apply];

    self.window = [[UIWindow alloc]
                   initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard"
                                                         bundle:nil];
    UINavigationController *nav = [storyboard instantiateInitialViewController];
    [self.window setRootViewController:nav];
    
    CSRetailerSelectionViewController *top = (id) nav.topViewController;
    [self.api getApplication:^(id<CSApplication> app, NSError *error) {
        [app getRetailers:^(id<CSRetailerListPage> firstPage, NSError *error) {
            top.retailerList = firstPage.retailerList;
        }];
    }];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (NSObject<CSTheme> *)theme
{
    return [[CSSimplyShopTheme alloc] init];
}

@end
