//
//  CSRefineBarRemoveButtonView.h
//  SimplyShop
//
//  Created by Will Harris on 16/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSRefine;
@class CSRefineBarRemoveButtonView;

@protocol CSRefineBarRemoveButtonViewDelegate <NSObject>

- (void)didTapRemoveButton:(CSRefineBarRemoveButtonView *)sender;

@end

@interface CSRefineBarRemoveButtonView : UIView

@property (retain, nonatomic) CSRefine *refine;
@property (weak, nonatomic) id<CSRefineBarRemoveButtonViewDelegate> delegate;
@end
