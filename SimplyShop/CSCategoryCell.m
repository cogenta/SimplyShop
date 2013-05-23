//
//  CSCategoryCell.m
//  SimplyShop
//
//  Created by Will Harris on 23/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSCategoryCell.h"
#import "CSTheme.h"
#import <CSApi/CSAPI.h>

@interface CSCategoryCell ()

@property (nonatomic, strong) NSObject *address;
@property (nonatomic, strong) NSObject<CSCategory> *category;

- (void)initialize;
- (void)updateContent;

@end

@implementation CSCategoryCell

@synthesize theme;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    [self addSubview:[[[NSBundle mainBundle]
                       loadNibNamed:@"CSCategoryCell"
                       owner:self
                       options:nil]
                      objectAtIndex:0]];
    self.address = nil;
    [self updateContent];
}

- (void)setTheme:(id<CSTheme>)newTheme
{
    if (newTheme == theme) {
        return;
    }
    
    theme = newTheme;
    UIImage *backgroundImage = [theme collectionViewCellBackgroundImage];
    self.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.selected = NO;
    
    self.categoryNameLabel.text = @"";
    self.categoryNameLabel.hidden = NO;
    
    self.address = nil;
    self.category = nil;
}

- (void)setLoadingAddress:(NSObject *)address
{
    self.category = nil;
    self.address = address;
    [self updateContent];
}

- (void)setCategory:(NSObject<CSCategory> *)category
            address:(NSObject *)address
{
    if (address != self.address) {
        // We ignore the category data because the cell has been reused for a
        // different retailer.
        return;
    }
    
    self.category = category;
    [self updateContent];
}

- (void)updateContent
{
    if (self.category) {
        self.categoryNameLabel.text = self.category.name;        
    } else {
        self.categoryNameLabel.text = @"...";
    }
}

@end
