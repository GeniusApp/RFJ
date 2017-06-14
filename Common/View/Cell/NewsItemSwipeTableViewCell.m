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

@interface NewsItemSwipeTableViewCell()<UIScrollViewDelegate, NewsItemViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSArray<NewsItemView *> *allNewsViews;
@property (assign) NSInteger currentPage;
@end

@implementation NewsItemSwipeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
     self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.scrollView setPagingEnabled:YES];
    self.scrollView.delegate = self;
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    self.allNewsViews = [NSArray array];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)updateCurrentPage {
    CGFloat width = self.scrollView.frame.size.width;
    CGFloat activePage = floor((self.scrollView.contentOffset.x - width / 2) / width)+1;
    
    if(self.currentPage != (NSInteger)activePage) {
        self.currentPage = (NSInteger)activePage;
        
        [self loadNewsAtIndex:self.currentPage + 1];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateCurrentPage];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self updateCurrentPage];
}

- (void) display {
    if(VALID_NOTEMPTY(self.newsItems, NSArray<NewsItem *>) && ISEMPTY(self.allNewsViews)) {
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width * [self.newsItems count], self.scrollView.frame.size.height)];

        for(NSInteger i = 0; i < [self.newsItems count]; i++) {
            NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"NewsItemView" owner:self options:nil];
            
            if(VALID_NOTEMPTY(views, NSArray)) {
                NewsItemView *contentView = (NewsItemView *)[views objectAtIndex:0];
                contentView.frame = CGRectMake(i * self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
                contentView.delegate = self;
                
                [self.scrollView addSubview:contentView];
                
                self.allNewsViews = [self.allNewsViews arrayByAddingObject:contentView];
                
                //Load the first and the next news if possible
                if(i == 0 || i == 1) {
                    [self loadNewsAtIndex:i];
                }
            }
        }
    }
    
    [self.contentView setNeedsLayout];
    [self.contentView setNeedsUpdateConstraints];
    [self.contentView updateConstraints];
    [self.contentView layoutIfNeeded];
    
    for(NSInteger i = 0; i < [self.allNewsViews count]; i++) {
        NewsItemView *contentView = [self.allNewsViews objectAtIndex:i];
        
        contentView.frame = CGRectMake(i * self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    }
}

-(void)loadNewsAtIndex:(NSInteger)index {
    if (VALID_NOTEMPTY(self.newsItems, NSArray<NewsItem *> ) && VALID_NOTEMPTY(self.allNewsViews, NSArray<NewsItemView *>) && index >= 0 && index < [self.newsItems count]) {
        NewsItem *currentItem = [self.newsItems objectAtIndex:index];
        NewsItemView *contentView = [self.allNewsViews objectAtIndex:index];
        
        [contentView setItem:currentItem];
    }
}

- (void) moveRight {
    if(self.currentPage + 1 < [self.newsItems count]) {
        CGFloat nextX = (self.currentPage + 1) * self.scrollView.frame.size.width;
        
        [self.scrollView scrollRectToVisible:CGRectMake(nextX, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height) animated:YES];
    }
}

- (void) moveLeft {
    if(self.currentPage - 1 >= 0) {
        CGFloat nextX = (self.currentPage - 1) * self.scrollView.frame.size.width;
        
        [self.scrollView scrollRectToVisible:CGRectMake(nextX, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height) animated:YES];
    }
}

-(void)NewsItemDidTap:(NewsItemView *)item {
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(NewsItemSwipeDidTap:withNewsItem:)]) {
        [self.delegate NewsItemSwipeDidTap:self withNewsItem:item.item];
    }
}

@end
