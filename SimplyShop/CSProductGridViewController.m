//
//  CSProductGridViewController.m
//  SimplyShop
//
//  Created by Will Harris on 08/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductGridViewController.h"
#import <CSApi/CSAPI.h>
#import "CSProductSummaryCell.h"
#import "CSProductDetailViewController.h"
#import "CSPriceContext.h"
#import "CSProductWrapper.h"
#import "CSEmptyProductGridView.h"
#import "CSSearchBarController.h"
#import "CSProductSearchStateTitleFormatter.h"

@protocol CSProductSearchState <NSObject>

@property (readonly) NSString *query;
@property (readonly) CSPriceContext *priceContext;

- (NSString *)titleWithFormatter:(id<CSProductSearchStateTitleFormatter>)formatter;

- (id<CSProductSearchState>)stateWithQuery:(NSString *)query;
- (void)getProducts:(void (^)(id<CSProductList>, NSError *))callback;

@end

@interface CSRetailerProductSearchState : NSObject <CSProductSearchState>

@property (readonly) id<CSRetailer> retailer;
@property (readonly) id<CSLikeList> likes;
@property (readonly) NSString *query;

- (id)initWithRetailer:(id<CSRetailer>)retailer
                 likes:(id<CSLikeList>)likes
                 query:(NSString *)query;

@end

@implementation CSRetailerProductSearchState

- (id)initWithRetailer:(id<CSRetailer>)retailer
                 likes:(id<CSLikeList>)likes
                 query:(NSString *)query
{
    self = [super init];
    if (self) {
        _retailer = retailer;
        _likes = likes;
        _query = query;
    }
    
    return self;
}

- (id<CSProductSearchState>)stateWithQuery:(NSString *)query
{
    if ( ! [query length] && ! [self.query length]) {
        return self;
    }
    
    if ([query isEqualToString:self.query]) {
        return self;
    }
    
    return [[CSRetailerProductSearchState alloc] initWithRetailer:self.retailer
                                                            likes:self.likes
                                                            query:query];
}

- (NSString *)titleWithFormatter:(id<CSProductSearchStateTitleFormatter>)formatter
{
    if (self.query) {
        return [formatter titleWithRetailer:self.retailer query:self.query];
    }
    
    return [formatter titleWithRetailer:self.retailer];
}

- (CSPriceContext *)priceContext
{
    return [[CSPriceContext alloc] initWithLikeList:self.likes
                                           retailer:self.retailer];
}

- (void)getProducts:(void (^)(id<CSProductList>, NSError *))callback
{
    if (self.query) {
        [self.retailer getProductsWithQuery:self.query
                                   callback:^(id<CSProductListPage> firstPage,
                                              NSError *error)
         {
             callback(firstPage.productList, error);
         }];
    } else {
        [self.retailer getProducts:^(id<CSProductListPage> firstPage,
                                     NSError *error)
         {
             callback(firstPage.productList, error);
         }];
    }
}

@end

@interface CSGroupProductSearchState : NSObject <CSProductSearchState>

@property (readonly) id<CSGroup> group;
@property (readonly) id<CSLikeList> likes;
@property (readonly) NSString *query;

- (id)initWithGroup:(id<CSGroup>)group
              likes:(id<CSLikeList>)likes
              query:(NSString *)query;

@end

@implementation CSGroupProductSearchState

- (id)initWithGroup:(id<CSGroup>)group
              likes:(id<CSLikeList>)likes
              query:(NSString *)query
{
    self = [super init];
    if (self) {
        _group = group;
        _likes = likes;
        _query = query;
    }
    return self;
}

- (id<CSProductSearchState>)stateWithQuery:(NSString *)query
{
    if ( ! [query length] && ! [self.query length]) {
        return self;
    }
    
    if ([query isEqualToString:self.query]) {
        return self;
    }
    
    return [[CSGroupProductSearchState alloc] initWithGroup:self.group
                                                      likes:self.likes
                                                      query:query];
}

- (NSString *)titleWithFormatter:(id<CSProductSearchStateTitleFormatter>)formatter
{
    if (self.query) {
        return [formatter titleWithQuery:self.query];
    }
    
    return [formatter title];
}

- (CSPriceContext *)priceContext
{
    return [[CSPriceContext alloc] initWithLikeList:self.likes];
}

- (void)getProducts:(void (^)(id<CSProductList>, NSError *))callback
{
    if (self.query) {
        [self.group getProductsWithQuery:self.query
                                callback:^(id<CSProductListPage> firstPage,
                                           NSError *error)
         {
             callback(firstPage.productList, error);
         }];
    } else {
        [self.group getProducts:^(id<CSProductListPage> firstPage,
                                  NSError *error)
         {
             callback(firstPage.productList, error);
         }];
    }
}

@end

@interface CSCategoryProductSearchState : NSObject <CSProductSearchState>

