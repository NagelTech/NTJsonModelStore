//
//  ApiClient.m
//  NTJsonModelStoreExample
//
//  Created by Ethan Nagel on 12/22/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import "ApiClient.h"


RecentType RecentHour = @"hour";
RecentType RecentDay = @"day";
RecentType RecentWeek = @"week";
RecentType RecentMonth = @"month";

CategoryType CategoryAll = @"all";
CategoryType CategorySignificant = @"significant";
CategoryType Category4_5 = @"4.5";
CategoryType Category2_5 = @"2.5";
CategoryType Category1_0 = @"1.0";



@implementation ApiClient


+(NSOperationQueue *)operationQueue
{
    static NSOperationQueue *operationQueue;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        operationQueue = [[NSOperationQueue alloc] init];
    });
    
    return operationQueue;
}


-(void)beginRequestWithUrl:(NSString *)url responseHandler:(void (^)(NSDictionary *json, NSError *error))responseHandler
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[self.class operationQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
    {
        
        if ( connectionError )
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                responseHandler(nil, connectionError);
            });
            return ;
        }
        
        NSError *error = nil;
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0 error:&error];

        dispatch_async(dispatch_get_main_queue(), ^{
            responseHandler(json, error);
        });
    }];
}


-(void)beginGetCategory:(CategoryType)categoryType recent:(RecentType)recentType responseHandler:(void (^)(GeoJSONFeatureCollection *earthquakes, NSError *error))responseHandler
{
    [self beginRequestWithUrl:[NSString stringWithFormat:@"http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/%@_%@.geojson", categoryType, recentType] responseHandler:^(NSDictionary *json, NSError *error) {
        NSLog(@"JSON = %@",  json);
        
        responseHandler([GeoJSONFeatureCollection modelWithJson:json], error);
    }];
}
                                                        

@end
