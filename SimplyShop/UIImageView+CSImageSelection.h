//
//  UIImageView+CSImageSelection.h
//  SimplyShop
//
//  Created by Will Harris on 03/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CSImageList;
@protocol CSImage;
@protocol CSPicture;

@interface UIImageView (CSImageSelection)

- (void)selectFrom:(id<CSImageList>)images
          callback:(void (^)(id<CSImage> image))callback;
- (void)setImageWithPicture:(id<CSPicture>)picture
                  completed:(void (^)(UIImage *image, NSError *error))callback;

@end
