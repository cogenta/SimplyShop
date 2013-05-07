//
//  CSHomePageViewController.m
//  SimplyShop
//
//  Created by Will Harris on 03/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSHomePageViewController.h"
#import "CSRetailerSelectionViewController.h"
#import "CSFavoriteStoresCell.h"
#import "CSProductSummariesCell.h"
#import "CSProductDetailViewController.h"
#import "CSPriceContext.h"
#import <CSApi/CSAPI.h>

@interface CSHomePageViewController () <
    UIAlertViewDelegate,
    CSFavoriteStoresCellDelegate,
    CSProductSummariesCellDelegate
>

@property (strong, nonatomic) NSObject<CSUser> *user;
@property (strong, nonatomic) NSObject<CSProductSummaryList> *topProductSummaries;
@property (strong, nonatomic) NSObject<CSLikeList> *likeList;

- (void)loadRetailers;
- (void)loadTopProductSummariesFromGroup:(NSObject<CSGroup> *)group;
- (void)saveRetailerSelection:(NSSet *)selectedURLs;

- (void)loadEverything;
- (void)setErrorState;

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
    self.favoriteStoresCell.api = self.api;
    
    [self loadEverything];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didLoadRetailers
{
    if ([self.favoriteStoresCell.selectedRetailerURLs count] < 3) {
        [self performSegueWithIdentifier:@"showRetailerSelection" sender:self];
    }
}

- (void)loadEverything
{
    [self.api login:^(id<CSUser> user, NSError *error) {
        if (error) {
            [self setErrorState];
            return;
        }
        
        self.user = user;
        [self loadRetailers];
    }];
}

- (void)loadTopProductSummariesFromGroup:(NSObject<CSGroup> *)group
{
    [group getProductSummaries:^(id<CSProductSummaryListPage> firstPage,
                                 NSError *error) {
        if (error) {
            [self setErrorState];
            return;
        }
        
        self.topProductSummaries = firstPage.productSummaryList;
        self.topProductsCell.productSummaries = firstPage.productSummaryList;
    }];
}

- (void)loadRetailers
{
    [self ensureFavoriteRetailersLikeList:^(id<CSLikeList> likeList, id<CSGroup> group, NSError *error)
    {
        if (error) {
            [self setErrorState];
            return;
        }
        
        self.likeList = likeList;
        
        [self loadTopProductSummariesFromGroup:group];
        
        __block NSInteger urlsToGet = likeList.count;
        if (urlsToGet == 0) {
            self.favoriteStoresCell.selectedRetailerURLs = [NSArray array];
            [self didLoadRetailers];
            return;
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
                    self.favoriteStoresCell.selectedRetailerURLs = [urls allObjects];
                    [self didLoadRetailers];
                }
            }];
        }
    }];
}

- (void)showMissingRetailer:(NSURL *)retailerURL
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Store Gone"
                                                    message:@"One of your favorite stores cannot be found on the server and will be removed from your favorites."
                                                   delegate:self
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)favoriteStoresCell:(CSFavoriteStoresCell *)cell
   failedToLoadRetailerURL:(NSURL *)retailerURL
                     error:(NSError *)error
{
    if ([error.userInfo[@"NSHTTPPropertyStatusCodeKey"] isEqual:@(404)]) {
        [self showMissingRetailer:retailerURL];
        
        NSMutableSet *retailerSet = [NSMutableSet setWithArray:cell.selectedRetailerURLs];
        [retailerSet removeObject:retailerURL];
        [self saveRetailerSelection:retailerSet];
        
        return;
    }
    
    [self setErrorState];
}

