//
//  CSRefineBarRemoveButtonView.m
//  SimplyShop
//
//  Created by Will Harris on 16/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRefineBarRemoveButtonView.h"
#import "CSRefine.h"
#import "CSRefineRemoveButton.h"

@interface CSRefineBarRemoveButtonView ()

@property (weak, nonatomic) UIButton *button;

- (void)initialize;
- (NSString *)titleForRefine;

@end

@implementation CSRefineBarRemoveButtonView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initialize];
}

- (void)initialize
{
    self.button = [CSRefineRemoveButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = self.bounds;
    self.button.autoresizingMask = (UIViewAutoresizingFlexibleHeight
                                    | UIViewAutoresizingFlexibleWidth);
    [self.button addTarget:self
                    action:@selector(didTapButton:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.button setTitle:[self titleForRefine] forState:UIControlStateNormal];
    [self addSubview:self.button];
    
    [self addObserver:self
           forKeyPath:@"refine"
              options:NSKeyValueObservingOptionNew
              context:NULL];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"refine"];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize result = [self.button sizeThatFits:size];
    result.height = size.height;
    return result;
}

- (IBAction)didTapButton:(id)sender
{
    [self.delegate didTapRemoveButton:self];
}

- (NSString *)titleForRefine
{
    return [NSString stringWithFormat:@"%@: %@",
            self.refine.name, self.refine.valueName];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self && [keyPath isEqualToString:@"refine"]) {
        [self.button setTitle:[self titleForRefine] forState:UIControlStateNormal];
    }
}

@end
