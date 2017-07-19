//
//  MainViewController.m
//  rfj
//
//  Created by Nuno Silva on 20/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <MagicalRecord/MagicalRecord.h>
#import <GoogleMobileAds/DFPInterstitial.h>
#import "Constants.h"
#import "DataManager.h"
#import "CategoryViewController.h"
#import "InfoContinuViewController.h"
#import "GalerieViewController.h"
#import "GalerieDetailViewController.h"
#import "GalerieGroupViewController.h"
#import "Validation.h"
#import "MainViewController.h"
#import "MenuItem+CoreDataProperties.h"
#import "MenuItemTableViewCell.h"
#import "MenuManager.h"
#import "NewsCategorySeparatorView.h"
#import "NewsGroupViewController.h"
#import "NewsItem+CoreDataProperties.h"
#import "GalerieItem+CoreDataProperties.h"
#import "NewsItemTableViewCell.h"
#import "GalerieItemTableViewCell.h"
#import "NewsDetailViewController.h"
#import "NewsManager.h"
#import "RadioManager.h"
#import "ResourcesManager.h"
#import "WebViewController.h"
#import "Reachability.h"
#import "NewsItemSwipeTableViewCell.h"
#import "WebViewTableViewCell.h"
#import "GalerieItemSwipeTableViewCell.h"


@import GoogleMobileAds;

@interface MainViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, GADInterstitialDelegate,
NewsItemTableViewCellDelegate, MenuItemTableViewCellDelegate, GalerieItemSwipeTableViewCellDelegate, NewsItemSwipeTableViewCellDelegate,
NewsCategorySeparatorViewDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
@property (nonatomic, assign) double theFakeMenuHeightConstraintConstant;
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIWebView *bottomBanner;
@property (strong, nonatomic) NSMutableArray<MenuItem *> *menuItems;
@property (strong, nonatomic) NSArray<NewsItem *> *newsItems;
@property (strong, nonatomic) NSArray<GalerieItem *> *galeriePhotos;
@property (strong, nonatomic) NSMutableArray<NewsItem *> *galerieIntoNews;
@property (strong, nonatomic) NSArray<NewsItem *> *importantItems;
@property (strong, nonatomic) NSArray<NewsItem *> *type4;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSArray<NewsItem *> *> *sortedNewsItems;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSArray<GalerieItem *> *> *sortedGalerieItems;
@property (strong, nonatomic) NSMutableArray<NSDictionary<NSArray<NSNumber *>*, NSArray<NewsItem *> *> *>*sortedNewsItems2;
@property (strong, nonatomic) NSMutableArray<NSDictionary<NSArray<NSNumber *>*, NSArray<GalerieItem *> *> *>*sortedGalerieItems2;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSArray<NewsItem *> *> *sortedImportantNews;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSArray<NewsItem *> *> *joinedRegionSport;
@property (strong, nonatomic) NSMutableArray<NSNumber *> *expandedMenuItems;
@property (strong, nonatomic) NSArray<MenuItem *> *allMenuItems;

@property (assign, nonatomic) NSInteger currentPage;
@property (assign, nonatomic) BOOL isLoading;

@property (strong, nonatomic) DFPInterstitial *interstitial;
@property (strong, nonatomic) DFPBannerView  *bannerView;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.screenName = @"Home";
    // tableView
    [self.menuTableView registerNib:[UINib nibWithNibName:@"MenuItemTableViewCell" bundle:nil] forCellReuseIdentifier:@"MenuItemTableViewCell"];
    [self.contentTableView registerNib:[UINib nibWithNibName:@"WebViewTableViewCell" bundle:nil] forCellReuseIdentifier:@"WebViewTableViewCell"];
    [self.contentTableView registerNib:[UINib nibWithNibName:@"GalerieItemSwipeTableViewCell" bundle:nil] forCellReuseIdentifier:@"GalerieItemSwipeTableViewCell"];
    [self.contentTableView registerNib:[UINib nibWithNibName:@"NewsItemTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsItemTableViewCell"];
    [self.contentTableView registerNib:[UINib nibWithNibName:@"NewsItemSwipeTableViewCell" bundle:nil] forCellReuseIdentifier:@"NewsItemSwipeTableViewCell"];
    
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    
    self.allMenuItems = [MenuItem sortedMenuItems];
    
    
    [[ResourcesManager singleton] fetchResourcesWithSuccessBlock:nil andFailureBlock:nil];
    
    [self refreshMenuItems];
    
    
    if([[DataManager singleton] isRFJ]) {
        self.menuTableView.backgroundColor = kBackgroundColorRFJ;
    }
    
    if([[DataManager singleton] isRJB]) {
        self.menuTableView.backgroundColor = kBackgroundColorRJB;
    }
    
    if([[DataManager singleton] isRTN]) {
        self.menuTableView.backgroundColor = kBackgroundColorRTN;
    }
    
    if(![MenuManager singleton].performedInitialFetch) {
        [[MenuManager singleton] fetchMenuItemsFromServerWithSuccessBlock:^(NSArray<MenuItem *> *items) {
            self.allMenuItems = items;
            [self refreshMenuItems];
        } andFailureBlock:^(NSError *error, NSArray<MenuItem *> *oldItems) {
            self.allMenuItems = oldItems;
            [self refreshMenuItems];
        }];
    }
    
    self.expandedMenuItems = [[NSMutableArray<NSNumber *> alloc] init];
    
    self.currentPage = 0;
    
    self.menuHeightConstraint.constant = 0;
    self.isLoading = NO;
    
    [self loadNextPage];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor whiteColor];
    refreshControl.tintColor = [UIColor blackColor];
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.contentTableView;
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = refreshControl;
    self.contentTableView.contentInset = UIEdgeInsetsMake(0, 0, 40, 0); // pull up to
    
    // Splash && Banner
