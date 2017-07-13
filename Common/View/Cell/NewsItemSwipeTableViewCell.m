//
//  NewsItemSwipeTableViewCell.m
//  rfj
//
//  Created by Gonçalo Girão on 31/05/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import "NewsItemSwipeTableViewCell.h"
#import "Constants.h"
#import "Validation.h"
#import "NewsItemView.h"
#import "SwipeView.h"

@interface NewsItemSwipeTableViewCell()<SwipeViewDataSource,SwipeViewDelegate>
@property (weak, nonatomic) IBOutlet SwipeView *swipeView;
@end

@implementation NewsItemSwipeTableViewCell {
    UINib * subviewNib;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.swipeView.pagingEnabled = YES;
    self.swipeView.delegate = self;
    self.swipeView.dataSource = self;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    subviewNib = [UINib nibWithNibName:@"NewsItemView" bundle:nil];
}

- (void) setNewsItems:(NSArray<NewsItem *> *)newsItems {
    if(_newsItems!= newsItems) {
        _newsItems = newsItems;
        [self.swipeView reloadData];
    }
}

#pragma mark - SwipeViewDataSource SwipeViewDelegate

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
    return _newsItems?_newsItems.count:0;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(NewsItemView *)view {
    if(_newsItems==nil) { return [UIView new]; }
    if(view==nil) {
        view = (id)[subviewNib instantiateWithOwner:self options:nil][0];
    }
    [view setItem:_newsItems[index]];
    return view;
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView {
    return self.swipeView.bounds.size;
}

- (void) swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index {
    if(_newsItems==nil) return;
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(NewsItemSwipeDidTap:withNewsItem:)]) {
        [self.delegate NewsItemSwipeDidTap:self withNewsItem:_newsItems[index]];
    }
}

#pragma mark -

- (void) moveRight {
    if(_newsItems==nil) return;
    [self.swipeView scrollByNumberOfItems:1 duration:.5];
}

- (void) moveLeft {
    if(_newsItems==nil) return;
    [self.swipeView scrollByNumberOfItems:-1 duration:.5];
}

@end
