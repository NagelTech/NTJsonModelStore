//
//  NTJsonModel.h
//  NTJsonModelSample
//
//  Created by Ethan Nagel on 4/8/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NTJsonModelArray.h"
#import "NTJsonPropertyConversion.h"

#import "NTJsonPropertyInfo.h"


@interface NTJsonModel : NSObject <NSCopying, NSMutableCopying>

@property (nonatomic,readonly) NSDictionary *json;
@property (nonatomic,readonly) BOOL isMutable;

-(id)init; // creates mutable instance
-(id)initWithJson:(NSDictionary *)json;
-(id)initWithMutableJson:(NSMutableDictionary *)mutableJson;
+(instancetype)modelWithJson:(NSDictionary *)json;
+(instancetype)modelWithMutableJson:(NSMutableDictionary *)mutableJson;

+(NSArray *)arrayWithJsonArray:(NSArray *)jsonArray;
+(NSMutableArray *)arrayWithMutableJsonArray:(NSMutableArray *)mutableJsonArray;

+(NSArray *)jsonPropertyInfo;

+(NSDictionary *)defaultJson;

-(id)copyWithZone:(NSZone *)zone;
-(id)mutableCopyWithZone:(NSZone *)zone;

-(void)becomeMutable;

@end
