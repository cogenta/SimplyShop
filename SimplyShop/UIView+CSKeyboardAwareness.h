//
//  UIView+CSKeyboardAwareness.h
//  SimplyShop
//
//  Created by Will Harris on 24/07/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CSKeyboardAwareness)

- (void)becomeAwareOfKeyboard;
- (void)becomeUnawareOfKeyboard;

@end
