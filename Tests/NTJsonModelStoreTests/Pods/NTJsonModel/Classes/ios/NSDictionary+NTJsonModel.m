//
//  NSDictionary+NTJsonModel.m
//  NTJsonModelSample
//
//  Created by Ethan Nagel on 9/8/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

#import "NTJsonModel+Private.h"


@implementation NSDictionary (NTJsonModel)


-(id)asJson
{
    NSMutableDictionary *jsonDictionary = [NSMutableDictionary dictionaryWithCapacity:self.count];
    
    for(id key in self.allKeys)
    {
        if ( ![key isKindOfClass:[NSString class]] )
            @throw [NSException exceptionWithName:@"NTJsonModelInvalidJson"
                                           reason:[NSString stringWithFormat:@"asJson encountered a non-string key: %@(%@)", NSStringFromClass([key class]), key]
                                         userInfo:nil];
        id item = self[key];
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
                                           reason:[NSString stringWithFormat:@"asJson cannot convert element for key %@ of type %@ to json", key, NSStringFromClass([item class])]
                                         userInfo:nil];
        
        jsonDictionary[key] = json;
    }
    
    return [jsonDictionary copy];
}


@end
