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

@protocol CSProductListWrapper <NSObject>

@property (readonly) NSUInteger count;

- (void)getProductWrapperAtIndex:(NSUInteger)index
                        callback:(void (^)(CSProductWrapper *result,
                                           NSError *error))callback;
- (void)getProductAtIndex:(NSUInteger)index
                 callback:(void (^)(id<CSProduct>, NSError *))callback;
@end

@interface CSProductListWrapper : NSObject <CSProductListWrapper>

@property id<CSProductList> products;

+ (instancetype) wrapperWithProducts:(id<CSProductList>)products;

@end

@implementation CSProductListWrapper

+ (instancetype)wrapperWithProducts:(id<CSProductList>)products
{
    CSProductListWrapper *result = [[CSProductListWrapper alloc] init];
    result.products = products;
    return result;
}

- (NSUInteger)count
{
    return [self.products count];
}

- (void)getProductWrapperAtIndex:(NSUInteger)index
                        callback:(void (^)(CSProductWrapper *, NSError *))callback
{
    [self.products getProductAtIndex:index
                            callback:^(id<CSProduct> result, NSError *error)
    {
        if (error) {
            callback(nil, error);
            return;
        }
        
        callback([CSProductWrapper wrapperForProduct:result], nil);
    }];
}

- (void)getProductAtIndex:(NSUInteger)index
                 callback:(void (^)(id<CSProduct>, NSError *))callback
{
    [self.products getProductAtIndex:index callback:callback];
}

@end

@interface CSProductSummaryListWrapper : NSObject <CSProductListWrapper>

@property id<CSProductSummaryList> products;

+ (instancetype) wrapperWithProducts:(id<CSProductSummaryList>)products;

@end

@implementation CSProductSummaryListWrapper

+ (instancetype)wrapperWithProducts:(id<CSProductSummaryList>)products
{
    CSProductSummaryListWrapper *result = [[CSProductSummaryListWrapper alloc] init];
    result.products = products;
    return result;
}

- (NSUInteger)count
{
    return [self.products count];
}

- (void)getProductWrapperAtIndex:(NSUInteger)index
                        callback:(void (^)(CSProductWrapper *, NSError *))callback
{
    [self.products getProductSummaryAtIndex:index
                                   callback:^(id<CSProductSummary> result, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         callback([CSProductWrapper wrapperForSummary:result], nil);
     }];
}

- (void)getProductAtIndex:(NSUInteger)index
                 callback:(void (^)(id<CSProduct>, NSError *))callback
{
    [self.products getProductSummaryAtIndex:index
                                   callback:^(id<CSProductSummary> result,
                                              NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         [result getProduct:callback];
     }];
}

@end

@interface CSProductGridViewController () <CSProductSummaryCellDelegate>

@property (strong, nonatomic) id<CSProductListWrapper> productListWrapper;

@property (strong, nonatomic) CSEmptyProductGridView *emptyView;
@property (strong, nonatomic) CSEmptyProductGridView *errorView;
@property (strong, nonatomic) CSEmptyProductGridView *loadingView;

- (void)hideAllEmptyViews;

- (void)showEmptyView;
- (void)hideEmptyView;

- (void)showErrorView;
- (void)hideErrorView;

- (void)showLoadingView;
- (void)hideLoadingView;

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

- (id<CSProductListWrapper>)productListWrapper
{
    return productListWrapper;
}

- (void)setProductListWrapper:(id<CSProductListWrapper>)wrapper
{
    productListWrapper = wrapper;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (productListWrapper.count) {
            [self hideAllEmptyViews];
        } else {
            [self showEmptyView];
        }
        [self.collectionView reloadData];
    });
}

- (void)setProductSummaries:(id<CSProductSummaryList>)products
{
    [self setProductListWrapper:[CSProductSummaryListWrapper wrapperWithProducts:products]];
}

- (void)setProducts:(id<CSProductList>)products
{
    [self setProductListWrapper:[CSProductListWrapper wrapperWithProducts:products]];
}

- (void)setRetailer:(id<CSRetailer>)retailer likes:(id<CSLikeList>)likes
{
    self.priceContext = [[CSPriceContext alloc] initWithLikeList:likes
                                                        retailer:retailer];
    self.title = retailer.name;
    [self setLoadingState];
    
    [retailer getProducts:^(id<CSProductListPage> firstPage, NSError *error) {
        if (error) {
            [self setErrorState];
            return;
        }
        
        self.products = firstPage.productList;
    }];
}

- (void)setGroup:(id<CSGroup>)group likes:(id<CSLikeList>)likes
{
    self.priceContext = [[CSPriceContext alloc] initWithLikeList:likes];
    self.title = @"Top Products";
    [self setLoadingState];
    [group getProducts:^(id<CSProductListPage> firstPage, NSError *error) {
        if (error) {
            [self setErrorState];
            return;
        }
        
        [self setProducts:firstPage.productList];
    }];
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *address = @{@"index": @(indexPath.row)};
    [self performSegueWithIdentifier:@"showProduct" sender:address];
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
        [self.productListWrapper getProductAtIndex:index
                                          callback:^(id<CSProduct> product,
                                                     NSError *error)
        {
            if (error) {
                [self showErrorAlert];
                [vc performSegueWithIdentifier:@"doneShowProduct" sender:self];
                return;
            }
            vc.product = product;
        }];
        
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

@end
