//
//  CSSearchBarController.h
//  SimplyShop
//
//  Created by Will Harris on 18/07/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSSearchBarControllerDelegate;

@interface CSSearchBarController : NSObject

@property (weak, nonatomic) id<CSSearchBarControllerDelegate> delegate;

- (id)initWithPlaceholder:(NSString *)placeholder
           navigationItem:(UINavigationItem *)navigationItem;

@end

@protocol CSSearchBarControllerDelegate <NSObject>

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;

@end
