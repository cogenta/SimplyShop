//
//  UIImageView+CSImageSelection.m
//  SimplyShop
//
//  Created by Will Harris on 03/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "UIImageView+CSImageSelection.h"

#import <CSApi/CSAPI.h>
#import <SDWebImage/UIImageView+WebCache.h>

@implementation UIImageView (CSImageSelection)

- (void)selectFrom:(id<CSImageList>)images
          callback:(void (^)(id<CSImage>))callback
{
    CGSize targetSize = self.frame.size;
    targetSize.width *= 2.0;
    targetSize.height *= 2.0;
    
    if (images.count == 0) {
        callback(nil);
    }
    
    __block id<CSImage> bestImage = nil;
    for (NSInteger i = 0 ; i < images.count; ++i) {
        [images getImageAtIndex:i
                       callback:^(id<CSImage> image, NSError *error)
         {
             if (error) {
                 return;
             }
             
             if ( ! bestImage) {
                 bestImage = image;
             }
             
             if ([image.width doubleValue] <= targetSize.width &&
                 [image.height doubleValue] <= targetSize.height &&
                 ([image.width doubleValue] > [bestImage.width doubleValue] ||
                  [image.height doubleValue] > [bestImage.height doubleValue])) {
                     bestImage = image;
                 }
             
             if (i == images.count - 1 && bestImage) {
                 callback(bestImage);
             }
         }];
    }
}

- (void)setImageWithPicture:(id<CSPicture>)picture
                  completed:(void (^)(UIImage *, NSError *))callback
{
    id<CSImageList> images = picture.imageList;
    
    [self selectFrom:images callback:^(id<CSImage> bestImage) {
        if ( ! bestImage) {
            return;
        }
        
        [self setImageWithURL:bestImage.enclosureURL
                    completed:^(UIImage *image,
                                NSError *error,
                                SDImageCacheType type)
         {
             if (callback) {
                 callback(image, error);
             }
         }];
    }];
}

@end
