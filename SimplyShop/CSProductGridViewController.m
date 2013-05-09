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

@interface CSProductGridViewController ()

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
    return self.productSummaries.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CSProductSummaryCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:@"CSProductSummaryCell"
                                              forIndexPath:indexPath];
    
    
    [self productSummaryCell:cell needsReloadWithAddress:indexPath];
    
    return cell;
}

- (void)productSummaryCell:(CSProductSummaryCell *)cell needsReloadWithAddress:(NSObject *)address
{
    [cell setLoadingAddress:address];
    [self.productSummaries getProductSummaryAtIndex:((NSIndexPath *)address).row
                                           callback:^(id<CSProductSummary> result,
                                                      NSError *error)
     {
         if (error) {
             [cell setError:error address:address];
             return;
         }
         
         [cell setProductSummary:result address:address];
     }];
}

- (void)setProductSummaries:(id<CSProductSummaryList>)productSummaries
{
    _productSummaries = productSummaries;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *address = @{@"index": @(indexPath.row)};
    [self performSegueWithIdentifier:@"showProduct" sender:address];
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
    [self.collectionView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showProduct"]) {
        CSProductDetailViewController *vc = (id) segue.destinationViewController;
        vc.priceContext = self.priceContext;
        
        NSDictionary *address = sender;
        id<CSProductSummaryList> list = self.productSummaries;
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

- (void)doneShowProduct:(UIStoryboardSegue *)segue
{
    [segue.destinationViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
