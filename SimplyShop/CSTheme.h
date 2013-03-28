//
//  CSTheme.h
//  SimplyShop
//
//  Created by Will Harris on 27/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSTheme

- (void)apply;
- (UIImage *)collectionViewCellBackgroundImage;
- (UIImage *)collectionViewCellSelectedBackgroundImage;

@end
