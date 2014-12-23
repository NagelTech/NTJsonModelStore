//
//  Earthquake.m
//  NTJsonModelStoreExample
//
//  Created by Ethan Nagel on 12/22/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import "Earthquake.h"

#import "GeoJSONPoint.h"


@implementation Earthquake

NTJsonProperty(code, jsonPath="properties.code")
NTJsonProperty(title, jsonPath="properties.title")
NTJsonProperty(magnitude, jsonPath="properties.mag")


-(CLLocation *)location
{
    return ([self.geometry isKindOfClass:[GeoJSONPoint class]]) ? ((GeoJSONPoint *)self.geometry).coordinate : nil;
}


@end