#ifdef SHOW_ADS
    NSString *interstitialURL = @"https://ww2.lapublicite.ch/webservices/WSBanner.php?type=RFJSPLASH&horizontalSize=1080&verticalSize=1920";
    [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"SplashViewController"] animated:YES completion:nil];
    [self getJsonResponse:interstitialURL success:^(NSDictionary *responseDict) {
        
        NSString *strStitial = responseDict[@"banner"];
        if (VALID_NOTEMPTY(strStitial, NSString)){
            //[self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"SplashViewController"] animated:YES completion:nil];
        }
        
    } failure:^(NSError *error) {
        // error handling here ...
    }];
    
    
    NSString *bannerURL = @"https://ww2.lapublicite.ch/webservices/WSBanner.php?type=RFJAPPBAN&horizontalSize=1080&verticalSize=1920";
    [self getJsonResponse:bannerURL success:^(NSDictionary *responseDict) {
        if(!responseDict[@"banner"]) {
            self.bannerView.hidden = YES;
            return;
        }
        NSString *html = [NSString stringWithFormat:
                          @"<!DOCTYPE html>"
                          "<html>"
                          "<head>"
                          "<link rel=\"stylesheet\" href=\"http://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.css\" type=\"text/css\" media=\"all\" />"
                          "<link rel=\"stylesheet\" href=\"https://www.rfj.ch/Htdocs/Styles/app.css\" type=\"text/css\" media=\"all\" />"
                          "<link rel=\"stylesheet\" href=\"https://www.rfj.ch/Htdocs/Styles/webview.css\" type=\"text/css\" media=\"all\" />"
                          "</head>"
                          "<body>"
                          "<div class=\"pub\"><img src='https://ww2.lapublicite.ch/pubserver/www/delivery/avw.php?zoneid=20049&amp;cb=101&amp;n=a77eccf9' border='0' alt='' /></div>"
                          "%@"
                          "</body>"
                          "</html>"
                          ,responseDict[@"banner"]];
        self.bottomBanner.delegate = self;
        [self.bottomBanner loadHTMLString:html baseURL:nil];
    } failure:^(NSError *error) {
        // error handling here ...
    }];
    
    
#endif
    //  [[AppOwiz sharedInstance] startWithAppToken:@"58f732549e6a8" withCrashReporting:YES withFeedback:YES];
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

- (BOOL)bottomBanner:(UIWebView *)bottomBanner shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked ) {
        UIApplication *application = [UIApplication sharedApplication];
        [application openURL:[request URL] options:@{} completionHandler:nil];
        return NO;
    }
    
    return YES;
}
- (void)refreshTable:(id)sender {
    //[self.contentTableView reloadData];
    [self loadNextPage];
    [self.contentTableView.refreshControl endRefreshing];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(self.needsToLoadInterstitial) {
        //[self loadInterstitial];
    }
}


-(NSArray<NewsItem *> *)combinedNewsItems
{
    NSMutableArray<NewsItem *> *items = [[NSMutableArray<NewsItem *> alloc] init];
    
    for(NSDictionary<NSArray<NSNumber *> *, NSArray<NewsItem *> *> *content in self.sortedNewsItems2) {
        [items addObjectsFromArray:[content objectForKey:[[content allKeys] objectAtIndex:0]]];
    }
    
    if(VALID_NOTEMPTY(self.importantItems, NSArray) && VALID_NOTEMPTY(self.type4, NSArray) && [self.importantItems count] == kTotalImportantItemsToDisplay + 1) {
        [items insertObject:[self.type4 objectAtIndex:0] atIndex:kTotalImportantItemsToDisplay];
    }
    
    /*
     for(NSNumber *navigationID in [self.sortedNewsItems allKeys]) {
     [items addObjectsFromArray:[self.sortedNewsItems objectForKey:navigationID]];
     }
     */
    
    return items;
}
- (IBAction)toggleSound:(UIButton *)sender {
    if ([sender isSelected]) {
        
        [sender setImage:[UIImage imageNamed:@"couper_son_.png"] forState:UIControlStateNormal];
        
        [sender setSelected:NO];
        
    } else {
        
        [sender setImage:[UIImage imageNamed:@"ecouter"] forState:UIControlStateSelected];
        
        [sender setSelected:YES];
        
    }
}

- (IBAction)openInfoReport:(id)sender {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"infoReportViewController"];
    
    if(VALID(controller, UIViewController)) {
        [self.navigationController pushViewController:controller animated:YES];
    }
}

-(void)sortNewsItems {
    self.sortedNewsItems = [[NSMutableDictionary<NSNumber *, NSArray<NewsItem *> *> alloc] init];
    
    for(NewsItem *item in self.newsItems) {
        NSArray *sortedItems = nil;
        
        if([self.sortedNewsItems objectForKey:@(item.navigationId)] == nil) {
            sortedItems = [NSArray arrayWithObject:item];
        }
        else {
            sortedItems = [[self.sortedNewsItems objectForKey:@(item.navigationId)] arrayByAddingObject:item];
        }
        
        [self.sortedNewsItems setObject:sortedItems forKey:@(item.navigationId)];
        
    }
}