@property (readonly) id<CSCategory>category;
@property (readonly) id<CSLikeList>likes;
@property (readonly) NSString *query;

- (id)initWithCategory:(id<CSCategory>)category
                 likes:(id<CSLikeList>)likes
                 query:(NSString *)query;

@end

@implementation CSCategoryProductSearchState

- (id)initWithCategory:(id<CSCategory>)category
                 likes:(id<CSLikeList>)likes
                 query:(NSString *)query
{
    self = [super init];
    if (self) {
        _category = category;
        _likes = likes;
        _query = query;
    }
    return self;
}

- (id<CSProductSearchState>)stateWithQuery:(NSString *)query
{
    if ( ! [query length] && ! [self.query length]) {
        return self;
    }
    
    if ([query isEqualToString:self.query]) {
        return self;
    }
    
    return [[CSCategoryProductSearchState alloc] initWithCategory:self.category
                                                            likes:self.likes
                                                            query:query];
}

- (NSString *)titleWithFormatter:(id<CSProductSearchStateTitleFormatter>)formatter
{
    if (self.query) {
        return [formatter titleWithCategory:self.category query:self.query];
    }
    
    return [formatter titleWithCategory:self.category];
}

- (CSPriceContext *)priceContext
{
    return [[CSPriceContext alloc] initWithLikeList:self.likes];
}

- (void)getProducts:(void (^)(id<CSProductList>, NSError *))callback
{
    if (self.query) {
        [self.category getProductsWithQuery:self.query
                                   callback:^(id<CSProductListPage> firstPage,
                                              NSError *error)
         {
             callback(firstPage.productList, error);
         }];
    } else {
        [self.category getProducts:^(id<CSProductListPage> firstPage,
                                     NSError *error)
         {
             callback(firstPage.productList, error);
         }];
    }
}

@end

@interface CSProductGridViewController () <
    CSProductSummaryCellDelegate,
    CSSearchBarControllerDelegate
>

@property (strong, nonatomic) id<CSProductListWrapper> productListWrapper;

@property (strong, nonatomic) CSEmptyProductGridView *emptyView;
@property (strong, nonatomic) CSEmptyProductGridView *errorView;
@property (strong, nonatomic) CSEmptyProductGridView *loadingView;

@property (strong, nonatomic) CSSearchBarController *searchBarController;
@property (strong, nonatomic) id<CSProductSearchState> searchState;

- (void)hideAllEmptyViews;

- (void)showEmptyView;
- (void)hideEmptyView;

- (void)showErrorView;
- (void)hideErrorView;

- (void)showLoadingView;
- (void)hideLoadingView;

- (void)addSearchToNavigationBar;

@end

@implementation CSProductGridViewController

@synthesize productListWrapper;

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
	[self addSearchToNavigationBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id<CSProductListWrapper>)productListWrapper
{
    return productListWrapper;
}

- (void)setProductListWrapper:(id<CSProductListWrapper>)wrapper
{
    productListWrapper = wrapper;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( ! productListWrapper) {
            [self showLoadingView];
        } else if (productListWrapper.count) {
            [self hideAllEmptyViews];
        } else {
            [self showEmptyView];
        }
        [self.collectionView reloadData];
    });
}

- (void)setProductSummaries:(id<CSProductSummaryList>)products
{
    [self setProductListWrapper:[CSProductSummaryListWrapper
                                 wrapperWithProducts:products]];
}

- (void)setProducts:(id<CSProductList>)products
{
    [self setProductListWrapper:[CSProductListWrapper
                                 wrapperWithProducts:products]];
}

- (void)setSearchState:(id<CSProductSearchState>)searchState
{
    _searchState = searchState;
    
    [self setLoadingState];
    [searchState getProducts:^(id<CSProductList> products, NSError *error) {
        if (error) {
            [self setErrorState];
            return;
        }
        
        self.products = products;
    }];
    
    self.priceContext = searchState.priceContext;
    self.title = [searchState titleWithFormatter:[CSProductSearchStateTitleFormatter instance]];
}

- (void)setRetailer:(id<CSRetailer>)retailer
              likes:(id<CSLikeList>)likes
              query:(NSString *)query
{
    self.searchState = [[CSRetailerProductSearchState alloc]
                        initWithRetailer:retailer likes:likes query:query];
}

- (void)setGroup:(id<CSGroup>)group
           likes:(id<CSLikeList>)likes
           query:(NSString *)query
{
    self.searchState = [[CSGroupProductSearchState alloc]
                        initWithGroup:group likes:likes query:query];
}


- (void)setCategory:(id<CSCategory>)category
              likes:(id<CSLikeList>)likes
              query:(NSString *)query
{
    self.searchState = [[CSCategoryProductSearchState alloc]
                        initWithCategory:category likes:likes query:query];
}

