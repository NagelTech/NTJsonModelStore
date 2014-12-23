//
//  Earthquake.h
//  NTJsonModelStoreExample
//
//  Created by Ethan Nagel on 12/22/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import "GeoJSONFeature.h"


@interface Earthquake : GeoJSONFeature

@property (nonatomic,readonly) NSString *code;
@property (nonatomic,readonly) NSString *title;
@property (nonatomic,readonly) double magnitude;
@property (nonatomic,readonly) NSDate *time;

@property (nonatomic,readonly) CLLocation *location;

@end
