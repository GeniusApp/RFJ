//
//  InfoContinuViewController.m
//  rfj
//
//  Created by Gonçalo Girão on 18/05/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import "GalerieDetailViewController.h"
#import <MagicalRecord/MagicalRecord.h>
#import <GoogleMobileAds/DFPInterstitial.h>
#import "Constants.h"
#import "DataManager.h"
#import "CategoryViewController.h"
#import "Validation.h"
#import "MenuItem+CoreDataProperties.h"
#import "MenuItemTableViewCell.h"
#import "MenuManager.h"
#import "NewsCategorySeparatorView.h"
#import "NewsGroupViewController.h"
#import "NewsItem+CoreDataProperties.h"
#import "GalerieDetail+CoreDataProperties.h"
#import "NewsItemTableViewCell.h"
#import "NewsDetailViewController.h"
#import "NewsManager.h"
#import "NewsSeparatorViewWithBackButton.h"
#import "RadioManager.h"
#import "ResourcesManager.h"
#import "WebViewController.h"
#import "GalerieItem+CoreDataProperties.h"
#import "GalerieDetailViewController.h"
#import "GalerieDetail+CoreDataProperties.h"
#import "GalerieDetailTableViewCell.h"
#import "GalerieDetailTopTableViewCell.h"


@interface GalerieDetailViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, GADInterstitialDelegate,
NewsItemTableViewCellDelegate, MenuItemTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet NewsSeparatorViewWithBackButton *separatorView;
@property (strong, nonatomic) NSMutableArray<MenuItem *> *menuItems;
@property (strong, nonatomic) NSArray<GalerieDetail *> *galerieDetail;
//@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSArray<NewsItem *> *> *sortedNewsItems;
@property (strong, nonatomic) NSMutableArray<NSNumber *> *expandedMenuItems;
@property (strong, nonatomic) NSArray<MenuItem *> *allMenuItems;
@property (strong, nonatomic) GalerieDetail *galeriesDetail;

@property (assign, nonatomic) NSInteger currentPage;
@property (assign, nonatomic) BOOL isLoading;
@property (strong, nonatomic) NSNumber *activeCategoryId;

@end

@implementation GalerieDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor whiteColor];
    refreshControl.tintColor = [UIColor blackColor];
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.contentTableView;
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = refreshControl;
    
    self.allMenuItems = [MenuItem sortedMenuItems];
    self.galerieDetail = [GalerieDetail MR_findAll];
    
    
    [[ResourcesManager singleton] fetchResourcesWithSuccessBlock:nil andFailureBlock:nil];
    
    [self refreshMenuItems];
    [self loadGalerie:self.newsID];
    
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
    self.activeCategoryId = [NSNumber numberWithInt:9622];
    //self.activeCategoryId = self.navigationId;
    [self refreshCategory:[self.activeCategoryId intValue]];
    self.currentPage = 0;
    
    self.menuHeightConstraint.constant = 0;
    //self.isLoading = NO;
    [self loadGalerie:self.newsID];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)homeButtonTapped:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

// Metdodo Som

// Metodo infoReporter

- (void)refreshTable:(id)sender {
    //TODO: refresh your data
    
    //[self.contentTableView reloadData];
    //[self loadNextPage];
    [self.contentTableView.refreshControl endRefreshing];
    
    
}

-(void)refreshCategory:(NSInteger)categoryId
{
    NSInteger menuIndex = [self.allMenuItems indexOfObjectPassingTest:^BOOL(MenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return obj.id == categoryId;
    }];
    
    if(menuIndex == NSNotFound) {
        return;
    }
    
    self.activeCategoryId = @(categoryId);
    self.currentPage = 1;
    
    [self.separatorView setCategoryName:[self.allMenuItems objectAtIndex:menuIndex].name];
    
    [self showLoading];
    
//    [[NewsManager singleton] fetchNewsAtPage:self.currentPage objectType:0 categoryId:categoryId withSuccessBlock:^(NSArray<NewsItem *> *items) {
    [[NewsManager singleton] fetchGalerieDetailForNews:self.newsID successBlock:^(GalerieDetail *galerieDetail) {
        self.galeriesDetail = galerieDetail;
        [self.contentTableView reloadData];
        
        [self hideLoading];
    } andFailureBlock:^(NSError *error, GalerieDetail *oldGalerieDetail) {
        self.galeriesDetail = oldGalerieDetail;
        [self.contentTableView reloadData];
        
        [self hideLoading];
    }];
}

