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
#import "NSDateFormatterInstance.h"

@interface NewsItemTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *sponsorLabel;
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIImageView *imageType;

@end

@implementation NewsItemTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Uncomment following lines to revert handleTap - by ggirao
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    gestureRecognizer.numberOfTapsRequired = 1;
    
    [self.coverView setUserInteractionEnabled:YES];
    [self.coverView addGestureRecognizer:gestureRecognizer];
}

-(void)setItem:(NewsItem *)item {
    if(_item==item)
        return;
    _item = item;
    if (item.type == 1) {
        NSString *concat1 = self.titleLabel.text;
        NSString *concat2 = @"     ";
        self.titleLabel.text = [NSString stringWithFormat:@"%@ %@", concat2, concat1];
        [self.imageType setImage:[UIImage imageNamed:@"image"]];
    } else if (item.type == 2) {
        NSString *concat1 = self.titleLabel.text;
        NSString *concat2 = @"     ";
        self.titleLabel.text = [NSString stringWithFormat:@"%@ %@", concat2, concat1];
        [self.imageType setImage:[UIImage imageNamed:@"sound"]];
    } else if (item.type == 3) {
        NSString *concat1 = self.titleLabel.text;
        NSString *concat2 = @"     ";
        self.titleLabel.text = [NSString stringWithFormat:@"%@ %@", concat2, concat1];
        [self.imageType setImage:[UIImage imageNamed:@"play"]];
    } else {
        self.titleLabel.text = item.title;
    }

    [self.coverImage sd_setImageWithURL:[NSURL URLWithString:item.retina1] placeholderImage:[UIImage imageNamed:@"no-image.png"]];
    
    if (item.type == 4) {
        self.dateLabel.text = @"";
    } else {
        self.dateLabel.text = [NSDateFormatterInstance formatFull:item.updateDate];
    }
    // TODO AN Do not call indexOfObjectPassingTest:. Move format to init
    NSArray<MenuItem *> *allItems = [MenuItem MR_findAll];
    
    NSInteger categoryIndex = [allItems indexOfObjectPassingTest:^BOOL(MenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return obj.id == item.navigationId;
    }];
    if (item.type == 4) {
        self.sponsorLabel.hidden = NO;
        self.categoryLabel.text = @"Publireportage";
    } else {
        if(categoryIndex != NSNotFound) {
            self.categoryLabel.text = [allItems objectAtIndex:categoryIndex].name;
        }
        else {
            self.categoryLabel.text = @"";
        }
    }
    
    if(item.read) {
        self.dateLabel.textColor = kNewsReadColor;
        self.titleLabel.textColor = kNewsReadColor;
        self.categoryLabel.textColor = kNewsReadColor;
    }
    
}

-(void)handleTap:(UIGestureRecognizer *)gestureRecognizer {
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(NewsItemDidTap:)]) {
        [self.delegate NewsItemDidTap:self];
    }
}

@end
