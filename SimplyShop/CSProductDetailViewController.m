//
//  CSProductDetailViewController.m
//  SimplyShop
//
//  Created by Will Harris on 25/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductDetailViewController.h"
#import "CSProductDetailsView.h"
#import "CSTitleBarView.h"
#import "CSProductStats.h"
#import <CSApi/CSAPI.h>

@interface CSProductDetailViewController ()

@property (nonatomic, weak) UIViewController *mainViewController;
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
    if ([segue.identifier isEqualToString:@"embedMainViewController"]) {
        self.mainViewController = segue.destinationViewController;
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
    self.productDetailsView.description = product.description;
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
}

- (void)setProductSummary:(id<CSProductSummary>)productSummary
{
    self.titleBarView.title = [productSummary.name uppercaseString];
    self.productDetailsView.description = productSummary.description;
    [self updateSizing];
}

@end
