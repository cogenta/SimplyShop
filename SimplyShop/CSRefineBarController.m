//
//  CSRefineBarController.m
//  SimplyShop
//
//  Created by Will Harris on 20/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRefineBarController.h"
#import "CSRefineMenuViewController.h"
#import "CSRefineBarView.h"
#import "CSRefine.h"
#import "CSRefineBarState.h"
#import "CSRefineBarView.h"
#import <CSApi/CSAPI.h>

@interface CSRefineBarController ()  <
CSRefineBarViewDelegate,
CSRefineMenuViewControllerDelegate>

@property (strong, nonatomic) UIPopoverController *popover;
@property (strong, nonatomic) IBOutlet CSRefineBarView *view;


@end

@implementation CSRefineBarController

- (void)setSlice:(id<CSSlice>)slice
{
    if (slice == _slice) {
        return;
    }
    
    [self willChangeValueForKey:@"slice"];
    _slice = slice;
    [self didChangeValueForKey:@"slice"];
    
    [CSRefineBarState getRefineBarStateForSlice:slice
                                       callback:^(CSRefineBarState *state,
                                                  NSError *error)
    {
        if (error) {
            // TODO: show error
            return;
        }
        
        self.view.state = state;
     }];
}

#pragma mark - CSRefineMenuViewControllerDelegate

- (void)refineMenuViewController:(CSRefineMenuViewController *)controller
                 didSelectNarrow:(id<CSNarrow>)narrow
{
    [self.delegate refineBarController:self didStartLoadingSliceForNarrow:narrow];
    [self.popover dismissPopoverAnimated:YES];
    self.popover = nil;
    
    [narrow getSlice:^(id<CSSlice> result, NSError *error) {
        if (error) {
            [self.delegate refineBarController:self
                              didFailWithError:error
                         loadingSliceForNarrow:narrow];
            return;
        }
        
        self.slice = result;
        [self.delegate refineBarController:self
                     didFinishLoadingSlice:result
                                 forNarrow:narrow];
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
    
    CSRefineMenuViewController *content = [[CSRefineMenuViewController alloc] initWithNibName:@"CSRefineMenuViewController" bundle:nil];
    content.menuDelegate = self;
    content.slice = self.slice;
    content.navigationItem.title = @"Refine";
    
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
    [self.delegate refineBarController:self didStartLoadingSliceForNarrow:nil];
    [refine getSliceWithoutRefine:self.slice
                         callback:^(id<CSSlice> result, NSError *error)
     {
         if (error) {
             [self.delegate refineBarController:self
                               didFailWithError:error
                          loadingSliceForNarrow:nil];
             return;
         }
         
         self.slice = result;
         [self.delegate refineBarController:self
                      didFinishLoadingSlice:result
                                  forNarrow:nil];
     }];
}

@end
