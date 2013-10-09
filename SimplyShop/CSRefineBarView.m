//
//  CSRefineBarView.m
//  SimplyShop
//
//  Created by Will Harris on 16/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRefineBarView.h"
#import "CSRefineBarState.h"
#import "CSRefine.h"
#import "CSRefineBarRemoveButtonView.h"

const static CGPoint kButtonOrigin = { .x = 9.0, .y = 7.0 };
const static CGSize kButtonSize = { .width = 94.0, .height = 30.0 };
const static CGFloat kButtonGap = 9.0;

@interface CSRefineBarView () <CSRefineBarRemoveButtonViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIView *loadedView;
@property (weak, nonatomic) IBOutlet UIButton *refineButton;

@property (strong, nonatomic) UIView *hiddenView;

- (IBAction)didTabRefineButton:(id)sender;
- (IBAction)didTapRemoveButton:(id)sender;

@property (strong, nonatomic) NSMutableDictionary *refineButtons;
@property (assign, nonatomic) BOOL loading;

- (void)initialize;

- (void)setLoadingState;
- (void)setLoadedState;

- (void)stateChanged;

@end

@implementation CSRefineBarView

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
    [[NSBundle mainBundle] loadNibNamed:@"CSRefineBarView"
                                  owner:self
                                options:nil];
    self.refineButtons = [[NSMutableDictionary alloc] init];
    [self setLoadingState];
    [self addObserver:self
           forKeyPath:@"state"
              options:NSKeyValueObservingOptionNew
              context:NULL];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"state"];
}

- (void)setLoadingState
{
    if (self.loading) {
        return;
    }
    
    self.loading = YES;
    [self insertSubview:self.loadingView belowSubview:self.loadedView];
    self.hiddenView = self.loadedView;
    [self.loadedView removeFromSuperview];
}

- (void)setLoadedState
{
    if ( ! self.loading) {
        return;
    }
    
    self.loading = NO;
    [self insertSubview:self.loadedView belowSubview:self.loadingView];
    self.hiddenView = self.loadingView;
    [self.loadingView removeFromSuperview];
}

- (void)layoutSubviews
{
    self.loadingView.frame = self.bounds;
    [self.loadingView setNeedsLayout];

    self.loadedView.frame = self.bounds;
    [self.loadedView setNeedsLayout];
    
    CGPoint nextOrigin = kButtonOrigin;
    for (CSRefine *refine in self.state.refines) {
        CSRefineBarRemoveButtonView *button = self.refineButtons[refine];
        NSAssert(button != nil, @"there should be a button for every refine");
        NSAssert(button.superview == self, @"buttons should be subviews of the bar");
        CGSize size = [button sizeThatFits:kButtonSize];
        CGRect frame = { .origin = nextOrigin, .size = size };
        button.frame = frame;
        nextOrigin.x += size.width + kButtonGap;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self && [keyPath isEqualToString:@"state"]) {
        [self stateChanged];
    }
}

- (void)stateChanged
{
    if ( ! self.state) {
        [self setLoadingState];
        return;
    }
    
    self.refineButton.hidden = ! self.state.canRefineMore;
    
    NSSet *nextRefineSet = [NSSet setWithArray:self.state.refines];
    NSMutableArray *refinesToRemove = [[NSMutableArray alloc] init];
    for (CSRefine *refine in [self.refineButtons allKeys]) {
        if ( ! [nextRefineSet containsObject:refine]) {
            [refinesToRemove addObject:refine];
        }
    }
    
    for (CSRefine *refineToRemove in refinesToRemove) {
        CSRefineBarRemoveButtonView *button = self.refineButtons[refineToRemove];
        [self.refineButtons removeObjectForKey:refineToRemove];
        [button removeFromSuperview];
    }

    for (CSRefine *refine in self.state.refines) {
        CSRefineBarRemoveButtonView *button = self.refineButtons[refine];
        if (button != nil) {
            continue;
        }
        
        CGRect frame = { .origin = kButtonOrigin, .size = kButtonSize };
        button = [[CSRefineBarRemoveButtonView alloc] initWithFrame:frame];
        button.refine = refine;
        button.delegate = self;
        [self addSubview:button];
        self.refineButtons[refine] = button;
    }
    
    [self setLoadedState];
}

- (IBAction)didTabRefineButton:(id)sender
{
    [self.delegate refineBarView:self didRequestRefineMenu:sender];
}

- (void)didTapRemoveButton:(CSRefineBarRemoveButtonView *)sender
{
    NSAssert([sender isKindOfClass:[CSRefineBarRemoveButtonView class]],
             @"button should be a refine remove button");
    [self.delegate refineBarView:self didSelectRemoval:sender.refine];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    self.backgroundColor = [UIColor clearColor];
    UIColor *backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    self.loadingView.backgroundColor = backgroundColor;
    self.loadedView.backgroundColor = backgroundColor;
    _backgroundImage = backgroundImage;
}

@end
