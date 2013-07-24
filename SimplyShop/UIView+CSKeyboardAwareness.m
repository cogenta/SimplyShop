//
//  UIView+CSKeyboardAwareness.m
//  SimplyShop
//
//  Created by Will Harris on 24/07/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "UIView+CSKeyboardAwareness.h"

static UIViewAnimationOptions
UIViewAnimationOptionsMake(UIViewAnimationCurve curve)
{
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
        case UIViewAnimationCurveLinear:
        default:
            return UIViewAnimationOptionCurveLinear;
    }
}

@implementation UIView (CSKeyboardAwareness)

- (void)becomeAwareOfKeyboard
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(CSKeyboardAwareness_keyboardDidShow:)
                   name:UIKeyboardDidShowNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(CSKeyboardAwareness_keyboardWillHide:)
                   name:UIKeyboardWillHideNotification
                 object:nil];
}

- (void)becomeUnawareOfKeyboard
{
    self.frame = self.superview.bounds;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [center removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)CSKeyboardAwareness_keyboardDidShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    CGRect keyboardEndFrame;
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]
     getValue:&keyboardEndFrame];
    
    CGRect keyboardFrame = [self.superview convertRect:keyboardEndFrame
                                              fromView:nil];
    CGFloat viewWidth = self.frame.size.width;
    CGRect newFrame = CGRectMake(0.0, 0.0, viewWidth, keyboardFrame.origin.y);
    
    self.frame = newFrame;
}

-(void)CSKeyboardAwareness_keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    UIViewAnimationCurve curve;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey]
     getValue:&curve];
    
    NSTimeInterval duration;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]
     getValue:&duration];
    
    CGRect keyboardEndFrame;
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]
     getValue:&keyboardEndFrame];
    
    UIViewAnimationOptions options = UIViewAnimationOptionsMake(curve);
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:options
                     animations:^{ self.frame = self.superview.bounds; }
                     completion:NULL];
}

@end
