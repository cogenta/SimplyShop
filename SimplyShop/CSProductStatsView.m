//
//  CSProductStatsView.m
//  SimplyShop
//
//  Created by Will Harris on 30/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductStatsView.h"
#import "CSProductStats.h"

@interface CSProductStatsView ()

@property (strong, nonatomic) NSMutableArray *labelLabels;
@property (strong, nonatomic) NSMutableArray *valueLabels;

- (void)initialize;

@end

@implementation CSProductStatsView

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
    self.labelFont = [UIFont boldSystemFontOfSize:10.0];
    self.labelColor = [UIColor darkTextColor];
    self.valueFont = [UIFont systemFontOfSize:10.0];
    self.valueColor = [UIColor darkTextColor];
    
    CGSize lineSize = [@"X" sizeWithFont:self.labelFont];
    self.heightForRow = lineSize.height;
    self.margin = lineSize.width;
}

- (CGFloat)maxLabelWidth
{
    CGFloat result = 0.0;
    for (CSProductStat *stat in _stats.stats) {
        CGFloat width = [stat.label sizeWithFont:_labelFont].width;
        if (width > result) {
            result = width;
        }
    }
    return result;
}

- (void)ensureLabelsInArray:(NSMutableArray **)labels
                 matchCount:(NSUInteger)rows
                       font:(UIFont *)font
                      color:(UIColor *)color;
{
    if ( ! *labels) {
        *labels = [NSMutableArray arrayWithCapacity:rows];
    }
    
    while ([*labels count] < rows) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.font = font;
        label.textColor = color;
        label.numberOfLines = 0;
        [self addSubview:label];
        [*labels addObject:label];
    }
    
    while ([*labels count] > rows) {
        UILabel *label = [*labels lastObject];
        [label removeFromSuperview];
        [*labels removeLastObject];
    }
}

- (void)setStats:(CSProductStats *)stats
{
    _stats = stats;
    NSArray *rows = stats.stats;
    NSUInteger count = [rows count];
    
    NSMutableArray *labelLabels = _labelLabels;
    [self ensureLabelsInArray:&labelLabels matchCount:count font:_labelFont color:_labelColor];
    _labelLabels = labelLabels;
    
    NSMutableArray *valueLabels = _valueLabels;
    [self ensureLabelsInArray:&valueLabels matchCount:count font:_valueFont color:_labelColor];
    _valueLabels = valueLabels;
    
    NSAssert([_labelLabels count] == count, nil);
    NSAssert([_valueLabels count] == count, nil);

    for (NSUInteger i = 0 ; i < count ; ++i) {
        CSProductStat *row = rows[i];
        [_labelLabels[i] setText:row.label];
        [_valueLabels[i] setText:row.value];
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)layoutSubviews
{
    NSArray *rows = _stats.stats;
    NSUInteger count = [rows count];

    NSAssert([_labelLabels count] == count, nil);
    NSAssert([_valueLabels count] == count, nil);
    
    CGSize maxSize = [UIScreen mainScreen].bounds.size;
    CGFloat valueX = [self maxLabelWidth] + self.margin;
    
    for (NSUInteger i = 0 ; i < count ; ++i) {
        CGRect labelLabelFrame;
        labelLabelFrame.origin = CGPointMake(0.0, _heightForRow * i);
        labelLabelFrame.size = [_labelLabels[i] sizeThatFits:maxSize];
        [_labelLabels[i] setFrame:labelLabelFrame];

        CGRect valueLabelFrame;
        valueLabelFrame.origin = CGPointMake(valueX, _heightForRow * i);
        valueLabelFrame.size = [_valueLabels[i] sizeThatFits:maxSize];
        [_valueLabels[i] setFrame:valueLabelFrame];
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(size.width, _heightForRow * [_stats.stats count]);
}

@end
