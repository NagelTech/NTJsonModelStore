//
//  GeoJSONFeature.h
//  NTJsonModelStoreExample
//
//  Created by Ethan Nagel on 12/22/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import "GeoJSONObject.h"

@interface GeoJSONFeature : GeoJSONObject

@property (nonatomic,readonly) GeoJSONObject *geometry;

@end


@protocol GeoJSONFeature <NSObject>
@end
