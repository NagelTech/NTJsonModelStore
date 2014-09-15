//
//  NTJsonModel.h
//  NTJsonModelSample
//
//  Created by Ethan Nagel on 4/8/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSArray+NTJsonModel.h"
#import "NSDictionary+NTJsonModel.h"

#import "NTJsonPropertyConversion.h"

#import "NTJsonPropertyInfo.h"


@interface NTJsonModel : NSObject <NSCopying, NSMutableCopying>

@property (nonatomic,readonly) BOOL isMutable;
+(NSDictionary *)defaultJson;

-(NSDictionary *)asJson;

+(Class)modelClassForJson:(NSDictionary *)json;

-(id)init; // creates mutable instance
-(id)initWithJson:(NSDictionary *)json;
-(id)initMutableWithJson:(NSDictionary *)json;
+(instancetype)modelWithJson:(NSDictionary *)json;
+(instancetype)mutableModelWithJson:(NSDictionary *)json;

+(NSArray *)arrayWithJsonArray:(NSArray *)jsonArray;
+(NSMutableArray *)mutableArrayWithJsonArray:(NSArray *)jsonArray;

-(id)copyWithZone:(NSZone *)zone;
-(id)mutableCopyWithZone:(NSZone *)zone;

-(BOOL)isEqualToModel:(NTJsonModel *)model;
-(BOOL)isEqual:(id)object;
-(NSUInteger)hash;

-(NSString *)description;
-(NSString *)fullDescription;

@end
