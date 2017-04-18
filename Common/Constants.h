//
//  Constants.h
//  rfj
//
//  Created by Nuno Silva on 01/03/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#ifndef Constants_h
#define Constants_h
#import "UIColor+HexString.h"

#define kNewsDetailIsHTML 1
#define kNewsDetailIsMarkdown 0

#define kMenuColorNormal [UIColor colorWithRed:0 green:153 / 255.0f blue:255 / 255.0f alpha:1]
#define kMenuColorSelected [UIColor colorWithRed:236 / 255.0f green:171 / 255.0f blue:31 / 255.0f alpha:1]

#define kNewsReadColor [UIColor lightGrayColor]

#define kMenuAnimationTime 0.5f
#define kItemsPerPage 10
#define kMenuRowHeight 44.0f
#define kContentCategorySeparatorHeight 30.0f

#define kBackgroundColorRFJ [UIColor colorWithHexString:@"0099ff"]
#define kBackgroundColorRJB [UIColor colorWithHexString:@"fb7d19"]
#define kBackgroundColorRTN [UIColor colorWithHexString:@"d5022d"]

#define kZoneIDRFJ 31
#define kZoneIDRJB 32
#define kZoneIDRTN 33

#define kObjectTypeNews 0
#define kObjectTypeGallery 1

#define kShareURLRFJ @"http://www.rfj.ch"
#define kShareURLRJB @"http://www.rjb.ch"
#define kShareURLRTN @"http://www.rtn.ch"

#define kURLNavigationFormat @"http://json.rfj.ch/Services/Mobile/MobileService.svc/navigation/list/%@"
#define kURLTemporaryNavigationFormat @"http://json.rfj.ch/Services/Mobile/MobileService.svc/navigation/temporary/%@"

#if kNewsDetailIsHTML
#   define kURLNewsDetailsFormat @"http://json.rfj.ch/Services/Mobile/MobileService.svc/news/%@?format=html"
#else
#   define kURLNewsDetailsFormat @"http://json.rfj.ch/Services/Mobile/MobileService.svc/news/%@?format=markdown"
#endif

#define kURLLastNewsFormat @"http://json.rfj.ch/Services/Mobile/MobileService.svc/news/lastNews/%@?objectType=%@&lastLocalObjectId=%@&pageIndex=%@&categoryId=%@"
#define kURLResourcesFormat @"http://json.rfj.ch/Services/Mobile/MobileService.svc/news/resources?type=%@"

#define kURLUsername @"RFJMobileService"
#define kURLPassword @"mCph5hVQ8WVJP_>W"


#endif /* Constants_h */
