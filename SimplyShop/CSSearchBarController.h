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
@property (copy, nonatomic) NSString *query;

- (id)initWithPlaceholder:(NSString *)placeholder
           navigationItem:(UINavigationItem *)navigationItem;

@end

@protocol CSSearchBarControllerDelegate <NSObject>

@optional
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;

@end
