//
//  NewsItemTableViewCell.m
//  rfj
//
//  Created by Nuno Silva on 21/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <MagicalRecord/MagicalRecord.h>
#import "NewsItemTableViewCell.h"
#import "Validation.h"
#import "Constants.h"
#import "UIImageView+WebCache.h"
#import "MenuItem+CoreDataProperties.h"

@interface NewsItemTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *coverView;

@end

@implementation NewsItemTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    gestureRecognizer.numberOfTapsRequired = 1;
    
    [self.coverView setUserInteractionEnabled:YES];
    [self.coverView addGestureRecognizer:gestureRecognizer];
}

-(void)setItem:(NewsItem *)item {
    if(VALID(item, NewsItem)) {
        _item = item;
        self.titleLabel.text = item.title;

        [self.coverImage sd_setImageWithURL:[NSURL URLWithString:item.image] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if(VALID(image, UIImage)) {
                [self.coverImage setImage:image];
            }
        }];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"'Actualisé le' dd.MM.y - HH:mm"];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        
        self.dateLabel.text = [formatter stringFromDate:item.updateDate];
        
        NSArray<MenuItem *> *allItems = [MenuItem MR_findAll];
        
        NSInteger categoryIndex = [allItems indexOfObjectPassingTest:^BOOL(MenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return obj.id == item.navigationId;
        }];
        
        if(categoryIndex != NSNotFound) {
            self.categoryLabel.text = [allItems objectAtIndex:categoryIndex].name;
        }
        else {
            self.categoryLabel.text = @"";
        }
        
        if(item.read) {
            self.dateLabel.textColor = kNewsReadColor;
            self.titleLabel.textColor = kNewsReadColor;
            self.categoryLabel.textColor = kNewsReadColor;
        }
    }
}

-(void)handleTap:(UIGestureRecognizer *)gestureRecognizer {
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(NewsItemDidTap:)]) {
        [self.delegate NewsItemDidTap:self];
    }
}

@end
