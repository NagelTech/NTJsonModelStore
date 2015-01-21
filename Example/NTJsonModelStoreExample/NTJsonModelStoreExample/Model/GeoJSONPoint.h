//
//  GeoJSONPoint.h
//  NTJsonModelStoreExample
//
//  Created by Ethan Nagel on 12/22/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import "GeoJSONObject.h"


@interface GeoJSONPoint : GeoJSONObject

@property (nonatomic,readonly) CLLocation *coordinate;

@end


@protocol GeoJSONPoint <NSObject>
@end