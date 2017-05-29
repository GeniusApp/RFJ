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
    NSLog(@"LEFT ARROW PRESSED");
}
- (IBAction)rightArrowTapped:(UIButton *)sender {
    NSLog(@"RIGHT ARROW PRESSED");
}

@end
