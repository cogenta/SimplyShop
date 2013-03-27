//
//  CSAppDelegate.m
//  SimplyShop
//
//  Created by Will Harris on 27/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSAppDelegate.h"
#import "CSSimplyShopTheme.h"

@interface CSAppDelegate ()
@property (readonly) NSObject<CSTheme> *theme;
@end

@implementation CSAppDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc]
                   initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self.theme apply];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard"
                                                         bundle:nil];
    UINavigationController *nav = [storyboard instantiateInitialViewController];
    [self.window setRootViewController:nav];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (NSObject<CSTheme> *)theme
{
    return [[CSSimplyShopTheme alloc] init];
}

@end
