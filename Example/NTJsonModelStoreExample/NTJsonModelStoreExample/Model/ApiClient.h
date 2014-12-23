//
//  ApiClient.h
//  NTJsonModelStoreExample
//
//  Created by Ethan Nagel on 12/22/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GeoJSONFeatureCollection.h"

typedef NSString *RecentType;
extern RecentType RecentHour;
extern RecentType RecentDay;
extern RecentType RecentWeek;
extern RecentType RecentMonth;

typedef NSString *CategoryType;

extern CategoryType CategoryAll;
extern CategoryType CategorySignificant;
extern CategoryType Category4_5;
extern CategoryType Category2_5;
extern CategoryType Category1_0;


@interface ApiClient : NSObject

-(void)beginGetCategory:(CategoryType)categoryType recent:(RecentType)recentType responseHandler:(void (^)(GeoJSONFeatureCollection *earthquakes, NSError *error))responseHandler;

@end
