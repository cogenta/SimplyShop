//
//  CSProductDetailViewController.m
//  SimplyShop
//
//  Created by Will Harris on 25/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductDetailViewController.h"
#import "CSProductDetailsView.h"
#import "CSProductSidebarView.h"
#import "CSTitleBarView.h"
#import "CSProductStats.h"
#import "CSPriceContext.h"
#import <PBWebViewController/PBWebViewController.h>
#import <CSApi/CSAPI.h>

@interface CSProductDetailViewController () <CSProductSidebarViewDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *recognizer;
@end

@implementation CSProductDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.title = @"Product Detail";
}

- (void)viewDidAppear:(BOOL)animated
{
    self.recognizer = [[UITapGestureRecognizer alloc]
                       initWithTarget:self
                       action:@selector(handleTapBehind:)];
    
    [self.recognizer setNumberOfTapsRequired:1];
    self.recognizer.cancelsTouchesInView = NO;
    [self.view.window addGestureRecognizer:self.recognizer];
    
    [super viewDidAppear:animated];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0, 0, 660.0, 620.0);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ( ! self.recognizer) {
        return;
    }
    [self.view.window removeGestureRecognizer:self.recognizer];
    self.recognizer = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPurchasePage"]) {
        UINavigationController *nav = segue.destinationViewController;
        PBWebViewController *vc = (id) nav.topViewController;
        vc.URL = [sender purchaseURL];
    }
}

- (void)handleTapBehind:(UITapGestureRecognizer *)sender
{
    if (sender.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    CGPoint location = [sender locationInView:nil];
    
    CGPoint converted = [self.view
                         convertPoint:location
                         fromView:self.view.window];
    if ([self.view pointInside:converted withEvent:nil]) {
        return;
    }
    
    [self.view.window removeGestureRecognizer:sender];
    [self performSegueWithIdentifier:@"doneShowProduct" sender:self];
}

- (void)updateSizing
{
    [self.productDetailsView setNeedsLayout];
}

- (void)setProduct:(id<CSProduct>)product
{
    self.titleBarView.title = [product.name uppercaseString];
    self.productDetailsView.description_ = product.description_;
    CSProductStats *stats = [[CSProductStats alloc] init];
    stats.product = product;
    self.productDetailsView.stats = stats;
    [product getPictures:^(id<CSPictureListPage> firstPage, NSError *error) {
        if (error) {
            // Do nothing
            return;
        }
        
        self.productDetailsView.pictures = firstPage.pictureList;
    }];
    
    [self updateSizing];
    [product getPrices:^(id<CSPriceListPage> firstPage, NSError *error) {
        if (error) {
            // TODO: better error handling
            self.sidebarView.price = nil;
            return;
        }
        
        [self.priceContext getBestPrice:firstPage.priceList
                               callback:^(id<CSPrice> bestPrice)
        {
            self.sidebarView.price = bestPrice;
        }];
    }];
}

- (void)setProductSummary:(id<CSProductSummary>)productSummary
{
    self.titleBarView.title = [productSummary.name uppercaseString];
    self.productDetailsView.description_ = productSummary.description_;
    
    self.sidebarView.price = nil;
    [self updateSizing];
}

- (void)sidebarView:(CSProductSidebarView *)view
     didSelectPrice:(id<CSPrice>)price
{
    [self performSegueWithIdentifier:@"showPurchasePage" sender:price];
}

- (IBAction)doneShowPurchasePage:(UIStoryboardSegue *)segue
{
    // Do nothing
}

@end
