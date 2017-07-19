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

@interface NewsDetailViewController () <UIWebViewDelegate>
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

@end

@implementation NewsDetailViewController {
    BOOL viewDidAppearAlready;
}

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
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(self.newsDetail && self.newsDetail.title) {
        self.screenNameForce = [NSString stringWithFormat:@"NewsDetail: %@",self.newsDetail.title];
    }
    viewDidAppearAlready = YES;
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
        if(viewDidAppearAlready && self.screenNameForce == nil) {
            self.screenNameForce = [NSString stringWithFormat:@"NewsDetail: %@",self.newsDetail.title];
        }
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
                "<div id='ad_container' style='text-align:center;'></div>"
                "<script>"
                "   function fetch_json(path, callback) {"
                "       var req = new XMLHttpRequest();"
                "       req.open('GET', path, true);"
                "       req.onreadystatechange = function() {"
                "           if ((req.readyState === 4 && req.status === 200) ||"
                "               (req.readyState === 3 && req.status === 200 && req.responseText[req.responseText.length] === '}') ) {"
                "               try {"
                "                   callback(JSON.parse(req.responseText));"
                "               } catch (e) { }"
                "           } else { }"
                "       };"
                "       req.send(null);"
                "   }"
                "   fetch_json('https://ww2.lapublicite.ch/webservices/WSBanner.php?type=RFJPAVE',function(json){"
                "       if(!json.banner) {return;}\n"
                "       // Weird workaround. Trim out JS and create own <iframe>\n"
                "       var uri_b = json.banner.indexOf('var uri = ')+11,\n"
                "           uri_e = json.banner.indexOf(' ',uri_b),\n"
                "           uri   = json.banner.substr(uri_b,uri_e-uri_b-1)+new String(Math.random()).substring(2, 11);\n"
                "       var script_b = json.banner.indexOf('<script'),\n"
                "           script_e = json.banner.indexOf('script>')+7;\n"
                "       json.banner = json.banner.substr(0,script_b) + json.banner.substr(script_e);\n"
                "       json.banner = json.banner.substr(0,script_b) + '<iframe width=300 height=250 src=\"'+ uri +'\"></iframe>' + json.banner.substr(script_b);\n"
                "       document.getElementById('ad_container').innerHTML = json.banner;\n"
                "       window.location.href='x-app://'+document.body.offsetHeight;\n"
                "   });"
                "</script>"
                "<script src='http://code.jquery.com/jquery-1.11.1.min.js'></script>"
                "<script type='text/javascript'>"
                "jQuery( document ).ready(function() {"
            
                "var playing = false;"
                "var audioElement = document.createElement('audio');"
                "audioElement.setAttribute('id','audioPlayer');"
            
                "jQuery('.sound-link').click(function(event){"
                "event.preventDefault();"
                "event.stopPropagation();"
                
                "var trackURL = jQuery(this).attr('href');"
                "var trackTitle = jQuery(this).attr('title');"
                "var trackCover = jQuery(this).attr('rel');"
                
                "audioElement.setAttribute('src', trackURL);"
                
                "audioElement.addEventListener('ended', function() {"
                    "this.play();"
                "}, false);"
                
                "if (playing == false) {"
                "    playing = true;"
                "    jQuery(this).find('.fa-volume-up').removeClass('fa-volume-up').addClass('fa-pause');"
                "    audioElement.play();"
                "} else {"
                "    playing = false;"
                "jQuery(this).find('.fa-pause').removeClass('fa-pause').addClass('fa-volume-up');"
                "    audioElement.pause();"
                "}"
                "});"
                "});"
                "</script>"
                "%@"
                "</body>"
                "</html>",header,html,footer];
        NSLog(@"HTMLTOPEDRO: %@", html);
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
    if (navigationType == UIWebViewNavigationTypeLinkClicked ) {
        [BaseViewController gaiTrackEventAd:@"NewsDetail"];
        UIApplication *application = [UIApplication sharedApplication];
        [application openURL:url options:@{} completionHandler:nil];
        return NO;
    }
    if([url.scheme isEqual:@"x-app"]) {
        self.newsContentHeightConstraint.constant = url.host.floatValue;
        [self hideLoading];
        return NO;
    }
    return YES;
}

@end