-(void)sortGalerieItems {
    self.sortedGalerieItems = [[NSMutableDictionary<NSNumber *, NSArray<GalerieItem *> *> alloc] init];
    
    for(GalerieItem *item in self.galeriePhotos) {
        NSArray *sortedItems = nil;
        
        if([self.sortedGalerieItems objectForKey:@(item.navigationId)] == nil) {
            sortedItems = [NSArray arrayWithObject:item];
        }
        else {
            sortedItems = [[self.sortedGalerieItems objectForKey:@(item.navigationId)] arrayByAddingObject:item];
        }
        
        [self.sortedGalerieItems setObject:sortedItems forKey:@(item.navigationId)];
        
    }
}

-(void)sortNewsItems2 {
    self.sortedNewsItems2 = [[NSMutableArray<NSDictionary<NSArray<NSNumber *>*, NSArray<NewsItem *> *> *> alloc] init];
    NSArray<NSArray<NSNumber *> *> *searchNumbers =
    @[
      @[@(9611), @(9643), @(9644), @(9645), @(9646), @(9647), @(9648), @(9649), @(9650),
        @(9629), @(10215), @(10216)],
      @[@(9612)],
      @[@(9622)],
      @[@(9613)],
      @[@(9614)],
      @[@(9615)],
      ];
    
    for(NSInteger i = 0; i < [searchNumbers count]; i++)
        {
        NSArray<NSNumber *> *searchItem = [searchNumbers objectAtIndex:i];
        NSMutableArray<NewsItem *> *items = [[NSMutableArray<NewsItem *> alloc] init];
        
        for(NewsItem *item in self.newsItems) {
            BOOL valid = NO;
            
            for(NSNumber *navigationId in searchItem)
                {
                if([navigationId intValue] == item.navigationId)
                    {
                    valid = YES;
                    
                    break;
                    }
                }
            
            if(!valid)
                {
                continue;
                }
            
            //            if (item.important == 1) {
            
            //            } else {
            [items addObject:item];
            //            }
        }
        
        [self.sortedNewsItems2 addObject:
         @{
           searchItem: items
           }];
        }
}

-(void)sortImportantNews {
    self.sortedImportantNews = [[NSMutableDictionary<NSNumber *, NSArray<NewsItem *> *> alloc] init];
    
    for(NewsItem *item in self.newsItems) {
        NSArray *sortedItems = nil;
        
        if([self.sortedImportantNews objectForKey:@(item.important)] == nil) {
            sortedItems = [NSArray arrayWithObject:item];
        }
        else {
            sortedItems = [[self.sortedImportantNews objectForKey:@(item.important)] arrayByAddingObject:item];
        }
        [self.sortedImportantNews setObject:sortedItems forKey:@(item.important)];
        
    }
}


-(void)refreshMenuItems
{
    NSMutableArray<MenuItem *> *menuItems = [[NSMutableArray<MenuItem *> alloc] init];
    
    for(MenuItem *item in self.allMenuItems)
        {
        if(item.parentId == 0)
            {
            [menuItems addObject:item];
            
            if([self.expandedMenuItems containsObject:@(item.id)])
                {
                for(MenuItem *childItem in self.allMenuItems)
                    {
                    if(childItem.parentId == item.id)
                        {
                        [menuItems addObject:item];
                        }
                    }
                }
            }
        }
    
    self.menuItems = menuItems;
    
    [self.menuTableView reloadData];
}

-(void)showLoading {
    [self.loadingView setHidden:NO];
}

-(void)hideLoading {
    [self.loadingView setHidden:YES];
}

-(void)showMenu {
    self.menuHeightConstraint.constant = self.menuTableView.contentSize.height;
    [self adjustMenuHeightConstant];
    
    [UIView animateWithDuration:kMenuAnimationTime animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void)hideMenu {
    self.menuHeightConstraint.constant = 0;
    
    [UIView animateWithDuration:kMenuAnimationTime animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(IBAction)playRadio:(id)sender {
    if([[RadioManager singleton] isPlaying]) {
        
        [sender setImage:[UIImage imageNamed:@"ecouter"] forState:UIControlStateSelected];
        [sender setSelected:YES];
        [[RadioManager singleton] stop];
        
    }
    else {
        
        [sender setImage:[UIImage imageNamed:@"couper_son_.png"] forState:UIControlStateNormal];
        [sender setSelected:NO];
        [[RadioManager singleton] play];
        
    }
}

-(void)loadInterstitial {
    self.needsToLoadInterstitial = NO;
    
    
    NSDictionary *BackendURLs = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BackendURLs" ofType:@"plist"]];
    self.interstitial = [[DFPInterstitial alloc] initWithAdUnitID:[BackendURLs objectForKey:@"DFPInterstitialLoadingLink"]];
    self.interstitial.delegate = self;
    
    DFPRequest *request = [DFPRequest request];
    request.testDevices = @[kGADSimulatorID, @"40238db35009b7d4b7bf9ac26d418d9e"];
    
    //[self.interstitial loadRequest:request];
}

-(void)loadPageItemsForPage:(NSInteger)page count:(NSInteger)count
                    success:(void(^)(NSArray<NewsItem *> *items))successBlock
                    failure:(void(^)(NSError *error))failureBlock {
    self.isLoading = YES;
    
    [[NewsManager singleton] fetchNewsAtPage:page objectType:0 categoryId:-1 withSuccessBlock:^(NSArray<NewsItem *> *items) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isLoading = NO;
            
            if(successBlock) {
                successBlock(items);
            }
        });
    } andFailureBlock:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isLoading = NO;
            
            if(failureBlock) {
                failureBlock(error);
            }
        });
    }];
}

