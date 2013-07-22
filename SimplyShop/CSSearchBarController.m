//
//  CSSearchBarController.m
//  SimplyShop
//
//  Created by Will Harris on 18/07/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSSearchBarController.h"


const static CGFloat kSmallSearchBarWidth = 200.0;
const static CGFloat kLargeSearchBarWidth = 300.0;
const static CGRect kSmallSearchBarFrame = {
    .size.width = kSmallSearchBarWidth,
    .size.height = 44.0,
    .origin.x = kLargeSearchBarWidth - kSmallSearchBarWidth,
    .origin.y = 0.0
};
const static CGRect kLargeSearchBarFrame = {
    .size.width = kLargeSearchBarWidth,
    .size.height = 44.0,
    .origin.x = 0.0,
    .origin.y = 0.0
};

@interface CSSearchBarController () <UISearchBarDelegate>

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UINavigationItem *navigationItem;

@end

@implementation CSSearchBarController

- (id)initWithPlaceholder:(NSString *)placeholder
           navigationItem:(UINavigationItem *)navigationItem
{
    self = [self init];
    if (self) {
        self.navigationItem = navigationItem;
        self.searchBar = [[UISearchBar alloc]
                          initWithFrame:kSmallSearchBarFrame];
        self.searchBar.delegate = self;
        self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.searchBar.placeholder = placeholder;
        UIBarButtonItem *searchItem = [[UIBarButtonItem alloc]
                                       initWithCustomView:self.searchBar];
        searchItem.width = kLargeSearchBarWidth;
        [navigationItem setRightBarButtonItem:searchItem];
    }
    return self;
}

- (void)dealloc
{
    [self.navigationItem setRightBarButtonItem:nil];
}

- (NSString *)query
{
    return self.searchBar.text;
}

- (void)setQuery:(NSString *)query
{
    self.searchBar.text = query;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [UIView animateWithDuration:0.25 animations:^{
        searchBar.frame = kLargeSearchBarFrame;
        [searchBar layoutSubviews];
    }];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [UIView animateWithDuration:0.25 animations:^{
        searchBar.frame = kSmallSearchBarFrame;
        [searchBar layoutSubviews];
    }];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    SEL sel = @selector(searchBarSearchButtonClicked:);
    if ([self.delegate respondsToSelector:sel]) {
        [self.delegate searchBarSearchButtonClicked:searchBar];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if ( ! [searchBar.text length]) {
        SEL sel = @selector(searchBarSearchButtonClicked:);
        if ([self.delegate respondsToSelector:sel]) {
            [self.delegate searchBarSearchButtonClicked:searchBar];
        }
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    SEL sel = @selector(searchBar:textDidChange:);
    if ([self.delegate respondsToSelector:sel]) {
        [self.delegate searchBar:searchBar textDidChange:searchText];
    }
}

@end
