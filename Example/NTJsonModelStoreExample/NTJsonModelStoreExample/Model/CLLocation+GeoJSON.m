//
//  CLLocation+GeoJSON.m
//  NTJsonModelStoreExample
//
//  Created by Ethan Nagel on 12/22/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import "CLLocation+GeoJSON.h"



@implementation CLLocation (GeoJSON)


-(instancetype)initWithJsonArray:(NSArray *)jsonArray
{
    double latitude = (jsonArray.count >= 1) ? [jsonArray[0] doubleValue] : 0;
    double longitude = (jsonArray.count >= 2) ? [jsonArray[1] doubleValue] : 0;
    double altitude = (jsonArray.count >= 3) ? [jsonArray[2] doubleValue] : 0;
    
    return [self initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude)
                           altitude:altitude
                 horizontalAccuracy:0
                   verticalAccuracy:0
                          timestamp:nil];
    
}


+(id)convertJsonToValue:(id)json
{
    return ([json isKindOfClass:[NSArray class]]) ? [[self.class alloc] initWithJsonArray:json] : nil;
}


@end
