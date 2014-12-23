//
//  CLLocation+GeoJSON.h
//  NTJsonModelStoreExample
//
//  Created by Ethan Nagel on 12/22/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <NTJsonPropertyConversion.h>


@interface CLLocation (GeoJSON) <NTJsonPropertyConversion>

-(instancetype)initWithJsonArray:(NSArray *)jsonArray;

@end
