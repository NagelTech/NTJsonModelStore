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



@protocol NTJsonMutableModel <NSObject>

// The base model has no mutable properties

@end


@interface NTJsonModel : NSObject <NSCopying, NSMutableCopying, NSCoding>

/**
 *  returns YES if this is a mutable instance
 */
@property (nonatomic,readonly) BOOL isMutable;


/**
 *  returns the default JSON for this object.
 *
 *  @return NSDictionary with the default JSON for this object.
 */
+(NSDictionary *)defaultJson;


/**
 *  returns an array with meta data for all JSON properties in this class.
 *  Each item is a dictionary with the following keys: @"name" (NSString), @"jsonKeyPath" (NSString), @"modelClass" (Class)
 *
 *  @return NSArray with metadata for all properties in this class.
 */
+(NSArray *)jsonPropertyMetadata;


/**
 *  returns the JSON representation of the object
 *
 *  @return NSDictionary with the JSON representation of the object.
 */
-(NSDictionary *)asJson;

+(Class)modelClassForJson:(NSDictionary *)json;
+(BOOL)modelClassForJsonOverridden;

/**
 *  returns a default immutable instance.
 */
-(id)init;

/**
 *  returns an immutable object with the supplied JSON
 *
 *  @param json the JSON
 *
 *  @return a new immutable model instance
 */
-(id)initWithJson:(NSDictionary *)json;

/**
 *  creates a new mutable instance, executes the mutationBlock and returns an immmutable copy of the object.
 *
 *  @param mutationBlock block to execute on the mutable model
 *
 *  @return an immutable copy of the model
 */
-(id)initWithMutationBlock:(void (^)(id mutable))mutationBlock;

/**
 *  returns a default mutable instance.
 */
-(id)initMutable;

/**
 *  returns an mutable object with the supplied JSON
 *
 *  @param json the JSON
 *
 *  @return a new mutable model instance
 */
-(id)initMutableWithJson:(NSDictionary *)json;

/**
 *  returns an immutable object with the supplied JSON or nil if json is nil
 *
 *  @param json the JSON
 *
 *  @return a new immutable model instance or nil
 */
+(id)modelWithJson:(NSDictionary *)json;

/**
 *  creates a new mutable instance, executes the mutationBlock and returns an immmutable copy of the object.
 *
 *  @param mutationBlock block to execute on the mutable model
 *
 *  @return an immutable copy of the model
 */
+(id)modelWithMutationBlock:(void (^)(id mutable))mutationBlock;

/**
 *  returns an mutable object with the supplied JSON or nil if json is nil
 *
 *  @param json the JSON
 *
 *  @return a new mutable model instance or nil
 */
+(id)mutableModelWithJson:(NSDictionary *)json;

/**
 *  creates a mutable copy of the sender, executes the mutationBlock with it and returns an immutable copy of sender
 *
 *  @return an immutable object with the changes in the mutationBlock applied.
 */
-(id)mutate:(void (^)(id mutable))mutationBlock;

/**
 *  returns an array of immutable Model objects with the supplied type. Objects are created lazily as they are accessed.
 *
 *  @param jsonArray the JSON array
 *
 *  @return an array of Model objects.
 */
+(NSArray *)arrayWithJsonArray:(NSArray *)jsonArray;

/**
 *  returns an array of mutable Model objects with the supplied type. Objects are created lazily as they are accessed.
 *
 *  @param jsonArray the JSON array
 *
 *  @return a mutable array of mutable Model objects.
 */
+(NSMutableArray *)mutableArrayWithJsonArray:(NSArray *)jsonArray;

-(BOOL)isEqualToModel:(NTJsonModel *)model;
-(BOOL)isEqual:(id)object;
-(NSUInteger)hash;

-(NSString *)description;

/**
 *  returns a detailed description of the object
 *
 *  @return a detailed description of the object
 */
-(NSString *)fullDescription;

@end
