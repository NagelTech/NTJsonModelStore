//
//  NSArray+NTJsonModel.m
//  NTJsonModelSample
//
//  Created by Ethan Nagel on 9/8/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

#import "NTJsonModel+Private.h"


@implementation NSArray (NTJsonModel)


-(id)asJson
{
    if ( [self respondsToSelector:@selector(__NSJsonModelArray_json)] )
        return [(id)self __NSJsonModelArray_json];
    
    NSMutableArray *jsonArray = [NSMutableArray arrayWithCapacity:self.count];
    
    for(id item in self)
    {
        id json;
        
        if ( [item respondsToSelector:@selector(asJson)] )
            json = [item asJson];   // will handle all arrays, dictionaries, NTJsonModels (and any other objects that implement asJson)
        
        else if ( [item isKindOfClass:[NSNumber class]]
                 || [item isKindOfClass:[NSString class]]
                 || [item isKindOfClass:[NSNull class]] )
            json = [item copy]; // make sure we don't get a mutable something or other some how (NSMutableString for instance)
        
        else if ( [[item class] respondsToSelector:@selector(convertValueToJson:)] )
            json = [[item class] convertValueToJson:item];
        
        else
            json = nil;
        
        if ( !json ) // unable to convert or conversion returned nil for some reason
            @throw [NSException exceptionWithName:@"NTJsonModelInvalidJson"
                                           reason:[NSString stringWithFormat:@"asJson cannot convert element of type %@ to json", NSStringFromClass([item class])]
                                         userInfo:nil];
        
        [jsonArray addObject:json];
    }
    
    return [jsonArray copy];
}


@end
