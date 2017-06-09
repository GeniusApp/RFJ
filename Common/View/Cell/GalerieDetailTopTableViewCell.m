//
//  GalerieDetailTopTableViewCell.m
//  rfj
//
//  Created by Gonçalo Girão on 08/06/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import "GalerieDetailTopTableViewCell.h"
#import "DataManager.h"
#import "BDGShare.h"
#import "Constants.h"

@interface GalerieDetailTopTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) NSString *shareBaseURL;
@property (strong, nonatomic) NSString *link;

@end
@implementation GalerieDetailTopTableViewCell
- (IBAction)shareFacebook:(id)sender {

    
    NSString *url = [NSString stringWithFormat:@"%@%@", self.shareBaseURL, self.link];
    
    [BDGSharing shareFacebook:self.titleLabel.text urlStr:url image:nil completion:nil];
}
- (IBAction)shareTwitter:(id)sender {

    
    NSString *url = [NSString stringWithFormat:@"%@%@", self.shareBaseURL, self.link];
    
    [BDGSharing shareTwitter:self.titleLabel.text urlStr:url image:nil completion:nil];
}
- (IBAction)shareWhatsApp:(id)sender {

    
    NSString *url = [NSString stringWithFormat:@"%@%@", self.shareBaseURL, self.link];
    
    NSURL *whatsAppUrl = [NSURL URLWithString:[NSString stringWithFormat:@"whatsapp://send?text=%@", [[NSString stringWithFormat:@"%@ %@", self.titleLabel.text, url] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
    
    if ([[UIApplication sharedApplication] canOpenURL:whatsAppUrl]) {
        if([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [[UIApplication sharedApplication] openURL:whatsAppUrl options:@{} completionHandler:nil];
        }
        else {
            [[UIApplication sharedApplication] openURL:whatsAppUrl];
        }
    }
}
- (IBAction)shareLink:(id)sender {

    
    NSString *url = [NSString stringWithFormat:@"%@%@", self.shareBaseURL, self.link];
    
    [BDGSharing shareEmail:self.titleLabel.text mailBody:url recipients:nil isHTML:NO completion:nil];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    gestureRecognizer.numberOfTapsRequired = 1;
    
    [self.contentView setUserInteractionEnabled:YES];
    [self.contentView addGestureRecognizer:gestureRecognizer];
    
    // Initialization code
    if([[DataManager singleton] isRFJ]) {
        self.shareBaseURL = kShareURLRFJ;
    }
    
    if([[DataManager singleton] isRJB]) {
        self.shareBaseURL = kShareURLRJB;
    }
    
    if([[DataManager singleton] isRTN]) {
        self.shareBaseURL = kShareURLRTN;
    }
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setTitle:(NSString *)title andAuthor:(NSString *)author andLink:(NSString *)link {
    NSAttributedString *authorString = [[NSAttributedString alloc] initWithData:[author dataUsingEncoding:NSUTF8StringEncoding]
                                     options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                               NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                          documentAttributes:nil error:nil];
    self.link = link;
    self.titleLabel.text = title;
    self.authorLabel.attributedText = authorString;
}

-(void)handleTap:(UIGestureRecognizer *)gestureRecognizer {
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(GalerieDetailDidTap:)]) {
        [self.delegate GalerieDetailDidTap:self];
    }
}
@end
