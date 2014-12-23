//
//  GeoJSONFeature.m
//  NTJsonModelStoreExample
//
//  Created by Ethan Nagel on 12/22/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import "GeoJSONFeature.h"

#import "Earthquake.h"


@implementation GeoJSONFeature


NTJsonProperty(geometry)


+(Class)modelClassForJson:(NSDictionary *)json
{
    NSDictionary *properties = json[@"properties"];
    
    if ( [properties isKindOfClass:[NSDictionary class]] )
    {
        NSObject *mag = properties[@"mag"];
        
        if ( [mag isKindOfClass:[NSNumber class]] )
            return [Earthquake class];  // assume it's an earthquake object if mag is included
    }
    
    return [GeoJSONFeature class];
}


@end
