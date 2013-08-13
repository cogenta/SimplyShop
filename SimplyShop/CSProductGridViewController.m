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
#import "CSEmptyProductGridView.h"
#import "CSSearchBarController.h"
#import "CSProductSearchStateTitleFormatter.h"
#import "CSProductSearchState.h"
#import "CSProductGridDataSource.h"
#import "CSPlaceholderView.h"
#import "UIView+CSKeyboardAwareness.h"

@interface CSProductGridViewController () <CSSearchBarControllerDelegate>

@property (strong, nonatomic) id<CSProductList> products;

@property (strong, nonatomic) CSSearchBarController *searchBarController;
@property (strong, nonatomic) id<CSProductSearchState> searchState;
@property (strong, nonatomic) id<CSAPIRequest> searchRequest;

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
    [super viewWillAppear:animated];
    [self.view becomeAwareOfKeyboard];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view becomeUnawareOfKeyboard];
    [super viewDidDisappear:animated];
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

- (id<CSProductList>)products
{
    return self.dataSource.products;
}

- (void)setProducts:(id<CSProductList>)products
{
    self.dataSource.products = products;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( ! products) {
            [self.placeholderView showLoadingView];
        } else if (products.count) {
            [self.placeholderView showContentView];
        } else {
            self.placeholderView.emptyViewDetail = [self detailForEmptyView];
            [self.placeholderView showEmptyView];
        }
        [self.collectionView reloadData];
    });
}

- (void)setSearchState:(id<CSProductSearchState>)searchState
{
    _searchState = searchState;
    
    [self.placeholderView showLoadingView];
    [self.searchRequest cancel];
    self.searchRequest = [searchState getProducts:^(id<CSProductList> products, NSError *error) {
        self.searchRequest = nil;
        if ( ! [self.searchState isEqual:searchState]) {
            return;
        }
        
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

- (void)setSlice:(id<CSSlice>)slice
        retailer:(id<CSRetailer>)retailer
           likes:(id<CSLikeList>)likes
           query:(NSString *)query
{
    self.searchState = [CSProductSearchState stateWithSlice:slice
                                                   retailer:retailer
                                                   category:nil
                                                      likes:likes
                                                      query:query];
}

- (void)setSlice:(id<CSSlice>)slice
           likes:(id<CSLikeList>)likes
           query:(NSString *)query
{
    self.searchState = [CSProductSearchState stateWithSlice:slice
                                                   retailer:nil
                                                   category:nil
                                                      likes:likes
                                                      query:query];
}

- (void)setSlice:(id<CSSlice>)slice
        category:(id<CSCategory>)category
           likes:(id<CSLikeList>)likes
           query:(NSString *)query
{
    self.searchState = [CSProductSearchState stateWithSlice:slice
                                                   retailer:nil
                                                   category:category
                                                      likes:likes
                                                      query:query];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showProduct"]) {
        CSProductDetailViewController *vc = segue.destinationViewController;
        vc.priceContext = self.searchState.priceContext;

        NSDictionary *address = sender;
        NSInteger index = [address[@"index"] integerValue];
        [vc setProductList:self.products index:index];
        
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