-(void)loadGalerie:(NSNumber *)newsID {
    
    if(VALID(newsID, NSNumber)) {
        
        
        [[NewsManager singleton] fetchGalerieDetailForNews:[newsID integerValue] successBlock:^(GalerieDetail *galeriesDetail) {
            self.galeriesDetail = galeriesDetail;
            //NSLog(@"QUEREMOS FOTOS! %lu", [self.galerieDetails count]);
            
           // [self refreshNews];
            [self.contentTableView reloadData];
            [self hideLoading];
        } andFailureBlock:^(NSError *error, GalerieDetail *oldGalerieDetail) {
            self.galeriesDetail = oldGalerieDetail;
            [self.contentTableView reloadData];
            [self hideLoading];
        //    [self refreshNews];
        }];
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




- (IBAction)toggleMenu:(id)sender {
    if(self.menuHeightConstraint.constant > 0) {
        [self hideMenu];
    }
    else {
        [self showMenu];
    }
}

#pragma mark - UITableView Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.menuTableView) {
        return [self.menuItems count];
    }
    else if(tableView == self.contentTableView) {
        
        if (section == 1) {
            return [self.galeriesDetail.contentGallery count];
        } else {
            return 1;
        }
    }
    
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(tableView == self.menuTableView) {
        return 1;
    } else {
        return 2;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if(tableView == self.menuTableView) {
        
        MenuItemTableViewCell *actualCell = (MenuItemTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"menuItemCell"];
        
        if(!VALID(actualCell, MenuItemTableViewCell)) {
            NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"MenuItemTableViewCell" owner:self options:nil];
            
            if(VALID_NOTEMPTY(views, NSArray)) {
                actualCell = [views objectAtIndex:0];
            }
        }
        
        if(VALID(actualCell, MenuItemTableViewCell)) {
            cell = actualCell;
            
            if(indexPath.row >= 0 && indexPath.row < [self.menuItems count]) {
                MenuItem *item = [self.menuItems objectAtIndex:indexPath.row];
                actualCell.delegate = self;
                
                if ([item.name  isEqual: @"Région"]) {
                    //item.name = @"   Région";
                    [actualCell setName:item.name];
                    //actualCell.layer.backgroundColor = [[UIColor colorWithHexString:@"#0073bf"] CGColor];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                    // cell.layer.backgroundColor = [[UIColor colorWithHexString:@"#000000"] CGColor];
                } else if ([item.name  isEqual: @"Suisse"]) {
                    //item.name = @"   Suisse";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Monde"]) {
                    //item.name = @"   Monde";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Économie"]) {
                    //item.name = @"   Économie";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Culture"]) {
                    //item.name = @"   Culture";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Football"]) {
                    //item.name = @"   Football";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Hockey"]) {
                    //item.name = @"   Hockey";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Basketball"]) {
                    //item.name = @"   Basketball";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Volleyball"]) {
                    //item.name = @"   Volleyball";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Cyclisme"]) {
                    //item.name = @"   Cyclisme";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Ski"]) {
                    // item.name = @"   Ski";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Hippisme"]) {
                    // item.name = @"   Hippisme";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Tennis"]) {
                    // item.name = @"   Tennis";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Autres sports"]) {
                    //item.name = @"   Autres sports";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Sports motorisés"]) {
                    // item.name = @"   Sports motorisés";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Inline hockey"]) {
                    // item.name = @"   Inline hockey";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else {
                    [actualCell setName:item.name];
                    actualCell.layer.backgroundColor = [[UIColor colorWithHexString:@"#0099ff"] CGColor];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#2182c3"] CGColor];
                }
                
                BOOL shouldExpand = [self.allMenuItems indexOfObjectPassingTest:^BOOL(MenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    return obj.parentId == item.id;
                }] != NSNotFound;
                
                UIImage *icon = nil;
                
                if(shouldExpand && item.id != 0) {
                    icon = [UIImage imageNamed:@"hamburger_menu"];
                }
                else if(VALID_NOTEMPTY(item.link, NSString)) {
                    icon = [UIImage imageNamed:@"link"];
                }
                
                if(VALID(icon, UIImage)) {
                    [actualCell setImage:icon];
                }
            }
        }
    }
    else if(tableView == self.contentTableView) {
        
        if (indexPath.section == 0) {
            
            GalerieDetailTopTableViewCell *actualCell = (GalerieDetailTopTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"GalerieDetailTopTableViewCell"];
            if(!VALID(actualCell, GalerieDetailTopTableViewCell)) {
                NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"GalerieDetailTopTableViewCell" owner:self options:nil];
                
                if(VALID_NOTEMPTY(views, NSArray)) {
                    actualCell = [views objectAtIndex:0];
                }
            }
            NSString *authorHTML = @"";
            NSArray *contentValue = [self.galerieDetail valueForKey:@"content"];
            if(VALID_NOTEMPTY(contentValue, NSArray)) {
                authorHTML = [contentValue objectAtIndex:0];
            }
            [actualCell setTitle:@"Titulo" andAuthor:authorHTML andLink:@"http://rfj.ch"];
            cell = actualCell;
            return cell;
        }
        GalerieDetailTableViewCell *actualCell = (GalerieDetailTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"newsItemCell"];
        if(!VALID(actualCell, GalerieDetailTableViewCell)) {
            NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"GalerieDetailTableViewCell" owner:self options:nil];
            
            if(VALID_NOTEMPTY(views, NSArray)) {
                actualCell = [views objectAtIndex:0];
            }
        }
        
        if(VALID(actualCell, GalerieDetailTableViewCell)) {
            cell = actualCell;
            //actualCell.delegate = self;
            

            
           
            if(indexPath.row >= 0 && indexPath.row < [self.galeriesDetail.contentGallery count]) {
               
                [actualCell setItem:self.galeriesDetail atIndex:indexPath.row];
                
            }
        }
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.menuTableView) {
        return 44.0f;
    }
    else if(tableView == self.contentTableView) {
        if (indexPath.section == 0) {
            return 100;
        }
            
        return ceilf([UIScreen mainScreen].bounds.size.width * 0.6372340425531915);
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
                
                [self.menuTableView deleteRowsAtIndexPaths:removedRows withRowAnimation:UITableViewRowAnimationTop];
                
                self.menuHeightConstraint.constant = self.menuHeightConstraint.constant - [removedRows count] * kMenuRowHeight;
                
                [UIView animateWithDuration:kMenuAnimationTime animations:^{
                    [self.menuTableView beginUpdates];
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
                WebViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewController"];
                
                if(VALID(controller, WebViewController)) {
                    controller.url = menuItem.link;
                    [self.navigationController pushViewController:controller animated:YES];
                }
            }
            else {
//                if ([@(menuItem.id) isEqualToNumber:[NSNumber numberWithInt:0]]) {
//                    
//                    InfoContinuViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"infoContinuViewController"];
//                    
//                    if(VALID(controller, InfoContinuViewController)) {
//                        //controller.navigationId = @(menuItem.id);
//                        [self.navigationController pushViewController:controller animated:YES];
//                    }
//                } else {
                    CategoryViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"categoryViewController"];
                    
                    if(VALID(controller, CategoryViewController)) {
                        controller.navigationId = @(menuItem.id);
                        [self.navigationController pushViewController:controller animated:YES];
                    }
                //}
            }
        }
    }
}



