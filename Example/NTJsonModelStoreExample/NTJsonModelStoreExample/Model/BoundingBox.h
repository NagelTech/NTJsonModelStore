//
//  BoundingBox.h
//  NTJsonModelStoreExample
//
//  Created by Ethan Nagel on 12/22/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

#import <NTJsonPropertyConversion.h>


@interface BoundingBox : NSObject <NTJsonPropertyConversion>

@property (nonatomic,readonly) CLLocation *min;
@property (nonatomic,readonly) CLLocation *max;

-(id)initWithJsonArray:(NSArray *)jsonArray;

@end
