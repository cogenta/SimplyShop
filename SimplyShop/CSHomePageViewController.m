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
@property (strong, nonatomic) NSSet *selectedRetailerURLs;

- (void)reloadRetailers;
- (void)saveRetailerSelection:(NSSet *)selectedURLs;

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
        
        [self ensureFavoriteRetailersLikeList:^(id<CSLikeList> likeList, id<CSGroup> group, NSError *error) {
            if (likeList.count < 3) {
                [self performSegueWithIdentifier:@"showRetailerSelection"
                                          sender:self];
            }
        }];
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
    [self ensureFavoriteRetailersLikeList:^(id<CSLikeList> likeList, id<CSGroup> group, NSError *error)
    {
        if (error) {
            // TODO: handle error
            return;
        }
        
        __block NSInteger urlsToGet = likeList.count;
        if (urlsToGet == 0) {
            self.selectedRetailerURLs = [NSSet set];
            self.retailerLikes = likeList;
        }
        
        NSMutableSet *urls = [NSMutableSet setWithCapacity:urlsToGet];
        for (NSInteger i = 0; i < urlsToGet; ++i) {
            [likeList getLikeAtIndex:i callback:^(id<CSLike> like, NSError *error)
            {
                --urlsToGet;
                if (like) {
                    [urls addObject:like.likedURL];
                }
                if (urlsToGet == 0) {
                    self.selectedRetailerURLs = [NSSet setWithSet:urls];
                    self.retailerLikes = likeList;
                }
            }];
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showRetailerSelection"] ||
        [segue.identifier isEqualToString:@"changeRetailerSelection"]) {
        UINavigationController *nav = segue.destinationViewController;
        CSRetailerSelectionViewController *vc = (id) nav.topViewController;
        vc.api = self.api;
        vc.selectedRetailerURLs = [self.selectedRetailerURLs mutableCopy];
        
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

- (IBAction)didTapChooseRetailersButton:(id)sender {
    [self performSegueWithIdentifier:@"changeRetailerSelection" sender:nil];
}

- (void)doneInitialRetailerSelection:(UIStoryboardSegue *)segue
{
    CSRetailerSelectionViewController *modal = segue.sourceViewController;
    // TODO: present saving state
    
    [self saveRetailerSelection:modal.selectedRetailerURLs];
}


- (void)ensureFavoriteRetailersGroup:(void (^)(id<CSGroup> group, NSError *error))callback
{
    [self.user getGroupsWithReference:@"favoriteRetailers"
                             callback:^(id<CSGroupListPage> firstPage,
                                        NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         NSObject<CSGroupList> *groups = firstPage.groupList;
         if (groups.count == 0) {
             [self.user createGroupWithChange:^(id<CSMutableGroup> mutableGroup) {
                 mutableGroup.reference = @"favoriteRetailers";
             } callback:callback];
             return;
         }
         
         [groups getGroupAtIndex:0 callback:callback];
     }];
}

- (void)ensureFavoriteRetailersLikeList:(void (^)(id<CSLikeList> likeList, id<CSGroup> group, NSError *error))callback
{
    [self ensureFavoriteRetailersGroup:^(id<CSGroup> group, NSError *error) {
        if (error) {
            callback(nil, nil, error);
            return;
        }
        
        [group getLikes:^(id<CSLikeListPage> firstPage, NSError *error) {
            if (error) {
                callback(nil, group, error);
                return;
            }
            
            callback(firstPage.likeList, group, nil);
        }];
    }];
}

- (IBAction)doneChangeRetailerSelection:(UIStoryboardSegue *)segue
{
    CSRetailerSelectionViewController *modal = segue.sourceViewController;
    // TODO: present saving state
    
    [self saveRetailerSelection:modal.selectedRetailerURLs];
}

- (void)saveRetailerSelection:(NSSet *)selectedURLs
{
    NSMutableSet *urlsToAdd = [NSMutableSet setWithSet:selectedURLs];
    NSMutableArray *likesToDelete = [NSMutableArray array];

    [self ensureFavoriteRetailersLikeList:^(id<CSLikeList> likeList, id<CSGroup> group, NSError *error)
    {
        if (error) {
            // TODO: handle error
            return;
        }
        
        __block NSInteger likesToCheck = likeList.count;
        void (^applyChanges)() = ^{
            __block NSInteger changesToApply = [likesToDelete count] + [urlsToAdd count];
            for (id<CSLike> like in likesToDelete) {
                [like remove:^(BOOL success, NSError *error) {
                    // TODO: handle error and failure
                    --changesToApply;
                    if (changesToApply == 0) {
                        self.selectedRetailerURLs = [NSSet setWithSet:selectedURLs];
                        self.retailerLikes = likeList;
                        [self reloadRetailers];
                    }
                }];
            }
            
            for (NSURL *url in urlsToAdd) {
                [group createLikeWithChange:^(id<CSMutableLike> like) {
                    like.likedURL = url;
                } callback:^(id<CSLike> like, NSError *error) {
                    // TODO: handle error
                    --changesToApply;
                    if (changesToApply == 0) {
                        self.selectedRetailerURLs = [NSSet setWithSet:selectedURLs];
                        self.retailerLikes = likeList;
                        [self reloadRetailers];
                    }
                }];
            }
        };
        
        if (likeList.count == 0) {
            applyChanges();
        }
        
        for (NSInteger i = 0 ; i < likeList.count; ++i) {
            [likeList getLikeAtIndex:i callback:^(id<CSLike> like, NSError *error) {
                // TODO: handle error
                if (like) {
                    NSURL *url = like.likedURL;
                    if ([urlsToAdd containsObject:url]) {
                        [urlsToAdd removeObject:url];
                    }
                    
                    if ( ! [selectedURLs containsObject:url]) {
                        [likesToDelete addObject:like];
                    }
                }
                --likesToCheck;
                
                if (likesToCheck == 0) {
                    applyChanges();
                }
            }];
        }
    }];
    

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[[NSBundle mainBundle] loadNibNamed:@"CSRetailersHeaderView" owner:nil options:nil] objectAtIndex:0];
}

@end