- (void)showErrorAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Failed to communicate with the server."
                                                   delegate:self
                                          cancelButtonTitle:@"Retry"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)setErrorState
{
    [self showErrorView];
}

- (void)setLoadingState
{
    [self showLoadingView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showProduct"]) {
        CSProductDetailViewController *vc = (id) segue.destinationViewController;
        vc.priceContext = self.priceContext;
        
        NSDictionary *address = sender;
        NSInteger index = [address[@"index"] integerValue];
        [vc setProductListWrapper:self.productListWrapper index:index];
        
        return;
    }
}

- (void)doneShowProduct:(UIStoryboardSegue *)segue
{
    [segue.destinationViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (NSString *)detailForEmptyView
{
    if (self.priceContext.retailer) {
        return [NSString stringWithFormat:@"We found no products for %@.",
                self.priceContext.retailer.name];
    }
    
    return @"No products were found for your search.";
}

- (void)showEmptyView
{
    [self hideAllEmptyViews];
    
    self.emptyView = [[CSEmptyProductGridView alloc]
                      initWithFrame:self.view.bounds];
    
    self.emptyView.frame = self.view.bounds;
    self.emptyView.detailText = [self detailForEmptyView];
    [self.view addSubview:self.emptyView];
}

- (void)hideEmptyView
{
    [self.emptyView removeFromSuperview];
    self.emptyView = nil;
}

- (void)showErrorView
{
    [self hideAllEmptyViews];
    
    self.errorView = [[CSEmptyProductGridView alloc]
                      initWithFrame:self.view.bounds];
    
    self.errorView.frame = self.view.bounds;
    self.errorView.headerText = @"Error";
    self.errorView.detailText = @"Failed to communicate with server";
    [self.view addSubview:self.errorView];
}

- (void)hideErrorView
{
    [self.errorView removeFromSuperview];
    self.errorView = nil;
}

- (void)showLoadingView
{
    [self hideAllEmptyViews];
    
    self.loadingView = [[CSEmptyProductGridView alloc]
                        initWithFrame:self.view.bounds];
    
    self.loadingView.frame = self.view.bounds;
    self.loadingView.headerText = @"Loading";
    self.loadingView.detailText = nil;
    self.loadingView.active = YES;
    [self.view addSubview:self.loadingView];
}

- (void)hideLoadingView
{
    [self.loadingView removeFromSuperview];
    self.loadingView = nil;
}

- (void)hideAllEmptyViews
{
    [self hideEmptyView];
    [self hideErrorView];
    [self hideLoadingView];
}

- (void)viewDidLayoutSubviews
{
    [UIView animateWithDuration:0.0 animations:^{
        CGPoint center = CGPointMake(CGRectGetMidX(self.view.bounds),
                                     CGRectGetMidY(self.view.bounds));
        self.loadingView.center = center;
        self.errorView.center = center;
        self.emptyView.center = center;
    } completion:^(BOOL finished) {
        self.loadingView.frame = self.view.bounds;
        self.errorView.frame = self.view.bounds;
        self.emptyView.frame = self.view.bounds;
    }];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.productListWrapper.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CSProductSummaryCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:@"CSProductSummaryPriceCell"
                                              forIndexPath:indexPath];
    
    if (cell.address != indexPath) {
        [self productSummaryCell:cell needsReloadWithAddress:indexPath];
    }
    
    return cell;
}

- (void)productSummaryCell:(CSProductSummaryCell *)cell
    needsReloadWithAddress:(NSObject *)address
{
    cell.priceContext = self.priceContext;
    [cell setLoadingAddress:address];
    [self.productListWrapper getProductWrapperAtIndex:((NSIndexPath *)address).row
                                             callback:^(CSProductWrapper *result,
                                                        NSError *error)
     {
         if (error) {
             [cell setError:error address:address];
             return;
         }
         
         [cell setWrapper:result address:address];
     }];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *address = @{@"index": @(indexPath.row)};
    [self performSegueWithIdentifier:@"showProduct" sender:address];
}

#pragma mark - Search Bar

- (void)addSearchToNavigationBar
{
    self.searchBarController = [[CSSearchBarController alloc]
                                initWithPlaceholder:@"Search Products"
                                navigationItem:self.navigationItem];
    self.searchBarController.query = self.searchState.query;
    self.searchBarController.delegate = self;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *query = searchBar.text;
    if ( ! [query length]) {
        query = nil;
    }
    
    id<CSProductSearchState> newState = [self.searchState stateWithQuery:query];
    if (newState != self.searchState) {
        self.searchState = newState;
        [self setProductListWrapper:nil];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSString *query = searchBar.text;
    if ( ! [query length]) {
        query = nil;
    }
    
    id<CSProductSearchState> newState = [self.searchState stateWithQuery:query];
    if (newState != self.searchState) {
        self.searchState = newState;
        [self setProductListWrapper:nil];
    }
}

@end
