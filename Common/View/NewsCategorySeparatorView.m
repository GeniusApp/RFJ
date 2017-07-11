//
//  NewsCategorySeparatorView.m
//  rfj
//
//  Created by Nuno Silva on 21/03/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import "NewsCategorySeparatorView.h"

@interface NewsCategorySeparatorView()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *leftArrow;
@property (weak, nonatomic) IBOutlet UIButton *rightArrow;

@end

@implementation NewsCategorySeparatorView

-(void)setName:(NSString *)name {
    if ([name rangeOfString:@"Région &"].location == NSNotFound) {
        self.nameLabel.text = name;
    } else {
        self.leftArrow.hidden = YES;
        self.rightArrow.hidden = YES;
        self.nameLabel.text = @"Région & Sport";
    }
}
- (IBAction)leftArrowTapped:(UIButton *)sender {
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(NewsCategorySeparatorViewDidClickLeft:)]) {
        [self.delegate NewsCategorySeparatorViewDidClickLeft:self];
    }
}
- (IBAction)rightArrowTapped:(UIButton *)sender {
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(NewsCategorySeparatorViewDidClickRight:)]) {
        [self.delegate NewsCategorySeparatorViewDidClickRight:self];
    }
}

@end
