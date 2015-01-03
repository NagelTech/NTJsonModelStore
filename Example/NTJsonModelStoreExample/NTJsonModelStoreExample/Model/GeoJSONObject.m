//
//  GeoJSONObject.m
//  NTJsonModelStoreExample
//
//  Created by Ethan Nagel on 12/22/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import "GeoJSONObject.h"

#import "GeoJSONPoint.h"
#import "GeoJSONFeature.h"
#import "GeoJSONFeatureCollection.h"

GeoJSONType GeoJSONTypePoint = @"Point";
GeoJSONType GeoJSONTypeFeature = @"Feature";
GeoJSONType GeoJSONTypeFeatureCollection = @"FeatureCollection";


@implementation GeoJSONObject


NTJsonCacheSize(100)
NTJsonIndex(type)
NTJsonProperty(type, enumValues=[GeoJSONObject types])
NTJsonProperty(bbox)


+(NSArray *)types
{
    return @[GeoJSONTypePoint, GeoJSONTypeFeature, GeoJSONTypeFeatureCollection];
}


+(Class)modelClassForJson:(NSDictionary *)json
{
    NSString *type = json[@"type"];
    
    if ( [type isKindOfClass:[NSString class]] )
    {
        if ( [type isEqualToString:GeoJSONTypePoint] )
            return [GeoJSONPoint class];
        
        else if ( [type isEqualToString:GeoJSONTypeFeature] )
            return [GeoJSONFeature class];
        
        else if ( [type isEqualToString:GeoJSONTypeFeatureCollection] )
            return [GeoJSONFeatureCollection class];
    }
    
    return [GeoJSONObject class];
}


@end