-(void)loadImagesForPage:(NSInteger)page count:(NSInteger)count
                 success:(void(^)(NSArray<GalerieItem *> *photos))successBlock
                 failure:(void(^)(NSError *error))failureBlock {
    self.isLoading = YES;
    
    [[NewsManager singleton] fetchImagesAtPage:page objectType:1 categoryId:-1 withSuccessBlock:^(NSArray<GalerieItem *> *photos) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isLoading = NO;
            
            if(successBlock) {
                successBlock(photos);
            }
        });
    } andFailureBlock:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isLoading = NO;
            
            if(failureBlock) {
                failureBlock(error);
            }
        });
    }];
}

-(void)loadNextPage {
    if(self.isLoading) {
        return;
    }
    
    [self showLoading];
    
    self.currentPage++;
    
    [self loadPageItemsForPage:self.currentPage count:kItemsPerPage success:^(NSArray<NewsItem *> *items) {
        [self hideLoading];
        
        for(NewsItem *item in items) {
            NSInteger itemIndex = [self.newsItems indexOfObjectPassingTest:^BOOL(NewsItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return item.id == obj.id;
            }];
            
            if(itemIndex == NSNotFound) {
                self.newsItems = [self.newsItems arrayByAddingObject:item];
            }
        }
        
        self.newsItems = [NewsItem MR_findAllSortedBy:@"createDate"
                                            ascending:NO];
        self.galeriePhotos = [GalerieItem MR_findAllSortedBy:@"createDate"
                                                   ascending:NO];
        NSPredicate *objPredicate = [NSPredicate predicateWithFormat:@"important = 1"];
        NSPredicate *objPredicateTwo = [NSPredicate predicateWithFormat:@"type = 4"];
        
        self.importantItems = [self.newsItems filteredArrayUsingPredicate:objPredicate];
        self.type4 = [self.newsItems filteredArrayUsingPredicate:objPredicateTwo];
        
        if(VALID_NOTEMPTY(self.importantItems, NSArray))
            {
            if([self.importantItems count] > kTotalImportantItemsToDisplay) {
                NSMutableArray *actualImportantItems = [[NSMutableArray alloc] init];
                
                for(NSInteger i = 0; i < kTotalImportantItemsToDisplay; i++) {
                    [actualImportantItems addObject:[self.importantItems objectAtIndex:i]];
                }
                
                self.importantItems = actualImportantItems;
            }
            
            if(VALID_NOTEMPTY(self.type4, NSArray)) { //Remove false when reactivating type 4's and check valid date
                NSUInteger randomIndex = arc4random() % [self.type4 count];
                self.importantItems = [self.importantItems arrayByAddingObject:[self.type4 objectAtIndex:randomIndex]];
            }
            }
        
        [self sortNewsItems];
        [self sortGalerieItems];
        [self sortNewsItems2];
        [self sortImportantNews];
        
        [self.contentTableView reloadData];
    } failure:^(NSError *error) {
        [self hideLoading];
        
        self.newsItems = [NewsItem MR_findAllSortedBy:@"createDate"
                                            ascending:NO];
        
        NSPredicate *objPredicate = [NSPredicate predicateWithFormat:@"important = 1"];
        self.importantItems = [self.newsItems filteredArrayUsingPredicate:objPredicate];
        
        NSPredicate *objPredicateTwo = [NSPredicate predicateWithFormat:@"type = 4"];
        self.type4 = [self.newsItems filteredArrayUsingPredicate:objPredicateTwo];
        
        if(VALID_NOTEMPTY(self.importantItems, NSArray) && [self.importantItems count] > kTotalImportantItemsToDisplay) {
            
            NSMutableArray *actualImportantItems = [[NSMutableArray alloc] init];
            
            for(NSInteger i = 0; i < kTotalImportantItemsToDisplay; i++) {
                [actualImportantItems addObject:[self.importantItems objectAtIndex:i]];
            }
            
            self.importantItems = actualImportantItems;
            
            if(VALID_NOTEMPTY(self.type4, NSArray)) {
                self.importantItems = [self.importantItems arrayByAddingObject:[self.type4 objectAtIndex:0]];
            }
        }
        
        [self sortNewsItems];
        [self sortGalerieItems];
        [self sortNewsItems2];
        [self sortImportantNews];
        //NSLog(@"Error: %@", error);
    }];
    [self loadImagesForPage:self.currentPage count:kItemsPerPage success:^(NSArray<GalerieItem *> *photos) {
        [self hideLoading];
        
        for(GalerieItem *photo in photos) {
            NSInteger itemIndex = [self.galeriePhotos indexOfObjectPassingTest:^BOOL(GalerieItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return photo.id == obj.id;
            }];
            
            if(itemIndex == NSNotFound) {
                self.galeriePhotos = [self.galeriePhotos arrayByAddingObject:photo];
            }
        }
        
        self.galeriePhotos = [GalerieItem MR_findAllSortedBy:@"createDate"
                                                   ascending:NO];
        [self sortGalerieItems];
        //NSLog(@"GALERIE: %@", self.galeriePhotos);
        //        NSPredicate *objPredicate = [NSPredicate predicateWithFormat:@"important = 1"];
        //
        //        self.importantItems = [self.newsItems filteredArrayUsingPredicate:objPredicate];
        //
        //        [self sortNewsItems];
        //        [self sortNewsItems2];
        //        [self sortImportantNews];
        
        [self.contentTableView reloadData];
    } failure:^(NSError *error) {
        [self hideLoading];
        
        self.galeriePhotos = [GalerieItem MR_findAllSortedBy:@"createDate"
                                                   ascending:NO];
        [self sortGalerieItems];
        //        NSPredicate *objPredicate = [NSPredicate predicateWithFormat:@"important = 1"];
        //
        //        self.importantItems = [self.newsItems filteredArrayUsingPredicate:objPredicate];
        //
        //        [self sortNewsItems];
        //        [self sortNewsItems2];
        //        [self sortImportantNews];
        //NSLog(@"Error: %@", error);
    }];
}

