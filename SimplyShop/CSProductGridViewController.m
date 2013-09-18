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
#import "CSRefineSelectionViewController.h"
#import "UIView+CSKeyboardAwareness.h"
#import "CSRefineBarView.h"
#import "CSRefineBarState.h"
#import "CSRefine.h"

@interface CSProductGridViewController ()
<CSSearchBarControllerDelegate,
CSRefineSelectionViewControllerDelegate,
CSRefineBarViewDelegate>

@property (strong, nonatomic) id<CSProductList> products;

@property (strong, nonatomic) CSSearchBarController *searchBarController;
@property (strong, nonatomic) id<CSAPIRequest> searchRequest;

@property (strong, nonatomic) UIPopoverController *popover;

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
    self.searchRequest = [searchState getProducts:^(id<CSProductList> products,
                                                    NSError *error) {
        self.searchRequest = nil;
        if ( ! [self.searchState isEqual:searchState]) {
            return;
        }
        
        if (error) {
            [self.placeholderView showErrorView];
            return;
        }
        
        [CSRefineBarState getRefineBarStateForSlice:self.searchState.slice
                                           callback:^(CSRefineBarState *state,
                                                      NSError *error)
        {
            if (error) {
                [self.placeholderView showErrorView];
                return;
            }
            
            self.refineBarView.state = state;
            self.products = products;
        }];
    }];
    
    id formatter = [CSProductSearchStateTitleFormatter instance];
    self.title = [searchState titleWithFormatter:formatter];
    
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
    if (self.searchState.priceContext.retailer) {
        return [NSString stringWithFormat:@"We found no products for %@.",
                self.searchState.priceContext.retailer.name];
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

#pragma mark - CSRefineSelectionViewControllerDelegate

- (id<CSNarrow>)selectedNarrow
{
    return nil;
}

- (void)getNarrows:(void (^)(id<CSNarrowList>, NSError *))callback
{
    [self.searchState.slice getAuthorNarrows:^(id<CSNarrowListPage> result,
                                               NSError *error) {
        if (error) {
            callback(nil, error);
            return;
        }
        
        callback(result.narrowList, nil);
    }];
}

- (void)didSelectNarrowAtIndex:(NSUInteger)index
{
    [self.placeholderView showLoadingView];
    [self.popover dismissPopoverAnimated:YES];
    self.popover = nil;
    [self.searchState.slice getAuthorNarrows:^(id<CSNarrowListPage> listPage,
                                               NSError *error) {
        if (error) {
            // TODO: report error
            return;
        }
        
        [listPage.narrowList getNarrowAtIndex:index
                                     callback:^(id<CSNarrow> narrow,
                                                NSError *error)
        {
            if (error) {
                // TODO: report error
                return;
            }
            
            [narrow getSlice:^(id<CSSlice> result, NSError *error) {
                if (error) {
                    // TODO: report error
                    return;
                }
                
                self.searchState = [self.searchState stateWithSlice:result];
            }];
        }];
    }];

}

#pragma mark - CSRefineBarViewDelegate

- (void)refineBarView:(CSRefineBarView *)bar didRequestRefineMenu:(id)sender
{
    if (self.popover.popoverVisible) {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
        return;
    }
    
    CSRefineSelectionViewController *content = [[CSRefineSelectionViewController alloc] initWithNibName:@"CSRefineSelectionViewController" bundle:nil];
    content.selectionDelegate = self;
    content.navigationItem.title = @"Author";
    
    UINavigationController *nav = [[UINavigationController alloc]
                                   initWithRootViewController:content];
    self.popover = [[UIPopoverController alloc] initWithContentViewController:nav];
    
    UIView *senderView = (UIView *)sender;
    [self.popover  presentPopoverFromRect:senderView.bounds
                                   inView:senderView
                permittedArrowDirections:UIPopoverArrowDirectionUp
                                 animated:YES];
}

- (void)refineBarView:(CSRefineBarView *)bar didSelectRemoval:(CSRefine *)refine
{
    [self.placeholderView showLoadingView];
    [refine getSliceWithoutRefine:self.searchState.slice
                         callback:^(id<CSSlice> result, NSError *error)
    {
        if (error) {
            [self.placeholderView showErrorView];
            return;
        }
        
        self.searchState = [self.searchState stateWithSlice:result];
    }];
}

@end
