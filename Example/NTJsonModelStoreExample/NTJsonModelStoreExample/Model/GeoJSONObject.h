//
//  GeoJSONObject.h
//  NTJsonModelStoreExample
//
//  Created by Ethan Nagel on 12/22/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import "NTJsonStorableModel.h"

#import "BoundingBox.h"


typedef NSString *GeoJSONType;

extern GeoJSONType GeoJSONTypePoint;
extern GeoJSONType GeoJSONTypeFeature;
extern GeoJSONType GeoJSONTypeFeatureCollection;


@interface GeoJSONObject : NTJsonStorableModel

@property (nonatomic,readonly) GeoJSONType type;
@property (nonatomic,readonly) BoundingBox *bbox;

+(NSArray *)types;

@end


@protocol GeoJSONObject <NSObject>
@end