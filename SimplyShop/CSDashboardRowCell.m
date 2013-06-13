//
//  CSDashboardRowCell.m
//  SimplyShop
//
//  Created by Will Harris on 05/06/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSDashboardRowCell.h"
#import "CSAddressCell.h"

void
check_initialized(id cell) {
}

@interface CSDashboardRowCell ()

@property (nonatomic) BOOL _initialized;
- (void)_checkInitialized;

@end

@implementation CSDashboardRowCell

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
        [self initialize];
        [self _checkInitialized];
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
    self._initialized = YES;
    UIView *subview = [[[NSBundle mainBundle]
                        loadNibNamed:[self cellNibName]
                        owner:self
                        options:nil]
                       objectAtIndex:0];
    self.frame = subview.frame;
    [self addSubview:subview];
    [self registerClasses];
}

- (void)registerClasses
{
    Class itemCellClass = [self itemCellClass];
    NSAssert([itemCellClass conformsToProtocol:@protocol(CSAddressCell)],
             @"Item cells must conform to CSAddressCell");
             
    [self.collectionView registerClass:itemCellClass
            forCellWithReuseIdentifier:@"CSDashboardRowItemCell"];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return [self modelCount];
}

- (id)addressForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell<CSAddressCell> *cell =
    [self collectionView:collectionView
        rowCellForItemAtIndexPath:indexPath];
    
    [self rowCellNeedsReload:cell
                 withAddress:[self addressForItemAtIndexPath:indexPath]];
    
    return cell;
}

- (UICollectionViewCell<CSAddressCell> *)collectionView:(UICollectionView *)collectionView
               rowCellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"CSDashboardRowItemCell"
                                                     forIndexPath:indexPath];
}

- (void)rowCellNeedsReload:(UICollectionViewCell<CSAddressCell> *)cell
               withAddress:(NSObject *)address;
{
    [cell setLoadingAddress:address];
    [self fetchModelWithAddress:address done:^(id result, NSError *error) {
        if (error) {
            [cell setError:error address:address];
            return;
        }
        
        [cell setModel:result address:address];
    }];
}

- (void)fetchModelWithAddress:(id)address
                         done:(void (^)(id model, NSError *error))done
{
    [self fetchModelAtIndex:((NSIndexPath *)address).row done:done];
}

- (void)reloadData
{
    [self.collectionView reloadData];
}

- (NSString *)cellNibName
{
    return @"CSCategoriesCell";
}

- (Class)itemCellClass
{
    return [UITableViewCell class];
}

- (NSInteger)modelCount
{
    return 0;
}

- (void)fetchModelAtIndex:(NSUInteger)index
                 done:(void (^)(id model, NSError *error))done
{
    done(nil, nil);
}

@end
