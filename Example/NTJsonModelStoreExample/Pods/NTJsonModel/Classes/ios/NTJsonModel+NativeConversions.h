//
//  NTJsonModel+NativeConversions.h
//  NTJsonModelSample
//
//  Created by Ethan Nagel on 4/19/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NTJsonPropertyConversion.h"


@interface NSDictionary (NTJsonModelNativeConversions) <NTJsonPropertyConversion>

@end


@interface NSArray (NTJsonModelNativeConversions) <NTJsonPropertyConversion>

@end


@interface NSNumber (NTJsonModelNativeConversions) <NTJsonPropertyConversion>

@end


@interface NSString (NTJsonModelNativeConversions) <NTJsonPropertyConversion>

@end


