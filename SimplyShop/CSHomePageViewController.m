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
#import "CSCategoriesCell.h"
#import "CSProductDetailViewController.h"
#import "CSPriceContext.h"
#import "CSProductGridViewController.h"
#import <CSApi/CSAPI.h>

@protocol CSHomePageRow <NSObject>
- (UITableViewCell *)cellForTableView:(UITableView *)tableView;
- (CGFloat)height;
@end

@interface CSHomePageRow : NSObject <CSHomePageRow>

@property (strong, nonatomic) UITableViewCell *cell;

- (id)initWithCell:(UITableViewCell *)cell;

@end

@implementation CSHomePageRow

- (id)initWithCell:(UITableViewCell *)cell
{
    self = [super init];
    if (self) {
        self.cell = cell;
    }
    return self;
}

- (UITableViewCell *)cellForTableView:(UITableView *)tableView
{
    return self.cell;
}

- (CGFloat)height
{
    return self.cell.bounds.size.height;
}

@end

@interface CSHomePageViewController () <
    UIAlertViewDelegate,
    CSFavoriteStoresCellDelegate,
    CSProductSummariesCellDelegate,
    CSCategoriesCellDelegate
>

@property (strong, nonatomic) CSProductSummariesCell *topProductsCell;
@property (strong, nonatomic) CSFavoriteStoresCell *favoriteStoresCell;
@property (strong, nonatomic) CSCategoriesCell *categoriesCell;
@property (strong, nonatomic) NSArray *rows;

@property (strong, nonatomic) NSObject<CSUser> *user;
@property (strong, nonatomic) NSObject<CSProductSummaryList> *topProductSummaries;
@property (strong, nonatomic) NSObject<CSLikeList> *likeList;
@property (strong, nonatomic) NSObject<CSGroup> *group;

- (void)loadRetailers;
- (void)loadCellsFromGroup:(NSObject<CSGroup> *)group;
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
    
    self.topProductsCell = [[CSProductSummariesCell alloc]
                            initWithStyle:UITableViewCellStyleDefault
                            reuseIdentifier:nil];
    self.topProductsCell.delegate = self;
    
    self.favoriteStoresCell = [[CSFavoriteStoresCell alloc]
                               initWithStyle:UITableViewCellStyleDefault
                               reuseIdentifier:nil];
    self.favoriteStoresCell.delegate = self;
    
    self.categoriesCell = [[CSCategoriesCell alloc]
                           initWithStyle:UITableViewCellStyleDefault
                           reuseIdentifier:nil];
    self.categoriesCell.delegate = self;
    
    self.favoriteStoresCell.api = self.api;
    
    self.rows = @[[[CSHomePageRow alloc] initWithCell:self.topProductsCell],
                  [[CSHomePageRow alloc] initWithCell:self.categoriesCell],
                  [[CSHomePageRow alloc] initWithCell:self.favoriteStoresCell]];
    
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

