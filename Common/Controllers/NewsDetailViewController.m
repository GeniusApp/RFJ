//
//  NewsDetailViewController.m
//  rfj
//
//  Created by Nuno Silva on 27/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <MagicalRecord/MagicalRecord.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"
#import "BDGShare.h"
#import "NewsDetailViewController.h"
#import "MenuItem+CoreDataProperties.h"
#import "MenuItemTableViewCell.h"
#import "NewsManager.h"
#import "NewsSeparatorViewWithBackButton.h"
#import "ResourcesManager.h"
#import "RadioManager.h"
#import "Validation.h"
#import "DataManager.h"
#import "CategoryViewController.h"
#import "WebViewController.h"

@interface NewsDetailViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *newsTitleLabel;
@property (weak, nonatomic) IBOutlet UIWebView *newsContent;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *newsContentHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet NewsSeparatorViewWithBackButton *separatorView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property int splashTimes;
@property (strong, nonatomic) NSArray<MenuItem *> *allMenuItems;
@property (strong, nonatomic) NewsDetail *newsDetail;
@property (strong, nonatomic) NSString *shareBaseURL;
@property (nonatomic, strong) NSString *str;

@end

@implementation NewsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.allMenuItems = [MenuItem MR_findAll];
    
    self.newsContent.scrollView.scrollEnabled = NO;
    
    if([[DataManager singleton] isRFJ]) {
        self.shareBaseURL = kShareURLRFJ;
    }
    
    if([[DataManager singleton] isRJB]) {
        self.shareBaseURL = kShareURLRJB;
    }
    
    if([[DataManager singleton] isRTN]) {
        self.shareBaseURL = kShareURLRTN;
    }
    
    [self showLoading];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    gestureRecognizer.numberOfTapsRequired = 1;
    
    [self.separatorView setUserInteractionEnabled:YES];
    [self.separatorView addGestureRecognizer:gestureRecognizer];
    

    NSString *squareURL = @"https://ww2.lapublicite.ch/webservices/WSBanner.php?type=RFJPAVE";
    [self getJsonResponse:squareURL success:^(NSDictionary *responseDict) {
        self.str = responseDict[@"banner"];
        NSString *fixSquare = @"<div class=\"pub\" id=\"beacon_6b7b3f991\">";
        if (VALID_NOTEMPTY(self.str, NSString)){
            self.str = [fixSquare stringByAppendingString:self.str];
            self.str = [self.str stringByAppendingString:@"</div>"];
        }
    } failure:^(NSError *error) {
        // error handling here ...
    }];

}

-(void)loadNews:(NSNumber *)newsToDisplay {
    [self showLoading];
    [self.scrollView setContentOffset:CGPointZero animated:NO];
    
    if(VALID(newsToDisplay, NSNumber)) {
        self.currentNews = newsToDisplay;
        
        [[NewsManager singleton] fetchNewsDetailForNews:[newsToDisplay integerValue] successBlock:^(NewsDetail *newsDetail) {
            self.newsDetail = newsDetail;
            
            [self refreshNews];
        } andFailureBlock:^(NSError *error, NewsDetail *oldNewsDetail) {
            self.newsDetail = oldNewsDetail;
            
            [self refreshNews];
        }];
    }
}

-(void)showLoading {
    [self.loadingView setHidden:NO];
}

-(void)hideLoading {
    [self.loadingView setHidden:YES];
    [self.view setNeedsLayout];
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraints];
    [self.view layoutIfNeeded];
}

-(void)refreshNews {
    if(VALID(self.newsDetail, NewsDetail)) {
        // load Splash
        
        if (![[NSUserDefaults standardUserDefaults] integerForKey:@"splashTimes"]) {
            [[NSUserDefaults standardUserDefaults] setInteger:self.splashTimes forKey:@"splashTimes"];
            self.splashTimes++;
        }else{
            [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"splashTimes"] + 1 forKey:@"splashTimes"];
        }
        //self.splashTimes++;
        [[NSUserDefaults standardUserDefaults] synchronize];
        int splash = [[NSUserDefaults standardUserDefaults] integerForKey:@"splashTimes"];
        splash++;
        
        if (splash == 7) {
            NSString * storyboardName = @"Main";
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
            UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"SplashViewController"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"splashTimes"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self presentViewController:vc animated:YES completion:nil];
            
        }
        self.newsTitleLabel.text = self.newsDetail.title;
        
        [self showLoading];
        
        NSString *categoryName = @"";
        
        NSInteger categoryIndex = [self.allMenuItems indexOfObjectPassingTest:^BOOL(MenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return obj.id == self.newsDetail.navigationId;
        }];
        
        if(categoryIndex != NSNotFound) {
            categoryName = [self.allMenuItems objectAtIndex:categoryIndex].name;
        }
        
        [self.separatorView setCategoryName:categoryName];
        
        NSString *html = nil;
        
