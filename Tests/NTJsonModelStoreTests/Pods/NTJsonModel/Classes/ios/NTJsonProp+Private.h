//
//  NTJsonProp+Private.h
//  NTJsonModelSample
//
//  Created by Ethan Nagel on 4/18/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

#import <objc/runtime.h>

@class NTJsonModel;

typedef enum
{
    NTJsonPropTypeString        = 1,
    NTJsonPropTypeInt           = 2,
    NTJsonPropTypeBool          = 3,
    NTJsonPropTypeFloat         = 4,
    NTJsonPropTypeDouble        = 5,
    NTJsonPropTypeLongLong      = 6,
    NTJsonPropTypeModel         = 7,
    NTJsonPropTypeModelArray    = 8,
    NTJsonPropTypeStringEnum    = 9,
    NTJsonPropTypeObject        = 10,   // a custom object of some kind (eg NSDate)
    NTJsonPropTypeObjectArray   = 11,   // an array of custom objects
} NTJsonPropType;


@interface NTJsonProp : NSObject

@property (nonatomic,readonly) Class modelClass;
@property (nonatomic,readonly) NSString *name;
@property (nonatomic,readonly) NSString *jsonKey;               // the first part of the key path
@property (nonatomic,readonly) NSString *remainingJsonKeyPath;  // any remaining key path values (readonly properties only)
@property (nonatomic,readonly) NSString *jsonKeyPath;           
@property (nonatomic,readonly) NTJsonPropType type;
@property (nonatomic,readonly) Class typeClass;
@property (nonatomic,readonly) NSSet *enumValues;
@property (nonatomic,readonly) id defaultValue;
@property (nonatomic,readonly) BOOL shouldCache;
@property (nonatomic,readonly) BOOL cachedObject;
@property (nonatomic,readonly) BOOL isReadOnly;

// conversion

-(id)object_convertValueToJson:(id)object;
-(id)object_convertJsonToValue:(id)json;

-(id)convertValueToJson:(id)object;
-(id)convertJsonToValue:(id)json;

+(instancetype)propertyWithClass:(Class)class objcProperty:(objc_property_t)objcProperty;


@end
