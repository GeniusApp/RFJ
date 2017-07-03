//
//  NewsItemSwipeTableViewCell.m
//  rfj
//
//  Created by Gonçalo Girão on 31/05/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import "GalerieItemSwipeTableViewCell.h"
#import "Constants.h"
#import "Validation.h"
#import "GalerieItemView.h"

@interface GalerieItemSwipeTableViewCell()<UIScrollViewDelegate, GalerieItemViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSArray<GalerieItemView *> *allGaleriesViews;
@property (assign) NSInteger currentPage;
@end

@implementation GalerieItemSwipeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
     self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.scrollView setPagingEnabled:YES];
    self.scrollView.delegate = self;
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    self.allGaleriesViews = [NSArray array];
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
        
        [self loadGalerieAtIndex:self.currentPage + 1];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateCurrentPage];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self updateCurrentPage];
}

- (void) display {
    if(VALID_NOTEMPTY(self.GalerieItems, NSArray<GalerieItem *>) && ISEMPTY(self.allGaleriesViews)) {
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width * [self.GalerieItems count], self.scrollView.frame.size.height)];

        for(NSInteger i = 0; i < [self.GalerieItems count]; i++) {
            NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"GalerieItemView" owner:self options:nil];
            
            if(VALID_NOTEMPTY(views, NSArray)) {
                GalerieItemView *contentView = (GalerieItemView *)[views objectAtIndex:0];
                contentView.frame = CGRectMake(i * self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
                contentView.delegate = self;
                
                [self.scrollView addSubview:contentView];
                
                self.allGaleriesViews = [self.allGaleriesViews arrayByAddingObject:contentView];
                
                //Load the first and the next news if possible
                if(i == 0 || i == 1) {
                    [self loadGalerieAtIndex:i];
                }
            }
        }
    }
    
    [self.contentView setNeedsLayout];
    [self.contentView setNeedsUpdateConstraints];
    [self.contentView updateConstraints];
    [self.contentView layoutIfNeeded];
    
    for(NSInteger i = 0; i < [self.allGaleriesViews count]; i++) {
        GalerieItemView *contentView = [self.allGaleriesViews objectAtIndex:i];
        
        contentView.frame = CGRectMake(i * self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    }
}

-(void)loadGalerieAtIndex:(NSInteger)index {
    if (VALID_NOTEMPTY(self.GalerieItems, NSArray<GalerieItem *> ) && VALID_NOTEMPTY(self.allGaleriesViews, NSArray<GalerieItemView *>) && index >= 0 && index < [self.GalerieItems count]) {
        GalerieItem *currentItem = [self.GalerieItems objectAtIndex:index];
        GalerieItemView *contentView = [self.allGaleriesViews objectAtIndex:index];
        
        [contentView setItem:currentItem];
    }
}

- (void) moveRight {
    if(self.currentPage + 1 < [self.GalerieItems count]) {
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

-(void)GalerieItemDidTap:(GalerieItemView *)item {
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(GalerieItemSwipeDidTap:withGalerieItem:)]) {
        [self.delegate GalerieItemSwipeDidTap:self withGalerieItem:item.item];
    }
}

@end
