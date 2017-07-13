//
//  GalerieItemSwipeTableViewCell.m
//  rfj
//
//  Created by Gonçalo Girão on 31/05/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import "GalerieItemSwipeTableViewCell.h"
#import "Constants.h"
#import "Validation.h"
#import "GalerieItemView.h"
#import "SwipeView.h"

@interface GalerieItemSwipeTableViewCell()<SwipeViewDataSource,SwipeViewDelegate>
@property (weak, nonatomic) IBOutlet SwipeView *swipeView;
@end

@implementation GalerieItemSwipeTableViewCell {
    UINib * subviewNib;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.swipeView.pagingEnabled = YES;
    self.swipeView.delegate = self;
    self.swipeView.dataSource = self;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    subviewNib = [UINib nibWithNibName:@"GalerieItemView" bundle:nil];
}

- (void) setGalerieItems:(NSArray<GalerieItem *> *)galerieItems {
    if(_galerieItems != galerieItems) {
        _galerieItems = galerieItems;
        [self.swipeView reloadData];
    }
}

#pragma mark - SwipeViewDataSource SwipeViewDelegate


- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
    return _galerieItems?_galerieItems.count:0;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(GalerieItemView *)view {
    if(_galerieItems==nil) { return [UIView new]; }
    if(view==nil) {
        view = (id)[subviewNib instantiateWithOwner:self options:nil][0];
    }
    [view setItem:_galerieItems[index]];
    return view;
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView {
    return self.swipeView.bounds.size;
}

- (void) swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index {
    if(_galerieItems==nil) return;
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(GalerieItemSwipeDidTap:withGalerieItem:)]) {
        [self.delegate GalerieItemSwipeDidTap:self withGalerieItem:_galerieItems[index]];
    }
}

#pragma mark -

- (void) moveRight {
    if(_galerieItems==nil) return;
    [self.swipeView scrollByNumberOfItems:1 duration:.5];
}

- (void) moveLeft {
    if(_galerieItems==nil) return;
    [self.swipeView scrollByNumberOfItems:-1 duration:.5];
}

@end
