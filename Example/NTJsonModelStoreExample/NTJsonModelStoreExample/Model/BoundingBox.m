//
//  BoundingBox.m
//  NTJsonModelStoreExample
//
//  Created by Ethan Nagel on 12/22/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import "BoundingBox.h"

#import "CLLocation+GeoJSON.h"


@implementation BoundingBox


-(id)initWithJsonArray:(NSArray *)jsonArray
{
    if ( (self=[super init]) )
    {
        NSInteger middle = jsonArray.count / 2;
        
        _min = (middle) ? [[CLLocation alloc] initWithJsonArray:[jsonArray subarrayWithRange:NSMakeRange(0,middle)]] : nil;
        _max = (middle) ? [[CLLocation alloc] initWithJsonArray:[jsonArray subarrayWithRange:NSMakeRange(middle, jsonArray.count-middle)]] : nil;
    }
    
    return self;
}


+(id)convertJsonToValue:(id)json
{
    return ([json isKindOfClass:[NSArray class]]) ? [[self alloc] initWithJsonArray:json] : nil;
}


@end
