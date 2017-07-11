//
//  WebViewTableViewCell.m
//  rfj
//
//  Created by Gonçalo Girão on 03/07/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import "WebViewTableViewCell.h"

@implementation WebViewTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.webView.scrollView.scrollEnabled = NO;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