#pragma mark - NewsItemTableViewCell Delegate

//-(void)NewsItemDidTap:(NewsItemTableViewCell *)item {
//    NSLog(@"ITEM COUNT %lu", (unsigned long)self.newsItems.count);
//    NSLog(@"SORTED COUNT %lu", (unsigned long)self.sortedNewsItems.count);
//    NSIndexPath *index = [self.contentTableView indexPathForCell:item];
//    //NSLog(@"DID SELECT ROW AT ITEM: %ld", (long)index.row);
//    if(index.row >= 0 && index.row < [self.newsItems count]) {
//        NewsGroupViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"newsGroup"];
//        //NSLog(@"ITEM COUNT: %ld", (long)index.row);
//        //NSLog(@"SECTION COUNT: %ld", (long)index.section);
//        
//        
//        if(VALID(controller, NewsGroupViewController)) {
//            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
//                NewsItem *localItem = [item.item MR_inContext:localContext];
//                
//                if(VALID(localItem, NewsItem)) {
//                    localItem.read = YES;
//                }
//            }];
//            
//            [self.contentTableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
//            
//            controller.newsToDisplay = [self combinedNewsItems];
//            controller.startingIndex = @([controller.newsToDisplay indexOfObjectPassingTest:^BOOL(NewsItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                return obj == item.item;
//            }]);
//            
//            [self.navigationController pushViewController:controller animated:YES];
//        }
//    }
//}
@end