- (IBAction)toggleMenu:(id)sender {
    if(self.menuHeightConstraint.constant > 0) {
        [self hideMenu];
    }
    else {
        [self showMenu];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked ) {
        [BaseViewController gaiTrackEventAd:@"Main"];
        UIApplication *application = [UIApplication sharedApplication];
        [application openURL:[request URL] options:@{} completionHandler:nil];
        return NO;
    }
    
    return YES;
}

#pragma mark - UITableView Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.menuTableView) {
        return [self.menuItems count];
    }
    else if(tableView == self.contentTableView) {
        //return [[self.sortedNewsItems objectForKey:navigationID] count];
        if (section == 0) {
            return [self.importantItems count];
        } else {
            return section == 1 ? 8 : 1;
        }
    }
    
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(tableView == self.menuTableView) {
        return 1;
    }
    //NSLog(@"SECTIONS COUNT %lu", (unsigned long)self.sortedNewsItems.count);
    return [self.sortedNewsItems2 count]+1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    //NSNumber *navigationID = [[self.sortedNewsItems allKeys] objectAtIndex:section];
    
    if(section == 0) {
        return nil;
    }
    
    NewsCategorySeparatorView *headerView = nil;
    
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"NewsCategorySeparatorView" owner:self options:nil];
    
    if(VALID_NOTEMPTY(views, NSArray))
        {
        headerView = [views objectAtIndex:0];
        }
    
    if(VALID(headerView, NewsCategorySeparatorView)) {
        /*
         NSInteger categoryIndex = [self.allMenuItems indexOfObjectPassingTest:^BOOL(MenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         return obj.id == [navigationID intValue];
         }];
         
         if(categoryIndex != NSNotFound) {
         [headerView setName:[self.allMenuItems objectAtIndex:categoryIndex].name];
         }
         */
        
        headerView.delegate = self;
        headerView.tableSection = @(section);
        
        NSDictionary<NSArray<NSNumber *> *, NSArray<NewsItem *> *> *content = [self.sortedNewsItems2 objectAtIndex:section - 1];
        NSArray<NSNumber *> *navigationIds = [[content allKeys] objectAtIndex:0];
        
        if(VALID_NOTEMPTY(navigationIds, NSArray<NSNumber *>)) {
            NSString *nameString = @"";
            
            NSInteger categoryIndex = [self.allMenuItems indexOfObjectPassingTest:^BOOL(MenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return obj.id == [[navigationIds objectAtIndex:0] intValue];
            }];
            
            if(categoryIndex != NSNotFound) {
                nameString = [self.allMenuItems objectAtIndex:categoryIndex].name;
            }
            
            for(NSInteger i = 1; i < [navigationIds count]; i++) {
                categoryIndex = [self.allMenuItems indexOfObjectPassingTest:^BOOL(MenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    return obj.id == [[navigationIds objectAtIndex:i] intValue];
                }];
                
                if(categoryIndex != NSNotFound) {
                    nameString = [NSString stringWithFormat:@"%@ & %@", nameString, [self.allMenuItems objectAtIndex:categoryIndex].name];
                }
            }
            if (categoryIndex == 7) {
            }
            if (categoryIndex == 9223372036854775807) {
                [headerView setName:@"Galeries photos"];
            } else {
                [headerView setName:nameString];
            }
        }
    }
    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(tableView == self.contentTableView) {
        if (section > 0) {
            return kContentCategorySeparatorHeight;
        }
    }
    
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.menuTableView) {
        static NSString * cellId = @"MenuItemTableViewCell";
        MenuItemTableViewCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
        MenuItem *item = [self.menuItems objectAtIndex:indexPath.row];
        cell.delegate = self;
        cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0099ff"];
        cell.contentView.layer.borderWidth = 1;
        cell.contentView.layer.borderColor = [[UIColor colorWithHexString:@"#2182c3"] CGColor];
        // TODO AN Refactor. Create .json or .plist instead. DO NOT use isEqual. Use id comparision
        if(
           [item.name  isEqual: @"Région"]              ||
           [item.name  isEqual: @"Suisse"]              ||
           [item.name  isEqual: @"Monde"]               ||
           [item.name  isEqual: @"Économie"]            ||
           [item.name  isEqual: @"Culture"]             ||
           [item.name  isEqual: @"Football"]            ||
           [item.name  isEqual: @"Hockey"]              ||
           [item.name  isEqual: @"Basketball"]          ||
           [item.name  isEqual: @"Volleyball"]          ||
           [item.name  isEqual: @"Cyclisme"]            ||
           [item.name  isEqual: @"Ski"]                 ||
           [item.name  isEqual: @"Hippisme"]            ||
           [item.name  isEqual: @"Tennis"]              ||
           [item.name  isEqual: @"Autres sports"]       ||
           [item.name  isEqual: @"Sports motorisés"]    ||
           [item.name  isEqual: @"Inline hockey"] ) {
            cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073c0"];
            cell.contentView.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
        }
        cell.theNameString = item.name;
        BOOL shouldExpand = [self.allMenuItems indexOfObjectPassingTest:^BOOL(MenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return obj.parentId == item.id;
        }] != NSNotFound;
        
        if(shouldExpand && item.id != 0) {
            cell.theImage = [UIImage imageNamed:@"hamburger_menu"];
            cell.theBoolIconInteractionEnabled = YES;
        } else if(VALID_NOTEMPTY(item.link, NSString)) {
            cell.theImage = [UIImage imageNamed:@"link"];
            cell.theBoolIconInteractionEnabled = NO;
        } else {
            cell.theImage = nil;
            cell.theBoolIconInteractionEnabled = NO;
        }
        return cell;
    } else if(tableView == self.contentTableView) {
        if (indexPath.row == 7) { // Square Type ADS
            static NSString * cellId = @"WebViewTableViewCell";
            WebViewTableViewCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
            NSString *squareURL = @"https://ww2.lapublicite.ch/webservices/WSBanner.php?type=RFJPAVE";
            [self getJsonResponse:squareURL success:^(NSDictionary *responseDict) {
                NSString *str = responseDict[@"banner"];
                NSString *fixSquare = @"<div class=\"pub\" id=\"beacon_6b7b3f991\">";
                if (VALID_NOTEMPTY(str, NSString)){
                    str = [fixSquare stringByAppendingString:str];
                    str = [str stringByAppendingString:@"</div>"];
                    [cell.webView loadHTMLString:str baseURL:nil];
                }
                cell.webView.delegate = self;
            } failure:^(NSError *error) {
                // error handling here ...
            }];
            return cell;
        } else if (indexPath.section == 3) { // GALERIE TYPE CELL
            static NSString * cellId = @"GalerieItemSwipeTableViewCell";
            GalerieItemSwipeTableViewCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
            cell.delegate = self;
            cell.galerieItems = self.galeriePhotos;
            return cell;
        } else { //CATEGORIES CELLS
            if(indexPath.section == 0 || indexPath.section == 1) {
                static NSString * cellId = @"NewsItemTableViewCell";
                NewsItemTableViewCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
                cell.delegate = self;
                NewsItem * item = nil;
                if(indexPath.section == 1) {
                    // TODO AN Move copy and removeObjectsInArray: to data init
                    NSDictionary<NSArray<NSNumber *> *, NSArray<NewsItem *> *> *content = [self.sortedNewsItems2 objectAtIndex:indexPath.section - 1];
                    NSArray<NewsItem *> *items = [content objectForKey:[[content allKeys] objectAtIndex:0]];
                    if(true) { // Format
                        NSMutableArray *theItemsMArray = items.mutableCopy;
                        [theItemsMArray removeObjectsInArray:self.importantItems];
                        items = theItemsMArray;
                    }
                    item = items[indexPath.row];
                } else {
                    item = [self.importantItems objectAtIndex:indexPath.row];
                }
                [cell setItem:item];
                return cell;
            } else {
                static NSString * cellId = @"NewsItemSwipeTableViewCell";
                NewsItemSwipeTableViewCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
                cell.delegate = self;
                // TODO AN Move sort to data init. allKeys is pricey call
                NSDictionary<NSArray<NSNumber *> *, NSArray<NewsItem *> *> *content = [self.sortedNewsItems2 objectAtIndex:indexPath.section - 1];
                NSArray<NewsItem *> *items = [content objectForKey:[[content allKeys] objectAtIndex:0]];
                [cell setNewsItems:items];
                return cell;
            }
        }
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.menuTableView) {
        return 44.0f;
    }
    else if(tableView == self.contentTableView) {
        if (indexPath.row == 7) {
            return 300;
        }  else {
            return ceilf([UIScreen mainScreen].bounds.size.width * 0.6372340425531915);
        }
    }
    
    return 44.0f;
}

