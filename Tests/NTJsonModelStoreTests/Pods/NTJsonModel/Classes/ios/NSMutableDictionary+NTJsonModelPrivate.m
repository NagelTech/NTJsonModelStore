//
//  NSMutableDictionary+NTJsonModelPrivate.m
//  NTJsonModelSample
//
//  Created by Ethan Nagel on 5/1/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

#import "NSMutableDictionary+NTJsonModelPrivate.h"


@implementation NSMutableDictionary (NTJsonModelPrivate)


-(void)NTJsonModel_setObject:(id)obj forKeyPath:(NSString *)keyPath
{
    // If we find a path, "x.y", parse the element and call ourselves recursively...
    
    NSUInteger dotPos = [keyPath rangeOfString:@"."].location;
    
    if ( dotPos != NSNotFound)
    {
        NSString *key = [keyPath substringToIndex:dotPos];
        NSString *remainingKeyPath = [keyPath substringFromIndex:dotPos+1];
        
        NSMutableDictionary *value = [self objectForKey:key];
        
        if ( ![value isKindOfClass:[NSMutableDictionary class]] )
        {
            value = [NSMutableDictionary dictionary];
            self[key] = value;
        }
        
        [value NTJsonModel_setObject:obj forKeyPath:remainingKeyPath];  // recursive
    }

    else
    {
        // If we get here, it's a simple key...
        [self setObject:obj forKey:keyPath];
    }
}


@end
