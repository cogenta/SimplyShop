//
//  CSRefineBarController.h
//  SimplyShop
//
//  Created by Will Harris on 20/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CSRefineBarController;
@protocol CSNarrow;
@protocol CSSlice;

@protocol CSRefineBarControllerDelegate <NSObject>

- (void)refineBarController:(CSRefineBarController *)controller
didStartLoadingSliceForNarrow:(id<CSNarrow>)narrow;
- (void)refineBarController:(CSRefineBarController *)controller
      didFinishLoadingSlice:(id<CSSlice>)slice
                  forNarrow:(id<CSNarrow>)narrow;
- (void)refineBarController:(CSRefineBarController *)controller
           didFailWithError:(NSError *)error
      loadingSliceForNarrow:(id<CSNarrow>)narrow;

@end

@interface CSRefineBarController : NSObject

@property (weak, nonatomic) IBOutlet id<CSRefineBarControllerDelegate> delegate;
@property (strong, nonatomic) id<CSSlice> slice;

@end