#pragma mark - UIScrollView Delegate

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(scrollView == self.contentTableView) {
        if(scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height && !self.isLoading) {
            //We probably don't want this
            //[self loadNextPage];
        }
    }
}

#pragma mark - Interstitial Delegate

- (void)interstitialDidReceiveAd:(DFPInterstitial *)ad {
    [self.interstitial presentFromRootViewController:self];
}

#pragma mark - MenuItemTableViewCell Delegate

-(void)menuItemDidTapIcon:(MenuItemTableViewCell *)item {
    NSIndexPath *index = [self.menuTableView indexPathForCell:item];
    
    if(index.row >= 0 && index.row < [self.menuItems count]) {
        MenuItem *menuItem = [self.menuItems objectAtIndex:index.row];
        
        if(VALID(menuItem, MenuItem)) {
            if([self.expandedMenuItems containsObject:@(menuItem.id)]) {
                [self.expandedMenuItems removeObject:@(menuItem.id)];
                
                NSMutableArray<NSIndexPath *> *removedRows = [[NSMutableArray<NSIndexPath *> alloc] init];
                
                for(NSInteger i = [self.menuItems count] - 1; i >= 0; i--) {
                    MenuItem *subItem = [self.menuItems objectAtIndex:i];
                    if(VALID(subItem, MenuItem) && subItem.parentId == menuItem.id) {
                        [removedRows addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                        [self.menuItems removeObject:subItem];
                    }
                }
                
                self.menuHeightConstraint.constant = self.menuHeightConstraint.constant - [removedRows count] * kMenuRowHeight;
                
                [UIView animateWithDuration:kMenuAnimationTime animations:^{
                    [self.menuTableView beginUpdates];
                    [self.menuTableView deleteRowsAtIndexPaths:removedRows withRowAnimation:UITableViewRowAnimationTop];
                    [self.menuTableView endUpdates];
                    [self.view layoutIfNeeded];
                }];
            }
            else
                {
                BOOL shouldExpand = [self.allMenuItems indexOfObjectPassingTest:^BOOL(MenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    return obj.parentId == menuItem.id;
                }] != NSNotFound;
                
                if(shouldExpand && menuItem.id != 0) {
                    [self.expandedMenuItems addObject:@(menuItem.id)];
                    
                    NSInteger startIndex = index.row + 1;
                    NSInteger currentIndex = 0;
                    NSMutableArray<NSIndexPath *> *insertedRows = [[NSMutableArray<NSIndexPath *> alloc] init];
                    
                    for(MenuItem *subItem in self.allMenuItems) {
                        if(subItem.parentId == menuItem.id) {
                            [self.menuItems insertObject:subItem atIndex:startIndex + currentIndex];
                            [insertedRows addObject:[NSIndexPath indexPathForRow:startIndex + currentIndex inSection:0]];
                            
                            currentIndex++;
                        }
                    }
                    
                    [self.menuTableView insertRowsAtIndexPaths:insertedRows withRowAnimation:UITableViewRowAnimationTop];
                    
                    self.menuHeightConstraint.constant = self.menuHeightConstraint.constant + [insertedRows count] * kMenuRowHeight;
                    
                    [UIView animateWithDuration:kMenuAnimationTime animations:^{
                        [self.menuTableView beginUpdates];
                        [self.menuTableView endUpdates];
                        [self.view layoutIfNeeded];
                    }];
                }
                }
        }
    }
}

-(void)menuItemDidTap:(MenuItemTableViewCell *)item {
    self.menuHeightConstraint.constant = 0;
    
    NSIndexPath *index = [self.menuTableView indexPathForCell:item];
    
    if(index.row >= 0 && index.row < [self.menuItems count]) {
        MenuItem *menuItem = [self.menuItems objectAtIndex:index.row];
        if(VALID(menuItem, MenuItem)) {
            [self.expandedMenuItems removeAllObjects];
            [self refreshMenuItems];
            
            if(VALID_NOTEMPTY(menuItem.link, NSString)) {
                [BaseViewController gaiTrackEventMenu:menuItem.name];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:menuItem.link]];
            }
            else {
                
                if ([@(menuItem.id) isEqualToNumber:[NSNumber numberWithInt:0]]) {
                    InfoContinuViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"infoContinuViewController"];
                    
                    if(VALID(controller, InfoContinuViewController)) {
                        //controller.navigationId = @(menuItem.id);
                        [self.navigationController pushViewController:controller animated:YES];
                    }
                } else if ([@(menuItem.id) isEqualToNumber:[NSNumber numberWithInt:9622]]) {
                    
                    GalerieViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"GalerieViewController"];
                    
                    if(VALID(controller, GalerieViewController)) {
                        //controller.navigationId = @(menuItem.id);
                        [self.navigationController pushViewController:controller animated:YES];
                    }
                }
                
                else {
                    CategoryViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"categoryViewController"];
                    
                    if(VALID(controller, CategoryViewController)) {
                        controller.navigationId = @(menuItem.id);
                        [self.navigationController pushViewController:controller animated:YES];
                    }
                }
            }
        }
    }
    
}

