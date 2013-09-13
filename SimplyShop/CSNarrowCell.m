//
//  CSNarrowCell.m
//  SimplyShop
//
//  Created by Will Harris on 13/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSNarrowCell.h"
#import <CSApi/CSAPI.h>

@interface CSNarrowCell ()

@property (nonatomic, strong) id<CSNarrow> narrow;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) id<CSNarrowList> list;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) BOOL _initialized;

- (void)initialize;
- (void)_checkInitialized;

@end

@implementation CSNarrowCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
        [self _checkInitialized];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initialize];
    [self _checkInitialized];
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)_checkInitialized
{
    NSAssert(self._initialized,
             @"[CSDashboardRowCell initialize] must be called");
}

- (void)initialize
{
    self.textLabel.text = @"Loading...";
    self._initialized = YES;
}

- (void)prepareForReuse
{
    self.list = nil;
    self.index = 0;
    self.narrow = nil;
    self.textLabel.textColor = [UIColor darkTextColor];
}

- (void)setNarrowList:(id<CSNarrowList>)list index:(NSUInteger)index
{
    self.list = list;
    self.index = index;
    self.narrow = nil;
    
    self.textLabel.text = @"Loading...";

    [self.list getNarrowAtIndex:index
                       callback:^(id<CSNarrow> narrow, NSError *error)
    {
        if (list != self.list || index != self.index) {
            // Ignore response because this cell has been reused.
            return;
        }
        
        if (error) {
            self.error = error;
            self.textLabel.text = @"Error";
            self.textLabel.textColor = [UIColor redColor];
            return;
        }
        
        self.narrow = narrow;
        self.textLabel.text = narrow.title;
    }];
}

@end
