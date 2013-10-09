//
//  CSHomePageViewController.m
//  SimplyShop
//
//  Created by Will Harris on 03/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSHomePageViewController.h"
#import "CSRetailerSelectionViewController.h"
#import "CSSliceRetailersCell.h"
#import "CSProductSummariesCell.h"
#import "CSCategoriesCell.h"
#import "CSProductDetailViewController.h"
#import "CSPriceContext.h"
#import "CSProductGridViewController.h"
#import <CSApi/CSAPI.h>
#import "CSSearchBarController.h"
#import "CSPlaceholderView.h"
#import "UIView+CSKeyboardAwareness.h"
#import "CSProductGridDataSource.h"
#import "CSProductSearchState.h"
#import "CSProductSearchStateTitleFormatter.h"
#import "CSRefineBarView.h"
#import "CSRefineBarController.h"

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
    if ( ! cell) {
        return nil;
    }
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
    CSSearchBarControllerDelegate,
    CSSliceRetailersCellDelegate,
    CSProductSummariesCellDelegate,
    CSCategoriesCellDelegate,
    UICollectionViewDelegate,
    CSRefineBarControllerDelegate
>

@property (strong, nonatomic) CSProductSummariesCell *topProductsCell;
@property (strong, nonatomic) CSSliceRetailersCell *favoriteStoresCell;
@property (strong, nonatomic) CSCategoriesCell *categoriesCell;
@property (strong, nonatomic) NSArray *rows;

@property (strong, nonatomic) NSObject<CSProductList> *products;
@property (strong, nonatomic) NSObject<CSNarrowList> *categoryNarrows;
@property (strong, nonatomic) NSObject<CSNarrowList> *retailerNarrows;

@property (strong, nonatomic) id<CSCategory> category;
@property (strong, nonatomic) id<CSRetailer> retailer;

@property (strong, nonatomic) id<CSProductSearchState> searchState;

@property (strong, nonatomic) CSSearchBarController *searchBarController;
@property (strong, nonatomic) id<CSAPIRequest> searchRequest;

- (void)loadModel;
- (void)reloadModel;

- (NSString *)dashboardTitle;

- (void)loadCellsFromSlice;
- (void)saveRetailerSelection:(NSSet *)selectedURLs;

- (void)setErrorState;

- (void)addSearchToNavigationBar;

- (void)loadSlice:(void (^)(BOOL success, NSError *error))callback;

@property (strong, nonatomic) id<CSLikeList> likeList;
- (void)loadLikeList:(void (^)(BOOL success, NSError *error))callback;

@property (strong, nonatomic) NSArray *selectedRetailerURLs;
- (void)loadSelectedRetailerURLs:(void (^)(BOOL success, NSError *error))callback;

@property (strong, nonatomic) NSObject<CSGroup> *group;
- (void)loadGroup:(void (^)(BOOL success, NSError *error))callback;

@property (strong, nonatomic) NSObject<CSUser> *user;
- (void)loadUser:(void (^)(BOOL success, NSError *error))callback;

@property (assign, nonatomic) BOOL wasPrepared;

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

- (void)prepareRootDashboard
{
    if (self.wasPrepared) {
        return;
    }
    
    BOOL isRoot = self.narrow == nil;
    
    self.topProductsCell = [[CSProductSummariesCell alloc]
                            initWithStyle:UITableViewCellStyleDefault
                            reuseIdentifier:nil];
    self.topProductsCell.delegate = self;
    self.topProductsCell.isRoot = isRoot;
    
    self.favoriteStoresCell = [[CSSliceRetailersCell alloc]
                               initWithStyle:UITableViewCellStyleDefault
                               reuseIdentifier:nil];
    self.favoriteStoresCell.delegate = self;
    self.favoriteStoresCell.isRoot = isRoot;
    
    self.categoriesCell = [[CSCategoriesCell alloc]
                           initWithStyle:UITableViewCellStyleDefault
                           reuseIdentifier:nil];
    self.categoriesCell.delegate = self;
    
    [self loadModel];
    self.navigationItem.title = [self dashboardTitle];
    self.wasPrepared = YES;
}

