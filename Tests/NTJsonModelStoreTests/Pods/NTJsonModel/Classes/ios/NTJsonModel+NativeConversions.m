//
//  NTJsonModel+NativeConversions.m
//  NTJsonModelSample
//
//  Created by Ethan Nagel on 4/19/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

#import "NTJsonModel+NativeConversions.h"



@implementation NSDictionary (NTJsonModelNativeConversions)


+(id)convertJsonToValue:(id)json
{
    return [json isKindOfClass:self] ? json : nil;
}


+(id)convertValueToJson:(id)value
{
    return value;
}


@end


@implementation NSArray (NTJsonModelNativeConversions)


+(id)convertJsonToValue:(id)json
{
    return [json isKindOfClass:self] ? json : nil;
}


+(id)convertValueToJson:(id)value
{
    return value;
}


@end


@implementation NSNumber (NTJsonModelNativeConversions)


+(id)convertJsonToValue:(id)json
{
    if ( [json isKindOfClass:self] )
        return json;
    
    if ( [json isKindOfClass:[NSString class]] )
    {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        
        formatter.numberStyle = NSNumberFormatterDecimalStyle;

        return [formatter numberFromString:json];
    }
    
    return nil;
}


+(id)convertValueToJson:(id)value
{
    return value;
}


@end


@implementation NSString (NTJsonModelNativeConversions)


+(id)convertJsonToValue:(id)json
{
    if ( [json isKindOfClass:[NSString class]] )
        return json;
    
    if ( [json respondsToSelector:@selector(stringValue)] )
        return [json stringValue];
    
    return nil;
}


+(id)convertValueToJson:(id)value
{
    return value;
}


@end