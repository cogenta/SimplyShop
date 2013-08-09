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
#import "CSCategoryRetailersCell.h"
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
    CSFavoriteStoresCellDelegate,
    CSProductSummariesCellDelegate,
    CSCategoriesCellDelegate,
    CSCategoryRetailersCellDelegate,
    UICollectionViewDelegate
>

@property (strong, nonatomic) CSProductSummariesCell *topProductsCell;
@property (strong, nonatomic) CSProductSummariesCell *categoryProductsCell;
@property (strong, nonatomic) CSProductSummariesCell *retailerProductsCell;
@property (strong, nonatomic) CSFavoriteStoresCell *favoriteStoresCell;
@property (strong, nonatomic) CSCategoryRetailersCell *categoryRetailersCell;
@property (strong, nonatomic) CSCategoriesCell *categoriesCell;
@property (strong, nonatomic) NSArray *rows;

@property (strong, nonatomic) NSObject<CSUser> *user;
@property (strong, nonatomic) NSObject<CSLikeList> *likeList;
@property (strong, nonatomic) NSObject<CSGroup> *group;
@property (strong, nonatomic) NSArray *selectedRetailerURLs;

@property (strong, nonatomic) NSObject<CSProductList> *products;
@property (strong, nonatomic) NSObject<CSNarrowList> *categoryNarrows;
@property (strong, nonatomic) NSObject<CSNarrowList> *retailerNarrows;

// TODO: do we need categoryNarrows and retailerNarrows

@property (strong, nonatomic) NSObject<CSProductList> *topProducts
__attribute__((deprecated ("Use products instead")));
@property (strong, nonatomic) NSObject<CSProductList> *categoryProducts
__attribute__((deprecated ("Use products instead")));
@property (strong, nonatomic) NSObject<CSProductList> *retailerProducts
__attribute__((deprecated ("Use products instead")));
@property (strong, nonatomic) NSObject<CSCategoryList> *categories
__attribute__((deprecated ("Use categoryNarrows instead")));
@property (strong, nonatomic) NSObject<CSRetailerList> *categoryRetailers
__attribute__((deprecated ("Use retailerNarrows instead")));

@property (strong, nonatomic) CSSearchBarController *searchBarController;
@property (strong, nonatomic) id<CSAPIRequest> searchRequest;

- (void)loadRetailers;
- (void)loadCellsFromGroup:(NSObject<CSGroup> *)group;
- (void)saveRetailerSelection:(NSSet *)selectedURLs;

- (void)loadRootDashboard;
- (void)loadCategoryDashboard;
- (void)setErrorState;

- (void)addSearchToNavigationBar;

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
    
    [self loadRootDashboard];
}

- (void)prepareCategoryDashboard
{
    self.categoryProductsCell = [[CSProductSummariesCell alloc]
                                 initWithStyle:UITableViewCellStyleDefault
                                 reuseIdentifier:nil];
    self.categoryProductsCell.delegate = self;
    
    CSHomePageRow *productsRow = [[CSHomePageRow alloc]
                                  initWithCell:self.categoryProductsCell];
    
    self.categoryRetailersCell = [[CSCategoryRetailersCell alloc]
                                  initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:nil];
    self.categoryRetailersCell.delegate = self;
    
    CSHomePageRow *retailersRow = [[CSHomePageRow alloc]
                                   initWithCell:self.categoryRetailersCell];

    [self.category getImmediateSubcategories:^(id<CSCategoryListPage> result,
                                               NSError *error)
    {
        if (error) {
            [self setErrorState];
            return;
        }
        
        if (result.count > 1) {
            self.categoriesCell = [[CSCategoriesCell alloc]
                                   initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:nil];
            self.categoriesCell.delegate = self;
            CSHomePageRow *categoriesRow = [[CSHomePageRow alloc]
                                            initWithCell:self.categoriesCell];
            if (self.retailer) {
                self.rows = @[productsRow,
                              categoriesRow];
            } else {
                self.rows = @[productsRow,
                              categoriesRow,
                              retailersRow];
            }
        } else {
            if (self.retailer) {
                self.rows = @[productsRow];
            } else {
                self.rows = @[productsRow, retailersRow];
            }

        }
    }];
    
    [self loadCategoryDashboard];
}