#pragma mark - NewsItemTableViewCell Delegate

-(void)NewsItemDidTap:(NewsItemTableViewCell *)item {
    
    NSIndexPath *index = [self.contentTableView indexPathForCell:item];
    
    if(index.row >= 0 && index.row < [self.newsItems count]) {
        NewsGroupViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"newsGroup"];
        //NSLog(@"ITEM COUNT: %ld", (long)index.row);
        //NSLog(@"SECTION COUNT: %ld", (long)index.section);
        
        
        if(VALID(controller, NewsGroupViewController)) {
            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
                NewsItem *localItem = [item.item MR_inContext:localContext];
                
                if(VALID(localItem, NewsItem)) {
                    localItem.read = YES;
                }
            }];
            
            [self.contentTableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
            
            controller.newsToDisplay = [self combinedNewsItems];
            
            controller.startingIndex = @([controller.newsToDisplay indexOfObjectPassingTest:^BOOL(NewsItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return obj == item.item;
            }]);
            
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

-(void)NewsItemSwipeDidTap:(NewsItemSwipeTableViewCell *)item withNewsItem:(NewsItem *)newsItem {
    
    NSIndexPath *index = [self.contentTableView indexPathForCell:item];
    
    if(index.row >= 0 && index.row < [self.newsItems count]) {
        NewsGroupViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"newsGroup"];
        //NSLog(@"ITEM COUNT: %ld", (long)index.row);
        //NSLog(@"SECTION COUNT: %ld", (long)index.section);
        
        
        if(VALID(controller, NewsGroupViewController)) {
            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
                NewsItem *localItem = [newsItem MR_inContext:localContext];
                
                if(VALID(localItem, NewsItem)) {
                    localItem.read = YES;
                }
            }];
            
            [self.contentTableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
            
            if (index.section == 0 && index.row == kTotalImportantItemsToDisplay) {
                controller.newsToDisplay = @[[self.type4 objectAtIndex:0]];
                controller.startingIndex = @0;
            } else {
                controller.newsToDisplay = [self combinedNewsItems];
                controller.startingIndex = @([controller.newsToDisplay indexOfObjectPassingTest:^BOOL(NewsItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    return obj == newsItem;
                }]);
            }
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

//-(void)GalerieItemDidTap:(GalerieItemTableViewCell *)item {
//    NSIndexPath *index = [self.contentTableView indexPathForCell:item];
//
//    if(index.row >= 0 && index.row < [self.newsItems count]) {
//        GalerieViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"GalerieViewController"];
//
//        if(VALID(controller, GalerieViewController)) {
//            //controller.navigationId = @(menuItem.id);
//            [self.navigationController pushViewController:controller animated:YES];
//        }
//    }
//
//}

-(void)GalerieItemSwipeDidTap:(GalerieItemSwipeTableViewCell *)item withGalerieItem:(GalerieItem *)galerieItem {
    GalerieGroupViewController *controller = (id)[self.storyboard instantiateViewControllerWithIdentifier:@"galerieGroup"];
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        GalerieItem *localItem = galerieItem;
        if(VALID(localItem, GalerieItem)) {
            localItem.read = YES;
        }
    }];
    controller.galerieToDisplay = self.galeriePhotos;
    controller.startingIndex = @([controller.galerieToDisplay indexOfObjectPassingTest:^BOOL(GalerieItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return obj == galerieItem;
    }]);
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)GalerieItemDidTap:(GalerieItemTableViewCell *)item {
    
    //    NSIndexPath *index = [self.contentTableView indexPathForCell:item];
    //    NSLog(@"GALERIE PHOTO TAPPED %ld", (long)index.row);
    //    GalerieItem *photoItem = [self.galerieItems objectAtIndex:index.row];
    //    NSLog(@"GALERIE PHOTO TAPPED %@", photoItem.retina1);
    //    UIImage *image =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoItem.retina1]]];
    //    [self addImageViewWithImage:image];
    NSIndexPath *index = [self.contentTableView indexPathForCell:item];
    if(index.row >= 0 && index.row < [self.galeriePhotos count]) {
        GalerieGroupViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"galerieGroup"];
        
        if(VALID(controller, GalerieGroupViewController)) {
            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
                GalerieItem *localItem = [item.item MR_inContext:localContext];
                
                if(VALID(localItem, GalerieItem)) {
                    localItem.read = YES;
                }
            }];
            
            [self.contentTableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
            
            controller.galerieToDisplay = self.galeriePhotos;
            controller.startingIndex = @([controller.galerieToDisplay indexOfObjectPassingTest:^BOOL(GalerieItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return obj == item.item;
            }]);
            
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
    
}

