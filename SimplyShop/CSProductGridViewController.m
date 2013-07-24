//
//  CSProductGridViewController.m
//  SimplyShop
//
//  Created by Will Harris on 08/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductGridViewController.h"
#import "CSProductDetailViewController.h"
#import "CSPriceContext.h"
#import "CSProductWrapper.h"
#import "CSEmptyProductGridView.h"
#import "CSSearchBarController.h"
#import "CSProductSearchStateTitleFormatter.h"
#import "CSProductSearchState.h"
#import "CSProductGridDataSource.h"
#import "CSPlaceholderView.h"
#import "UIView+CSKeyboardAwareness.h"

@interface CSProductGridViewController () <CSSearchBarControllerDelegate>

@property (strong, nonatomic) id<CSProductListWrapper> productListWrapper;

@property (strong, nonatomic) CSSearchBarController *searchBarController;
@property (strong, nonatomic) id<CSProductSearchState> searchState;

- (void)addSearchToNavigationBar;

@end

@implementation CSProductGridViewController

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
    self.placeholderView.emptyViewTitle = @"No Products";
    self.placeholderView.errorViewDetail = @"Failed to communicate with server";
    [self.placeholderView showLoadingView];

	[self addSearchToNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.view becomeAwareOfKeyboard];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view becomeUnawareOfKeyboard];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CSPriceContext *)priceContext
{
    return self.dataSource.priceContext;
}

- (void)setPriceContext:(CSPriceContext *)priceContext
{
    self.dataSource.priceContext = priceContext;
}

- (id<CSProductListWrapper>)productListWrapper
{
    return self.dataSource.productListWrapper;
}

- (void)setProductListWrapper:(id<CSProductListWrapper>)wrapper
{
    self.dataSource.productListWrapper = wrapper;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( ! wrapper) {
            [self.placeholderView showLoadingView];
        } else if (wrapper.count) {
            [self.placeholderView showContentView];
        } else {
            self.placeholderView.emptyViewDetail = [self detailForEmptyView];
            [self.placeholderView showEmptyView];
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
    
    [self.placeholderView showLoadingView];
    [searchState getProducts:^(id<CSProductList> products, NSError *error) {
        if (error) {
            [self.placeholderView showErrorView];
            return;
        }
        
        self.products = products;
    }];
    
    self.priceContext = searchState.priceContext;
    id formatter = [CSProductSearchStateTitleFormatter instance];
    self.title = [searchState titleWithFormatter:formatter];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showProduct"]) {
        CSProductDetailViewController *vc = segue.destinationViewController;
        vc.priceContext = self.searchState.priceContext;

        NSDictionary *address = sender;
        NSInteger index = [address[@"index"] integerValue];
        [vc setProductListWrapper:self.productListWrapper index:index];
        
        return;
    }
}

- (void)doneShowProduct:(UIStoryboardSegue *)segue
{
    [segue.destinationViewController dismissViewControllerAnimated:YES
                                                        completion:NULL];
}

- (NSString *)detailForEmptyView
{
    if (self.priceContext.retailer) {
        return [NSString stringWithFormat:@"We found no products for %@.",
                self.priceContext.retailer.name];
    }
    
    return @"No products were found for your search.";
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
    }
}

@end