- (NSString *)dashboardTitle
{
    if ( ! self.slice) {
        return @"Loading...";
    }
    
    if (self.category) {
        if (self.retailer) {
            return [NSString stringWithFormat:@"%@ from %@",
                    self.category.name, self.retailer.name];
        } else {
            return self.category.name;
        }
    } else if (self.retailer) {
        return self.retailer.name;
    } else {
        return @"Dashboard";
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.placeholderView showLoadingView];

    [self addSearchToNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self prepareRootDashboard];
    
    if (self.rows) {
        [self.placeholderView showContentView];
    }
    [self addObserver:self forKeyPath:@"rows" options:NSKeyValueObservingOptionNew context:NULL];
    [self.view becomeAwareOfKeyboard];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self removeObserver:self forKeyPath:@"rows"];
    [self.view becomeUnawareOfKeyboard];
    [super viewDidDisappear:animated];
}

- (void)showContent
{
    if ([self.rows count] == 1) {
        self.gridDataSource.priceContext = [[CSPriceContext alloc]
                                            initWithLikeList:self.likeList
                                            retailer:self.retailer];
        
        self.gridDataSource.products = self.products;
        
        [self.gridView reloadData];
        
        if (self.products.count) {
            [self.placeholderView setContentView:self.productGrid];
            [self.placeholderView showContentView];
            self.refineBarView.hidden = NO;
        } else if (self.products == nil) {
            [self.placeholderView showLoadingView];
        } else {
            [self.placeholderView showEmptyView];
        }
    } else {
        [self.placeholderView setContentView:self.tableView];
        [self.placeholderView showContentView];
        self.refineBarView.hidden = YES;
        [self.tableView reloadData];
    }
    
    self.navigationItem.title = [self dashboardTitle];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self && [keyPath isEqualToString:@"rows"]) {
        [self showContent];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadSlice:(void (^)(BOOL, NSError *))callback
{
    if (self.slice) {
        callback(YES, nil);
        return;
    }
    
    // If no slice is loaded, try first to get it from a supplied narrow.
    if (self.narrow) {
        [self.narrow getSlice:^(id<CSSlice> result, NSError *error) {
            if (error) {
                [self setErrorState];
                return;
            }
            
            self.slice = result;
            callback(YES, nil);
        }];
        return;
    }
    
    // If no slice is loaded, and we don't have a narrow, get a slice of the
    // user's selected retailers.
    [self loadGroup:^(BOOL success, NSError *error) {
        if ( ! success) {
            callback(NO, error);
            return;
        }
        
        [self.group getLikes:^(id<CSLikeListPage> firstPage, NSError *error) {
            if (error) {
                callback(NO, error);
                return;
            }
            
            if (firstPage.count < 3) {
                [self performSegueWithIdentifier:@"showRetailerSelection"
                                          sender:self];
            }
        }];
        
        [self.group getSlice:^(id<CSSlice> slice, NSError *error) {
            if (error) {
                callback(NO, error);
                return;
            }
            
            self.slice = slice;
            callback(YES, nil);
        }];
    }];
}

- (void)loadGroup:(void (^)(BOOL, NSError *))callback
{
    if (self.group) {
        callback(YES, nil);
        return;
    }
    
    // If the group hasn't been loaded, get it from the user.
    [self loadUser:^(BOOL success, NSError *error) {
        if ( ! success) {
            callback(NO, error);
            return;
        }
        
        [self ensureFavoriteRetailersGroup:^(id<CSGroup> group,
                                             NSError *error)
        {
            if (error) {
                callback(NO, error);
                return;
            }
            
            self.group = group;
            callback(YES, nil);
        }];
    }];
}

- (void)loadUser:(void (^)(BOOL, NSError *))callback
{
    if (self.user) {
        callback(YES, nil);
        return;
    }
    
    // If the user hasn't been loaded, log in.
    [self.api login:^(id<CSUser> user, NSError *error) {
        if ( ! user) {
            callback(NO, error);
            return;
        }
        
        self.user = user;
        callback(YES, nil);
    }];
}

- (void)loadModel
{
    [self loadSlice:^(BOOL success, NSError *error) {
        if ( ! success) {
            [self setErrorState];
            return;
        }
        
        self.refineController.slice = self.slice;
        
        [self loadSelectedRetailerURLs:^(BOOL success, NSError *error) {
            if ( ! success) {
                [self setErrorState];
                return;
            }
            
            [self loadCellsFromSlice];
        }];
    }];
}

- (void)loadSelectedRetailerURLs:(void (^)(BOOL, NSError *))callback
{
    if (self.selectedRetailerURLs) {
        callback(YES, nil);
        return;
    }

    [self loadLikeList:^(BOOL success, NSError *error) {
        if ( ! success) {
            callback(NO, error);
            return;
        }
        
        id<CSLikeList> likeList = self.likeList;
        __block NSInteger urlsToGet = likeList.count;
        if (urlsToGet == 0) {
            self.selectedRetailerURLs = [NSArray array];
            callback(YES, nil);
            return;
        }
        
        NSMutableSet *urls = [NSMutableSet setWithCapacity:urlsToGet];
        for (NSInteger i = 0; i < urlsToGet; ++i) {
            [likeList getLikeAtIndex:i callback:^(id<CSLike> like,
                                                  NSError *error)
            {
                if (error) {
                    callback(NO, error);
                    return;
                }
                
                --urlsToGet;
                if (like) {
                    [urls addObject:like.likedURL];
                }
                if (urlsToGet == 0) {
                    self.selectedRetailerURLs = [urls allObjects];
                    callback(YES, nil);
                    return;
                }
            }];
        }
    }];
}


- (void)loadLikeList:(void (^)(BOOL, NSError *))callback
{
    if (self.likeList) {
        callback(YES, nil);
        return;
    }
    
    [self loadGroup:^(BOOL success, NSError *error) {
        if ( ! success) {
            callback(NO, error);
            return;
        }
        
        [self.group getLikes:^(id<CSLikeListPage> firstPage, NSError *error) {
            if (error) {
                callback(NO, error);
                return;
            }
            
            self.likeList = firstPage.likeList;
            callback(YES, nil);
        }];
    }];
}

- (void)reloadModel
{
    [self.placeholderView showLoadingView];
    self.slice = nil;
    self.selectedRetailerURLs = nil;
    self.likeList = nil;
    self.group = nil;
    [self loadModel];
}

- (void)loadCellsFromSlice
{
    [self.slice getCategoryNarrows:^(id<CSNarrowListPage> categoryNarrows,
                                     NSError *error) {
        if (error) {
            [self setErrorState];
            return;
        }
        
        NSMutableArray *rows = [[NSMutableArray alloc] initWithCapacity:3];
        
        if (self.slice.productsURL) {
            [rows addObject:[[CSHomePageRow alloc]
                             initWithCell:self.topProductsCell]];
        }
        
        if (self.slice.categoryNarrowsURL && categoryNarrows.count > 0) {
            [rows addObject:[[CSHomePageRow alloc]
                             initWithCell:self.categoriesCell]];
        }
        
        if (self.slice.retailerNarrowsURL) {
            [rows addObject:[[CSHomePageRow alloc]
                             initWithCell:self.favoriteStoresCell]];
        }
        
        self.rows = [NSArray arrayWithArray:rows];
    }];
    
    [self.slice getFiltersByCategory:^(id<CSCategory> category,
                                       NSError *error)
    {
        if (error) {
            [self setErrorState];
            return;
        }
        
        [self.slice getFiltersByRetailer:^(id<CSRetailer> retailer,
                                           NSError *error)
        {
            if (error) {
                [self setErrorState];
                return;
            }
            
            self.retailer = retailer;
            self.category = category;
            
            self.navigationItem.title = [self dashboardTitle];
        }];
    }];

    [self.slice getProducts:^(id<CSProductListPage> firstPage,
                              NSError *error)
     {
         if (error) {
             [self setErrorState];
             return;
         }
         
         self.products = firstPage.productList;
         self.topProductsCell.products = self.products;
         [self showContent];
     }];
    
    [self.slice getCategoryNarrows:^(id<CSNarrowListPage> result, NSError *error)
     {
         if (error) {
             [self setErrorState];
             return;
         }
         
         self.categoryNarrows = result.narrowList;
         self.categoriesCell.narrows = self.categoryNarrows;
     }];
    
    [self.slice getRetailerNarrows:^(id<CSNarrowListPage> result, NSError *error) {
        if (error) {
            [self setErrorState];
            return;
        }
        
        self.retailerNarrows = result.narrowList;
        self.favoriteStoresCell.narrows = self.retailerNarrows;
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

- (void)sliceRetailersCell:(CSSliceRetailersCell *)cell
   failedToLoadRetailerURL:(NSURL *)retailerURL
                     error:(NSError *)error
{
    if ([error.userInfo[@"NSHTTPPropertyStatusCodeKey"] isEqual:@(404)]) {
        [self showMissingRetailer:retailerURL];
        
        // TODO: remove retailer at retailerURL from likes.
        
        return;
    }
    
    [self setErrorState];
}

- (void)setErrorState
{
    self.placeholderView.errorViewDetail = @"Failed to communicate with the server.";
    [self.placeholderView showErrorView];
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
    [self.placeholderView showLoadingView];
    [self loadModel];
}

- (void)prepareForShowRetailerSelectionForSegue:(UIStoryboardSegue *)segue
                                         sender:(id)sender
{
    UINavigationController *nav = segue.destinationViewController;
    CSRetailerSelectionViewController *vc = (id) nav.topViewController;
    vc.api = self.api;
    NSArray *selectedURLs = self.selectedRetailerURLs;
    vc.selectedRetailerURLs = [NSMutableSet setWithArray:selectedURLs];
}

- (void)prepareForShowProductSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CSProductDetailViewController *vc = (id) segue.destinationViewController;
    if (self.retailer) {
        vc.priceContext = [[CSPriceContext alloc] initWithLikeList:self.likeList
                                                          retailer:self.retailer];
    } else {
        vc.priceContext = [[CSPriceContext alloc] initWithLikeList:self.likeList];
    }
    
    NSDictionary *address = sender;
    if ([address[@"collection"] isEqualToString:@"grid"]) {
        NSInteger index = [address[@"index"] integerValue];
        [vc setProductList:self.gridDataSource.products index:index];
    } else {
        CSProductSummariesCell *cell = address[@"cell"];
        id<CSProductList> list = cell.products;
        NSInteger index = [address[@"index"] integerValue];
        [vc setProductList:list index:index];
    }
}

- (void)prepareForShowTopProductsGridSegue:(UIStoryboardSegue *)segue
                                    sender:(id)sender
{
    NSString *q = nil;
    if ([sender isKindOfClass:[UISearchBar class]]) {
        UISearchBar *searchBar = sender;
        q = searchBar.text;
    }
    
    NSAssert(self.likeList, nil);
    NSAssert(self.group || self.category || self.retailer, nil);
    CSProductGridViewController *vc = (id) segue.destinationViewController;
    self.searchState = [CSProductSearchState stateWithSlice:self.slice
                                                   retailer:self.retailer
                                                   category:self.category
                                                      likes:self.likeList
                                                      query:q];
    vc.searchState = self.searchState;
    vc.dataSource.priceContext = [[CSPriceContext alloc]
                                  initWithLikeList:self.likeList
                                  retailer:self.retailer];

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
                [self reloadModel];
            }
            for (id<CSLike> like in likesToDelete) {
                [like remove:^(BOOL success, NSError *error) {
                    if (error) {
                        [self setErrorState];
                        return;
                    }
                    
                    --changesToApply;
                    if (changesToApply == 0) {
                        [self reloadModel];
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
                        [self reloadModel];
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
                              @"index": @(index),
                              @"collection": @"row"};
    [self performSegueWithIdentifier:@"showProduct" sender:address];
}

- (void)productSummariesCellDidTapSeeAllButton:(CSProductSummariesCell *)cell
{
    UIView *v = [self.refineController performSelector:@selector(view)];
    v.backgroundColor = [UIColor redColor];
    
    [self performSegueWithIdentifier:@"showTopProductsGrid" sender:cell];
}

- (void)sliceRetailersCell:(CSSliceRetailersCell *)cell
           didSelectNarrow:(id<CSNarrow>)narrow
{
    CSHomePageViewController *vc =
    [self.storyboard instantiateViewControllerWithIdentifier:
     @"CSHomePageViewController"];
    vc.api = self.api;
    vc.narrow = narrow;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)sliceRetailersCellDidTapChooseButton:(CSSliceRetailersCell *)cell
{
    [self performSegueWithIdentifier:@"changeRetailerSelection" sender:cell];
}

- (void)categoriesCell:(CSCategoriesCell *)cell
       didSelectNarrow:(id<CSNarrow>)narrow
               atIndex:(NSUInteger)index
{
    CSHomePageViewController *vc =
    [self.storyboard instantiateViewControllerWithIdentifier:
     @"CSHomePageViewController"];
    vc.api = self.api;
    vc.narrow = narrow;
    [self.navigationController pushViewController:vc animated:YES];
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

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<CSHomePageRow> row = self.rows[indexPath.row];
    return [row height];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *address = @{@"index": @(indexPath.row), @"collection": @"grid"};
    [self performSegueWithIdentifier:@"showProduct" sender:address];
}

#pragma mark - Search Bar

- (void)addSearchToNavigationBar
{
    self.searchBarController = [[CSSearchBarController alloc]
                                initWithPlaceholder:@"Search Products"
                                navigationItem:self.navigationItem];
    self.searchBarController.delegate = self;
}

- (void)loadSearchState:(id<CSProductSearchState>)searchState
{
    NSString *searchText = searchState.query;
    id formatter = [CSProductSearchStateTitleFormatter instance];
    self.navigationItem.title = [searchState titleWithFormatter:formatter];
    
    self.gridDataSource.priceContext = [[CSPriceContext alloc] initWithLikeList:self.likeList retailer:self.retailer];
    
    [self.placeholderView showLoadingView];
    [self.searchRequest cancel];
    self.searchRequest = [searchState getProducts:^(id<CSProductList> products, NSError *error) {
        self.searchRequest = nil;
        if (searchText != self.searchBarController.query &&
            ! [searchText isEqualToString:self.searchBarController.query]) {
            return;
        }
        
        if (error) {
            [self.placeholderView showErrorView];
            return;
        }
        
        self.gridDataSource.products = products;
        [self.gridView reloadData];
        if (products.count) {
            self.searchState = searchState;
            [self.placeholderView setContentView:self.productGrid];
            self.refineBarView.hidden = NO;
            [self.placeholderView showContentView];
        } else {
            [self.placeholderView showEmptyView];
            self.refineBarView.hidden = NO;
        }
    }];

}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSString *query = searchBar.text;
    if ( ! [query length]) {
        query = nil;
    }
    
    if ( ! query) {
        [self showContent];
        return;
    }
    
    id<CSProductSearchState> searchState = [CSProductSearchState
                                            stateWithSlice:self.slice
                                            retailer:self.retailer
                                            category:self.category
                                            likes:self.likeList
                                            query:query];

    [self loadSearchState:searchState];
}

#pragma mark - CSRefineBarControllerDelegate

- (void)refineBarController:(CSRefineBarController *)controller
didStartLoadingSliceForNarrow:(id<CSNarrow>)narrow
{
    [self.placeholderView showLoadingView];
}

- (void)refineBarController:(CSRefineBarController *)controller
      didFinishLoadingSlice:(id<CSSlice>)slice
                  forNarrow:(id<CSNarrow>)narrow
{
    id<CSProductSearchState> searchState;
    if (self.searchState) {
        searchState = [self.searchState stateWithSlice:slice];
    } else {
        searchState = [CSProductSearchState stateWithSlice:self.slice
                                                  retailer:self.retailer
                                                  category:self.category
                                                     likes:self.likeList
                                                     query:nil];
    }
    [self loadSearchState:searchState];
}

- (void)refineBarController:(CSRefineBarController *)controller
           didFailWithError:(NSError *)error
      loadingSliceForNarrow:(id<CSNarrow>)narrow
{
    [self.placeholderView showEmptyView];
}

#pragma mark - Restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    [coder encodeObject:self.api forKey:@"api"];
    [coder encodeObject:self.selectedRetailerURLs forKey:@"selectedRetailerURLs"];
    [coder encodeObject:self.narrow forKey:@"narrow"];
    [coder encodeObject:self.likeList forKey:@"likeList"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    self.api = [coder decodeObjectForKey:@"api"];
    self.selectedRetailerURLs = [coder decodeObjectForKey:@"selectedRetailerURLs"];
    self.narrow = [coder decodeObjectForKey:@"narrow"];
    self.likeList = [coder decodeObjectForKey:@"likeList"];
    [self prepareRootDashboard];
}

@end
