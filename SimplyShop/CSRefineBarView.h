//
//  CSRefineBarView.h
//  SimplyShop
//
//  Created by Will Harris on 16/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSRefineBarState;
@class CSRefineBarView;
@class CSRefine;

@protocol CSRefineBarViewDelegate

- (void)refineBarView:(CSRefineBarView *)bar didRequestRefineMenu:(id)sender;
- (void)refineBarView:(CSRefineBarView *)bar
     didSelectRemoval:(CSRefine *)refine;

@end

@interface CSRefineBarView : UIView

@property (strong, nonatomic) CSRefineBarState *state;
@property (weak, nonatomic) IBOutlet id<CSRefineBarViewDelegate> delegate;

@property (strong, nonatomic) UIImage *backgroundImage UI_APPEARANCE_SELECTOR;

@end