- (void)loadCellsFromGroup:(NSObject<CSGroup> *)group
{
    self.group = group;
    [group getProductSummaries:^(id<CSProductSummaryListPage> firstPage,
                                 NSError *error) {
        if (error) {
            [self setErrorState];
            return;
        }
        
        self.topProductSummaries = firstPage.productSummaryList;
        self.topProductsCell.productSummaries = firstPage.productSummaryList;
    }];
    
    [group getCategories:^(id<CSCategoryListPage> firstPage, NSError *error) {
        if (error) {
            [self setErrorState];
            return;
        }
        
        self.categoriesCell.categories = firstPage.categoryList;
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
        
        [self loadCellsFromGroup:group];
        
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

- (void)prepareForShowRetailerSelectionForSegue:(UIStoryboardSegue *)segue
                                         sender:(id)sender
{
    UINavigationController *nav = segue.destinationViewController;
    CSRetailerSelectionViewController *vc = (id) nav.topViewController;
    vc.api = self.api;
    NSArray *selectedURLs = self.favoriteStoresCell.selectedRetailerURLs;
    vc.selectedRetailerURLs = [NSMutableSet setWithArray:selectedURLs];
}

- (void)prepareForShowProductSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CSProductDetailViewController *vc = (id) segue.destinationViewController;
    vc.priceContext = [[CSPriceContext alloc] initWithLikeList:self.likeList];
    
    NSDictionary *address = sender;
    CSProductSummariesCell *cell = address[@"cell"];
    id<CSProductSummaryList> list = cell.productSummaries;
    NSInteger index = [address[@"index"] integerValue];
    [vc setProductSummaryList:list index:index];
}

- (void)prepareForShowTopProductsGridSegue:(UIStoryboardSegue *)segue
                                    sender:(id)sender
{
    NSAssert(self.likeList, nil);
    NSAssert(self.group, nil);
    CSProductGridViewController *vc = (id) segue.destinationViewController;
    [vc setGroup:self.group likes:self.likeList];
}

- (void)prepareForShowRetailerProductsGridSegue:(UIStoryboardSegue *)segue
                                         sender:(id)sender
{
    NSAssert(self.likeList, nil);
    
    NSDictionary *address = sender;
    id<CSRetailer> retailer = address[@"retailer"];
    
    CSProductGridViewController *vc = (id) segue.destinationViewController;
    [vc setRetailer:retailer likes:self.likeList];
}

- (void)prepareForShowCategoryProductsGridSegue:(UIStoryboardSegue *)segue
                                         sender:(id)sender
{
    NSAssert(self.likeList, nil);
    
    NSDictionary *address = sender;
    id<CSCategory> category = address[@"category"];
    
    CSProductGridViewController *vc = (id) segue.destinationViewController;
    [vc setCategory:category likes:self.likeList];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showRetailerSelection"] ||
        [segue.identifier isEqualToString:@"changeRetailerSelection"]) {
        [self prepareForShowRetailerSelectionForSegue:segue sender:sender];
        return;
    }
    
    if ([segue.identifier isEqualToString:@"showProduct"]) {
        [self prepareForShowProductSegue:segue sender:sender];
        return;
    }
    
    if ([segue.identifier isEqualToString:@"showTopProductsGrid"]) {
        [self prepareForShowTopProductsGridSegue:segue sender:sender];
        return;
    }
    
    if ([segue.identifier isEqualToString:@"showRetailerProductsGrid"]) {
        [self prepareForShowRetailerProductsGridSegue:segue sender:sender];
        return;
    }
    
    if ([segue.identifier isEqualToString:@"showCategoryProductsGrid"]) {
        [self prepareForShowCategoryProductsGridSegue:segue sender:sender];
        return;
    }
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

- (void)ensureFavoriteRetailersLikeList:(void (^)(id<CSLikeList> likeList,
                                                  id<CSGroup> group,
                                                  NSError *error))callback
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

    [self ensureFavoriteRetailersLikeList:^(id<CSLikeList> likeList,
                                            id<CSGroup> group,
                                            NSError *error)
    {
        if (error) {
            [self setErrorState];
            return;
        }
        
        __block NSInteger likesToCheck = likeList.count;
        void (^applyChanges)() = ^{
            __block NSInteger changesToApply = ([likesToDelete count] +
                                                [urlsToAdd count]);
            if (changesToApply == 0) {
                self.favoriteStoresCell.selectedRetailerURLs = [selectedURLs allObjects];
                [self loadRetailers];
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
                        [self loadRetailers];
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
                        [self loadRetailers];
                    }
                }];
            }
        };
        
        if (likeList.count == 0) {
            applyChanges();
        }
        
        for (NSInteger i = 0 ; i < likeList.count; ++i) {
            [likeList getLikeAtIndex:i callback:^(id<CSLike> like,
                                                  NSError *error) {
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

- (void)productSummariesCellDidTapSeeAllButton:(CSProductSummariesCell *)cell
{
    [self performSegueWithIdentifier:@"showTopProductsGrid" sender:cell];
}

- (void)favoriteStoresCell:(CSFavoriteStoresCell *)cell
         didSelectRetailer:(id<CSRetailer>)retailer
                     index:(NSUInteger)index
{
    NSDictionary *address = @{@"cell": cell,
                              @"index": @(index),
                              @"retailer": retailer};
    [self performSegueWithIdentifier:@"showRetailerProductsGrid"
                              sender:address];
}

- (void)favoriteStoresCellDidTapChooseButton:(CSFavoriteStoresCell *)cell
{
    [self performSegueWithIdentifier:@"changeRetailerSelection" sender:cell];
}

- (void)categoriesCell:(CSCategoriesCell *)cell didSelectItemAtIndex:(NSUInteger)index
{
    [cell.categories getCategoryAtIndex:index callback:^(id<CSCategory> cat,
                                                         NSError *error) {
        NSDictionary *address = @{@"cell": cell,
                                  @"index": @(index),
                                  @"category": cat};
        [self performSegueWithIdentifier:@"showCategoryProductsGrid"
                                  sender:address];
    }];
}

- (IBAction)doneShowProduct:(UIStoryboardSegue *)segue
{
    [segue.destinationViewController dismissViewControllerAnimated:YES
                                                        completion:NULL];
}

- (IBAction)doneShowProductsGrid:(UIStoryboardSegue *)segue
{
    // Do nothing
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [(id<CSHomePageRow>) self.rows[indexPath.row]
            cellForTableView:tableView];
}

#pragma make - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<CSHomePageRow> row = self.rows[indexPath.row];
    return [row height];
}

@end
