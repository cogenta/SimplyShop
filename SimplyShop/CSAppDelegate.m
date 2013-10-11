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
#import <MBCategory/MBCategory.h>


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
    NSURLCache *sharedCache = [[NSURLCache alloc]
                               initWithMemoryCapacity:1024*1024*10
                               diskCapacity:1024*1024*20
                               diskPath:@"shared_cache"];
    [sharedCache removeAllCachedResponses];
    [NSURLCache setSharedURLCache:sharedCache];
    
    if ( ! api) {
        api = [CSAPI apiWithBookmark:kAPIBookmark
                            username:kAPIUsername
                            password:kAPIPassword];
    }

    [self.theme apply];

    
#ifdef LAUNCHIMAGE
    UINavigationController *nav = [[UINavigationController alloc]
                                   initWithRootViewController:nil];
    self.window.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    self.window.rootViewController = nav;
    return YES;
    
#else
    self.window.backgroundColor = [UIColor blackColor];
    
    if (self.window.rootViewController) {
        UINavigationController *nav = (id) self.window.rootViewController;
        NSArray *viewControllers = nav.viewControllers;
        if ( ! [viewControllers count]) {
            return YES;
        }
        
        CSHomePageViewController *bottom = viewControllers[0];
        bottom.api = self.api;
        return YES;
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard"
                                                         bundle:nil];
    UINavigationController *nav = [storyboard instantiateInitialViewController];
    [self.window setRootViewController:nav];
    
    CSHomePageViewController *top = (id) nav.topViewController;
    top.api = self.api;
    
    [self.window makeKeyAndVisible];
    
    return YES;
#endif
}

- (NSObject<CSTheme> *)theme
{
    return [[CSSimplyShopTheme alloc] init];
}

#pragma mark - Restoration

#define kAppVersionRestorationKey @"com.cogenta.restoration.app_version"
#define kAPIRestorationKey @"com.cogenta.restoration.api"
#define kAPIBookmarkRestorationKey @"com.cogenta.restoration.apiBookmark"

- (BOOL)application:(UIApplication *)application
shouldSaveApplicationState:(NSCoder *)coder
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = infoDictionary[(NSString *) kCFBundleVersionKey];
    
    [coder encodeObject:version forKey:kAppVersionRestorationKey];
    [coder encodeObject:kAPIBookmark forKey:kAPIBookmarkRestorationKey];
    return YES;
}

- (BOOL)application:(UIApplication *)application
shouldRestoreApplicationState:(NSCoder *)coder
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = infoDictionary[(NSString *) kCFBundleVersionKey];

    NSString *savedBookmark = [coder decodeObjectForKey:
                               kAPIBookmarkRestorationKey];
    NSString *savedVersion = [coder decodeObjectForKey:
                              kAppVersionRestorationKey];
    return ([version isEqualToString:savedVersion] &&
            [savedBookmark isEqualToString:kAPIBookmark]);
}

- (void)application:(UIApplication *)application
didDecodeRestorableStateWithCoder:(NSCoder *)coder
{
    api = [coder decodeObjectForKey:kAPIRestorationKey];
}

- (void)application:(UIApplication *)application
willEncodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeObject:api forKey:kAPIRestorationKey];
}

@end