- (void)setErrorState
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Failed to communicate with the server."
                                                   delegate:self
                                          cancelButtonTitle:@"Retry"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self loadEverything];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showRetailerSelection"] ||
        [segue.identifier isEqualToString:@"changeRetailerSelection"]) {
        UINavigationController *nav = segue.destinationViewController;
        CSRetailerSelectionViewController *vc = (id) nav.topViewController;
        vc.api = self.api;
        vc.selectedRetailerURLs = [NSMutableSet setWithArray:self.favoriteStoresCell.selectedRetailerURLs];
        
        return;
    }
    
    if ([segue.identifier isEqualToString:@"showProduct"]) {
        CSProductDetailViewController *vc = (id) segue.destinationViewController;
        vc.priceContext = [[CSPriceContext alloc] initWithLikeList:self.likeList];
        
        NSDictionary *address = sender;
        CSProductSummariesCell *cell = address[@"cell"];
        id<CSProductSummaryList> list = cell.productSummaries;
        NSInteger index = [address[@"index"] integerValue];
        [list
         getProductSummaryAtIndex:index
         callback:^(id<CSProductSummary> result, NSError *error)
        {
            if (error) {
                [self setErrorState];
                [vc performSegueWithIdentifier:@"doneShowProduct" sender:self];
                return;
            }
            vc.productSummary = result;
            [result getProduct:^(id<CSProduct> product, NSError *error) {
                if (error) {
                    [self setErrorState];
                    [vc performSegueWithIdentifier:@"doneShowProduct" sender:self];
                    return;
                }
                vc.product = product;
            }];
        }];

        return;
    }
}


- (IBAction)didTapChooseRetailersButton:(id)sender {
    [self performSegueWithIdentifier:@"changeRetailerSelection" sender:nil];
}

- (IBAction)didTapSeeAllTopProductsButton:(id)sender {
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
            [self setErrorState];
            return;
        }
        
        __block NSInteger likesToCheck = likeList.count;
        void (^applyChanges)() = ^{
            __block NSInteger changesToApply = [likesToDelete count] + [urlsToAdd count];
            if (changesToApply == 0) {
                self.favoriteStoresCell.selectedRetailerURLs = [selectedURLs allObjects];
                [self loadTopProductSummariesFromGroup:group];
            }
            for (id<CSLike> like in likesToDelete) {
                [like remove:^(BOOL success, NSError *error) {
                    if (error) {
                        [self setErrorState];
                        return;
                    }
                    
                    --changesToApply;
                    if (changesToApply == 0) {
                        self.favoriteStoresCell.selectedRetailerURLs = [selectedURLs allObjects];
                        [self loadTopProductSummariesFromGroup:group];
                    }
                }];
            }
            
            for (NSURL *url in urlsToAdd) {
                [group createLikeWithChange:^(id<CSMutableLike> like) {
                    like.likedURL = url;
                } callback:^(id<CSLike> like, NSError *error) {
                    if (error) {
                        [self setErrorState];
                        return;
                    }
                    
                    --changesToApply;
                    if (changesToApply == 0) {
                        self.favoriteStoresCell.selectedRetailerURLs = [selectedURLs allObjects];
                        [self loadTopProductSummariesFromGroup:group];
                    }
                }];
            }
        };
        
        if (likeList.count == 0) {
            applyChanges();
        }
        
        for (NSInteger i = 0 ; i < likeList.count; ++i) {
            [likeList getLikeAtIndex:i callback:^(id<CSLike> like, NSError *error) {
                if (error) {
                    [self setErrorState];
                    return;
                }
                
                NSURL *url = like.likedURL;
                if ([urlsToAdd containsObject:url]) {
                    [urlsToAdd removeObject:url];
                }
                
                if ( ! [selectedURLs containsObject:url]) {
                    [likesToDelete addObject:like];
                }
                
                --likesToCheck;
                
                if (likesToCheck == 0) {
                    applyChanges();
                }
            }];
        }
    }];
}

- (void)productSummariesCell:(CSProductSummariesCell *)cell
        didSelectItemAtIndex:(NSUInteger)index
{
    NSDictionary *address = @{@"cell": cell,
                              @"index": @(index)};
    [self performSegueWithIdentifier:@"showProduct" sender:address];
}

- (void)doneShowProduct:(UIStoryboardSegue *)segue
{
    [segue.destinationViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
