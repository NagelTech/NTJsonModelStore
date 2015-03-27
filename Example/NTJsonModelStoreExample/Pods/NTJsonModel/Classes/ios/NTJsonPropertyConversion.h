//
//  NTJsonPropertyConversion.h
//  NTJsonModelSample
//
//  Created by Ethan Nagel on 4/18/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NTJsonPropertyConversion <NSObject>

@optional

+(id)convertJsonToValue:(id)json;
+(id)convertValueToJson:(id)value;

+(id)validateCachedValue:(id)value forJson:(id)json;

@end
