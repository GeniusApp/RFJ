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
#import "UIImageView+WebCache.h"

@interface NewsItemSwipeTableViewCell()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSArray<UIImageView *> *allImages;
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
    self.allImages = [NSArray array];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat width = scrollView.frame.size.width;
    CGFloat activePage = floor((scrollView.contentOffset.x - width / 2) / width)+1;
    
    if(self.currentPage != (NSInteger)activePage) {
        self.currentPage = (NSInteger)activePage;
        
        [self loadNewsAtIndex:self.currentPage + 1];
    }
}

- (void) display {
    if(VALID_NOTEMPTY(self.newsItems, NSArray<NewsItem *>) && ISEMPTY(self.allImages)) {
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width * [self.newsItems count], self.scrollView.frame.size.height)];

        for(NSInteger i = 0; i < [self.newsItems count]; i++) {
            UIImageView *contentImage = [[UIImageView alloc] init];
            contentImage.contentMode = UIViewContentModeScaleAspectFill;
            contentImage.frame = CGRectMake(i * self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
            contentImage.clipsToBounds = YES;
            
            [self.scrollView addSubview:contentImage];
            
            self.allImages = [self.allImages arrayByAddingObject:contentImage];
            
            //Load the first and the next news if possible
            if(i == 0 || i == 1) {
                [self loadNewsAtIndex:i];
            }
        }
    }
    
    [self.contentView setNeedsLayout];
    [self.contentView setNeedsUpdateConstraints];
    [self.contentView updateConstraints];
    [self.contentView layoutIfNeeded];
    
    for(NSInteger i = 0; i < [self.allImages count]; i++) {
        UIImageView *contentImage = [self.allImages objectAtIndex:i];
        
        contentImage.frame = CGRectMake(i * self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    }
}

-(void)loadNewsAtIndex:(NSInteger)index {
    if (VALID_NOTEMPTY(self.newsItems, NSArray<NewsItem *> ) && VALID_NOTEMPTY(self.allImages, NSArray<UIImageView *>) && index >= 0 && index < [self.newsItems count]) {
        NewsItem *currentItem = [self.newsItems objectAtIndex:index];
        UIImageView *currentImage = [self.allImages objectAtIndex:index];
        
        if ([currentItem.retina1 rangeOfString:@"jpg"].location == NSNotFound && [currentItem.retina1 rangeOfString:@"JPG"].location == NSNotFound && [currentItem.retina1 rangeOfString:@"png"].location == NSNotFound && [currentItem.retina1 rangeOfString:@"PNG"].location == NSNotFound) {
            
            UIImage *noImage = [UIImage imageNamed:@"no-image.png"];
            [currentImage setImage:noImage];
        } else {
            [currentImage sd_setImageWithURL:[NSURL URLWithString:currentItem.retina1] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
                if(VALID(image, UIImage)) {
                    [currentImage setImage:image];
                }
            }];
        }
        
    }
}

- (void) moveRight {
}

- (void) moveLeft {
    
}

@end
