//
//  GeoJSONFeatureCollection.h
//  NTJsonModelStoreExample
//
//  Created by Ethan Nagel on 12/22/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import "GeoJSONObject.h"

#import "GeoJSONFeature.h"


@interface GeoJSONFeatureCollection : GeoJSONObject

@property (nonatomic,readonly) NSArray<GeoJSONFeature> *features;

@end
