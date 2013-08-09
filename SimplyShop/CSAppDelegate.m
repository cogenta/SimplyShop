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
#import "CSHomePageViewController.h"

#define kAPIBookmark @"http://192.168.1.16:5000/apps/5166c038704679e1be1b2c6e"
#define kAPIUsername @"224f32de-b1df-4bc7-9ef5-c71d8d9c7349"
#define kAPIPassword @"0647e17d-8813-40b7-adbe-c9553312b1b6"

@interface CSAppDelegate ()
@property (readonly) NSObject<CSTheme> *theme;
@end

@implementation CSAppDelegate

@synthesize api;

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:1024*1024*10
                                                            diskCapacity:1024*1024*20
                                                                diskPath:@"shared_cache"];
    [sharedCache removeAllCachedResponses];
    [NSURLCache setSharedURLCache:sharedCache];
    
    api = [CSAPI apiWithBookmark:kAPIBookmark
                        username:kAPIUsername
                        password:kAPIPassword];

    [self.theme apply];

    self.window = [[UIWindow alloc]
                   initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard"
                                                         bundle:nil];
    UINavigationController *nav = [storyboard instantiateInitialViewController];
    [self.window setRootViewController:nav];
    
    CSHomePageViewController *top = (id) nav.topViewController;
    top.api = self.api;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (NSObject<CSTheme> *)theme
{
    return [[CSSimplyShopTheme alloc] init];
}

@end