- (void)prepareRetailerDashboard
{
    self.retailerProductsCell = [[CSProductSummariesCell alloc]
                                 initWithStyle:UITableViewCellStyleDefault
                                 reuseIdentifier:nil];
    self.retailerProductsCell.delegate = self;
    
    CSHomePageRow *productsRow = [[CSHomePageRow alloc]
                                  initWithCell:self.retailerProductsCell];
    [self.slice getCategoryNarrows:^(id<CSNarrowListPage> result, NSError *error)
    {
         if (error) {
             [self setErrorState];
             return;
         }
         
         if (result.count > 1) {
             self.categoriesCell = [[CSCategoriesCell alloc]
                                    initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:nil];
             self.categoriesCell.delegate = self;
             self.categoryNarrows = result.narrowList;
             self.categoriesCell.narrows = self.categoryNarrows;
             
             CSHomePageRow *categoriesRow = [[CSHomePageRow alloc]
                                             initWithCell:self.categoriesCell];
             self.rows = @[productsRow, categoriesRow];
         } else {
             self.rows = @[productsRow];
         }
     }];
    
    [self loadRetailerDashboard];
}

- (NSString *)dashboardTitle
{
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
    
    if (self.category) {
        [self prepareCategoryDashboard];
        if (self.retailer) {
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                     initWithTitle:self.category.name
                                                     style:UIBarButtonItemStylePlain
                                                     target:nil
                                                     action:NULL];
        }
    } else if (self.retailer) {
        [self prepareRetailerDashboard];
    } else {
        [self prepareRootDashboard];
    }
    
    self.navigationItem.title = [self dashboardTitle];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
            [self.placeholderView setContentView:self.gridView];
            [self.placeholderView showContentView];
        } else if (self.products == nil) {
            [self.placeholderView showLoadingView];
        } else {
            [self.placeholderView showEmptyView];
        }
    } else {
        [self.placeholderView setContentView:self.tableView];
        [self.placeholderView showContentView];
        [self.tableView reloadData];
    }
    
    self.navigationItem.title = [self dashboardTitle];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
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

- (void)didLoadRetailers
{
    if ([self.selectedRetailerURLs count] < 3) {
        [self performSegueWithIdentifier:@"showRetailerSelection" sender:self];
    }
}

- (void)loadModel
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

- (void)loadRootDashboard
{
    [self loadModel];
}

- (void)loadCategoryDashboard
{
    [self loadModel];
}

- (void)loadRetailerDashboard
{
    [self loadModel];
}

