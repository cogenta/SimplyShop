//
//  CSHomePageViewController.m
//  SimplyShop
//
//  Created by Will Harris on 03/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSHomePageViewController.h"
#import "CSRetailerView.h"
#import "CSRetailerSelectionViewController.h"
#import <CSApi/CSAPI.h>

@interface CSHomePageViewController ()

@property (strong, nonatomic) NSObject<CSLikeList> *retailerLikes;
@property (strong, nonatomic) NSObject<CSUser> *user;

- (void)reloadRetailers;

@end

@implementation CSHomePageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.retailersSwipeView.truncateFinalPage = YES;
    self.retailersSwipeView.pagingEnabled = NO;
    
    [self.api login:^(id<CSUser> user, NSError *error) {
        if (error) {
            // TODO: handle erro
            return;
        }
        
        self.user = user;
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addObserver:self
           forKeyPath:@"user"
              options:NSKeyValueObservingOptionNew
              context:NULL];
    [self addObserver:self
           forKeyPath:@"retailerLikes"
              options:NSKeyValueObservingOptionNew
              context:NULL];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeObserver:self forKeyPath:@"retailerLikes"];
    [self removeObserver:self forKeyPath:@"user"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"user"]) {
        [self reloadRetailers];
        return;
    }
    
    if ([keyPath isEqualToString:@"retailerLikes"]) {
        [self.retailersSwipeView reloadData];
        return;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadRetailers
{
    [self.user getGroupsWithReference:@"favoriteRetailers"
                             callback:^(id<CSGroupListPage> firstPage,
                                        NSError *error)
    {
        if (error) {
            // TODO: handle error
            return;
        }
        
        NSObject<CSGroupList> *groups = firstPage.groupList;
        if (groups.count == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"showRetailerSelection"
                                          sender:self];
            });
            return;
        }
        
        [groups getGroupAtIndex:0
                       callback:^(id<CSGroup> group, NSError *error)
        {
            if (error) {
                // TODO: handle error
                return;
            }
            
            [group getLikes:^(id<CSLikeListPage> firstPage, NSError *error)
            {
                if (error) {
                    // TODO: handle error
                    return;
                }
                
                self.retailerLikes = firstPage.likeList;
            }];
        }];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showRetailerSelection"]) {
        UINavigationController *nav = segue.destinationViewController;
        CSRetailerSelectionViewController *vc = (id) nav.topViewController;
        vc.api = self.api;
        return;
    }
}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return self.retailerLikes.count;
}

- (UIView *)swipeView:(SwipeView *)swipeView
   viewForItemAtIndex:(NSInteger)index
          reusingView:(UIView *)view
{
    CSRetailerView *retailerView = nil;
    if (view) {
        retailerView = (CSRetailerView *)view;
    }
    
    if ( ! retailerView) {
        retailerView = [[[NSBundle mainBundle]
                         loadNibNamed:@"CSRetailerView"
                         owner:nil
                         options:nil]
                        objectAtIndex:0];
    }
    
    retailerView.retailerNameLabel.text = [NSString stringWithFormat:@"%d", index];
    return retailerView;
}

- (void)doneInitialRetailerSelection:(UIStoryboardSegue *)segue
{
    CSRetailerSelectionViewController *modal = segue.sourceViewController;
    // TODO: present saving state
    
    [self.api login:^(id<CSUser> user, NSError *error) {
        if (error) {
            // TODO: handle error
            return;
        }
        
        [user createGroupWithChange:^(id<CSMutableGroup> mutableGroup) {
            mutableGroup.reference = @"favoriteRetailers";
        } callback:^(id<CSGroup> group, NSError *error) {
            if (error) {
                // TODO: handle error
                return;
            }
            
            __block NSUInteger likesToAdd = modal.selectedRetailerURLs.count;
            for (NSURL *url in modal.selectedRetailerURLs) {
                [group createLikeWithChange:^(id<CSMutableLike> like) {
                    like.likedURL = url;
                } callback:^(id<CSLike> like, NSError *error) {
                    --likesToAdd;
                    // TODO: handle error
                    
                    if (likesToAdd == 0) {
                        [self reloadRetailers];
                    }
                }];
            }
        }];
    }];

}

@end
