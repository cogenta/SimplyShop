//
//  CSAppearanceButton.h
//  SimplyShop
//
//  Created by Will Harris on 04/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSAppearanceButton : UIButton

- (void)setTitleFont:(UIFont *)font UI_APPEARANCE_SELECTOR;
- (void)setTitleColor:(UIColor *)color UI_APPEARANCE_SELECTOR;
- (void)setTitleShadowColor:(UIColor *)color UI_APPEARANCE_SELECTOR;
- (void)setTitleLabelShadowOffset:(CGSize)offset UI_APPEARANCE_SELECTOR;

@end
