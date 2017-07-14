//
//  NewsItemSwipeTableViewCell.h
//  rfj
//
//  Created by Gonçalo Girão on 31/05/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsItem+CoreDataProperties.h"

@class NewsItemSwipeTableViewCell;

@protocol NewsItemSwipeTableViewCellDelegate<NSObject>
-(void)NewsItemSwipeDidTap:(NewsItemSwipeTableViewCell *)item withNewsItem:(NewsItem *)newsItem;
@end

@interface NewsItemSwipeTableViewCell : UITableViewCell
@property (assign, nonatomic) id<NewsItemSwipeTableViewCellDelegate> delegate;
@property (strong, nonatomic) NSArray <NewsItem *> *newsItems;
- (void) moveLeft;
- (void) moveRight;
@end
