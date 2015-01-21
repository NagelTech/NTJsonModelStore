//
//  NSDate+NTJsonPropertyConversion.m
//  NTJsonModelStoreExample
//
//  Created by Ethan Nagel on 1/3/15.
//  Copyright (c) 2015 Nagel Technologies, Inc. All rights reserved.
//

#import "NSDate+NTJsonPropertyConversion.h"


@implementation NSDate (NTJsonPropertyConversion)


+(id)convertJsonToValue:(id)json
{
    if ( ![json isKindOfClass:[NSNumber class]] )
        return nil;
    
    double value = [json doubleValue];
    
    if ( value > 2147483647.0 )
        value /= 1000.0;
    
    return [NSDate dateWithTimeIntervalSince1970:value];
}


@end