- (void)loadCellsFromGroup:(NSObject<CSGroup> *)group
{
    self.group = group;
    
    [self.group getSlice:^(id<CSSlice> slice, NSError *error) {
        if (error) {
            [self setErrorState];
            return;
        }
        
        self.slice = slice;
        
        [self.slice getProducts:^(id<CSProductListPage> firstPage,
                                  NSError *error)
        {
            if (error) {
                [self setErrorState];
                return;
            }
            
            self.products = firstPage.productList;
            self.topProductsCell.products = self.products;
            
            self.rows = @[[[CSHomePageRow alloc] initWithCell:self.topProductsCell],
                          [[CSHomePageRow alloc] initWithCell:self.categoriesCell],
                          [[CSHomePageRow alloc] initWithCell:self.favoriteStoresCell]];
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
    }];
}

- (void)loadCellsFromCategory:(NSObject<CSCategory> *)category
{
    [category getProducts:^(id<CSProductListPage> firstPage,
                            NSError *error) {
        if (error) {
            [self setErrorState];
            return;
        }
        
        id<CSProductList> list = firstPage.productList;
        self.categoryProducts = list;
        self.categoryProductsCell.products = list;
        [self showContent];
    }];
    
    [self.slice getCategoryNarrows:^(id<CSNarrowListPage> result,
                                     NSError *error)
    {
        if (error) {
            [self setErrorState];
            return;
        }
        
        self.categoryNarrows = result.narrowList;
        self.categoriesCell.narrows = self.categoryNarrows;
    }];
    
    [category getRetailers:^(id<CSRetailerListPage> result,
                             NSError *error) {
        if (error) {
            [self setErrorState];
            return;
        }
        
        self.categoryRetailers = result.retailerList;
        self.categoryRetailersCell.retailers = self.categoryRetailers;
    }];
}

- (void)loadCellsFromRetailer:(NSObject<CSRetailer> *)retailer
{
    [retailer getProducts:^(id<CSProductListPage> firstPage,
                            NSError *error) {
        if (error) {
            [self setErrorState];
            return;
        }
        
        id<CSProductList> list = firstPage.productList;
        self.retailerProducts = list;
        self.retailerProductsCell.products = list;
        [self showContent];
    }];
}

- (void)loadRetailers
{
    [self ensureFavoriteRetailersLikeList:^(id<CSLikeList> likeList,
                                            id<CSGroup> group,
                                            NSError *error)
    {
        if (error) {
            [self setErrorState];
            return;
        }
        
        self.likeList = likeList;
        
        if (self.category) {
            [self loadCellsFromCategory:self.category];
        } else if (self.retailer) {
            [self loadCellsFromRetailer:self.retailer];
        } else {
            [self loadCellsFromGroup:group];
            
            __block NSInteger urlsToGet = likeList.count;
            if (urlsToGet == 0) {
                self.selectedRetailerURLs = [NSArray array];
                self.favoriteStoresCell.selectedRetailerURLs = self.selectedRetailerURLs;
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
                         self.selectedRetailerURLs = [urls allObjects];
                         self.favoriteStoresCell.selectedRetailerURLs = self.selectedRetailerURLs;
                         [self didLoadRetailers];
                     }
                 }];
            }
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
    if (self.category) {
        [self loadCategoryDashboard];
    } else if (self.retailer) {
        [self loadRetailerDashboard];
    } else {
        [self loadRootDashboard];
    }
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
    if (self.category) {
        [vc setCategory:self.category likes:self.likeList query:q];
        vc.priceContext = [[CSPriceContext alloc] initWithLikeList:self.likeList
                                                          retailer:self.retailer];
    } else if (self.retailer) {
        [vc setRetailer:self.retailer likes:self.likeList query:q];
        vc.priceContext = [[CSPriceContext alloc] initWithLikeList:self.likeList
                                                          retailer:self.retailer];
    } else {
        [vc setGroup:self.group likes:self.likeList query:q];
    }
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
                self.selectedRetailerURLs = [selectedURLs allObjects];
                self.favoriteStoresCell.selectedRetailerURLs = self.selectedRetailerURLs;
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
                        self.selectedRetailerURLs = [selectedURLs allObjects];
                        self.favoriteStoresCell.selectedRetailerURLs = self.selectedRetailerURLs;
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
                        self.selectedRetailerURLs = [selectedURLs allObjects];
                        self.favoriteStoresCell.selectedRetailerURLs = self.selectedRetailerURLs;
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
                              @"index": @(index),
                              @"collection": @"row"};
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
    CSHomePageViewController *vc = [self.storyboard
                                    instantiateViewControllerWithIdentifier:
                                    @"CSHomePageViewController"];
    vc.api = self.api;
    vc.retailer = retailer;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)favoriteStoresCellDidTapChooseButton:(CSFavoriteStoresCell *)cell
{
    [self performSegueWithIdentifier:@"changeRetailerSelection" sender:cell];
}

- (void)categoriesCell:(CSCategoriesCell *)cell
     didSelectNarrow:(id<CSNarrow>)narrow
               atIndex:(NSUInteger)index
{
    [narrow getSlice:^(id<CSSlice> slice, NSError *error) {
        if (error) {
            [self setErrorState];
            return;
        }
        
        [slice getFiltersByCategory:^(id<CSCategory> category,
                                      NSError *error) {
            if (error) {
                [self setErrorState];
                return;
            }
         
            CSHomePageViewController *vc =
            [self.storyboard instantiateViewControllerWithIdentifier:
             @"CSHomePageViewController"];
            vc.api = self.api;
            vc.slice = slice;
            
            vc.retailer = self.retailer;
            vc.category = category;
            [self.navigationController pushViewController:vc animated:YES];
        }];
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

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<CSHomePageRow> row = self.rows[indexPath.row];
    return [row height];
}

#pragma mark - CSCategoryRetailersCellDelegate

- (void)categoryRetailersCell:(CSCategoryRetailersCell *)cell
     didSelectRetailerAtIndex:(NSInteger)index
{
    CSHomePageViewController *vc = [self.storyboard
                                    instantiateViewControllerWithIdentifier:
                                    @"CSHomePageViewController"];
    vc.api = self.api;
    
    [cell.retailers getRetailerAtIndex:index
                              callback:^(id<CSRetailer> retailer,
                                         NSError *error)
    {
        if (error) {
            [self setErrorState];
            return;
        }
        
        vc.retailer = retailer;
        [self.navigationController pushViewController:vc animated:YES];
        
    }];
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
    
    id<CSProductSearchState> searchState = nil;
    if (self.category) {
        searchState = [[CSCategoryProductSearchState alloc] initWithCategory:self.category likes:self.likeList query:query];
    } else if (self.retailer) {
        searchState = [[CSRetailerProductSearchState alloc] initWithRetailer:self.retailer likes:self.likeList query:query];
    } else {
        searchState = [[CSGroupProductSearchState alloc] initWithGroup:self.group likes:self.likeList query:query];
    }
    
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
            [self.placeholderView setContentView:self.gridView];
            [self.placeholderView showContentView];
        } else {
            [self.placeholderView showEmptyView];
        }
    }];
}

@end