#if kNewsDetailIsHTML
        html = self.newsDetail.content;
#else
        html = [MMMarkdown HTMLStringWithMarkdown:self.newsDetail.content error:nil];
#endif
        
        NSString *header = @"";
        NSString *footer = @"";
        
        Resources *resources = [ResourcesManager resources];
        
        if(VALID(resources, Resources)) {
            if(VALID_NOTEMPTY(resources.htmlHeader, NSString)) {
                header = resources.htmlHeader;
                header = [header stringByAppendingString:@"<link rel=\"stylesheet\" href=\"https://www.rfj.ch/Htdocs/Styles/app.css\" type=\"text/css\" media=\"all\" />"];
                [header = header stringByAppendingString:@"<link rel=\"stylesheet\" href=\"https://www.rfj.ch/Htdocs/Styles/webview.css\" type=\"text/css\" media=\"all\" />"];
                header = [header stringByAppendingString:@"<link rel=\"stylesheet\" href=\"http://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.css\" type=\"text/css\" media=\"all\" />"];
            }
            
            if(VALID_NOTEMPTY(resources.htmlFooter, NSString)) {
                footer = resources.htmlFooter;
            }
        }
        if VALID_NOTEMPTY(self.str, NSString){
            html = [html stringByAppendingString:self.str];
        }
        // IMPORTANT Fix is here. Looks like valid HTML was required
        html = [NSString stringWithFormat:
                @"<!DOCTYPE html>"
                "<html>"
                "<head>"
                "%@"
                "</head>"
                "<body>"
                "<div>"
                "%@"
                "</div>"
                "%@"
                "</body>"
                "</html>",header,html,footer];
        [self.newsContent loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
        [self.separatorView setDate:self.newsDetail.updateDate];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Failed to load the news article" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Go Back" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}
-(void)getJsonResponse:(NSString *)urlStr success:(void (^)(NSDictionary *responseDict))success failure:(void(^)(NSError* error))failure
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    // Asynchronously API is hit here
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                //                                                NSLog(@"%@",data);
                                                if (error)
                                                    failure(error);
                                                else {
                                                    NSDictionary *json  = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                    //                                                    NSLog(@"%@",json);
                                                    success(json);
                                                }
                                            }];
    [dataTask resume];    // Executed First
}
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    //CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    CategoryViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"categoryViewController"];
    
    if(VALID(controller, CategoryViewController)) {
        
        controller.navigationId = @(self.newsDetail.navigationId);
        [self.navigationController pushViewController:controller animated:YES];
    }
    //Do stuff here...
    
    
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)shareFacebook:(id)sender {
    if(!VALID_NOTEMPTY(self.newsDetail, NewsDetail)) {
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@", self.shareBaseURL, self.newsDetail.link];
    
    [BDGSharing shareFacebook:self.newsDetail.title urlStr:url image:nil completion:nil];
}

- (IBAction)shareTwitter:(id)sender {
    if(!VALID_NOTEMPTY(self.newsDetail, NewsDetail)) {
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@", self.shareBaseURL, self.newsDetail.link];
    
    [BDGSharing shareTwitter:self.newsDetail.title urlStr:url image:nil completion:nil];
}

- (IBAction)shareWhatsapp:(id)sender {
    if(!VALID_NOTEMPTY(self.newsDetail, NewsDetail)) {
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@", self.shareBaseURL, self.newsDetail.link];
    
    NSURL *whatsAppUrl = [NSURL URLWithString:[NSString stringWithFormat:@"whatsapp://send?text=%@", [[NSString stringWithFormat:@"%@ %@", self.newsDetail.title, url] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
    
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
    if(!VALID_NOTEMPTY(self.newsDetail, NewsDetail)) {
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@", self.shareBaseURL, self.newsDetail.link];
    
    [BDGSharing shareEmail:self.newsDetail.title mailBody:url recipients:nil isHTML:NO completion:nil];
}

#pragma mark - WebView Delegate

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [webView stringByEvaluatingJavaScriptFromString:
    @"(function(){"
    "   document.documentElement.style.webkitUserSelect='none';"
    "   document.documentElement.style.webkitTouchCallout='none';"
    "   window.location.href='x-app://'+document.body.offsetHeight;"
    "})();"];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [request URL];
    if([url.scheme isEqual:@"x-app"]) {
        self.newsContentHeightConstraint.constant = url.host.floatValue;
        [self hideLoading];
        return NO;
    }
    return YES;
}

@end