-(void)NewsCategorySeparatorViewDidClickLeft:(NewsCategorySeparatorView *)view {
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:view.tableSection.integerValue];
    if([self tableView:self.contentTableView numberOfRowsInSection:view.tableSection.integerValue] > indexPath.row) {
        UITableViewCell * cell = [self.contentTableView cellForRowAtIndexPath:indexPath];
        if(cell != nil && [cell respondsToSelector:@selector(moveLeft)]) {
            [cell performSelector:@selector(moveLeft)];
        }
    }
}

-(void)NewsCategorySeparatorViewDidClickRight:(NewsCategorySeparatorView *)view {
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:view.tableSection.integerValue];
    if([self tableView:self.contentTableView numberOfRowsInSection:view.tableSection.integerValue] > indexPath.row) {
        UITableViewCell * cell = [self.contentTableView cellForRowAtIndexPath:indexPath];
        if(cell != nil && [cell respondsToSelector:@selector(moveRight)]) {
            [cell performSelector:@selector(moveRight)];
        }
    }
}

- (void)adjustMenuHeightConstant
{
    self.theFakeMenuHeightConstraintConstant = self.menuHeightConstraint.constant;
    double theProperHeightCount = 0;
    {
    theProperHeightCount += self.menuTableView.superview.frame.size.height;
    theProperHeightCount -= self.bottomBanner.frame.size.height;
    theProperHeightCount -= self.menuTableView.frame.origin.y;
    }
    if (self.menuHeightConstraint.constant > theProperHeightCount)
        {
        self.menuHeightConstraint.constant = theProperHeightCount;
        }
}

@end






























