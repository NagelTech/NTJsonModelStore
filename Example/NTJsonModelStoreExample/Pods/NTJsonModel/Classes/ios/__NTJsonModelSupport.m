//
//  __NTJsonModelSupport.m
//  NTJsonModelSample
//
//  Created by Ethan Nagel on 9/4/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

#import "__NTJsonModelSupport.h"

#import "NTJsonModel+Private.h"


@interface __NTJsonModelSupport ()
{
    NSArray *_properties;
    NSDictionary *_allRelatedProperties;
    NSDictionary *_defaultJson;
    NSNumber *_modelClassForJsonOverridden;
    BOOL _isImmutableClass;
    NSArray *_propertyMetadata;
}

@property (nonatomic,readonly) NSDictionary *allRelatedProperties;

@end


@implementation __NTJsonModelSupport


-(__NTJsonModelSupport *)superSupport
{
    if ( self.modelClass.superclass == [NSObject class] )
        return nil;
    else
        return [self.modelClass.superclass __ntJsonModelSupport];
}


#pragma mark - Helpers


static BOOL classImplementsSelector(Class class, SEL selector)
{
    BOOL found = NO;
    
    unsigned int count;
    Method *methods = class_copyMethodList(object_getClass(class), &count);
    
    for(unsigned int index=0; index<count; index++)
    {
        SEL sel = method_getName(methods[index]);
        
        if ( sel == selector )
        {
            found = YES;
            break;
        }
    }
    
    free(methods);

    return found;
}


static id fastDeepCopy(id value)
{
    if ( [value isKindOfClass:[NSArray class]] )
    {
        // perform a a deep copy of the array, but only if any values actually change when calling fastDeepCopy on them

        NSArray *array = value;
        NSMutableArray *mutableArray = nil;

        for(int index=0; index<array.count; index++)
        {
            id value = array[index];
            id valueCopy = fastDeepCopy(value);

            // If the copy is not identical to the original and we haven't created the mutableArray yet,
            // initialize it with the first values.

            if ( value != valueCopy && !mutableArray )
            {
                mutableArray = (index > 0) ? [[array subarrayWithRange:NSMakeRange(0, index)] mutableCopy] : [NSMutableArray array];
            }

            // If we have created the mutableArray then we are performing a deep copy, so append the value...

            if ( mutableArray )
            {
                [mutableArray addObject:valueCopy];
            }
        }

        return (mutableArray) ? [mutableArray copy] : [array copy];
    }

    else if ( [value isKindOfClass:[NSDictionary class]] )
    {
        // NSDictionaries aren't as easy to enumerate and we expect them to be mostly immutable
        // so we first do a pass to see if it is immutable and if it isn't then we fall back to full
        // deep copy logic...

        NSDictionary *dictionary = value;

        __block BOOL allValuesImmutable = YES;

        [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
            id valueCopy = fastDeepCopy(value);

            if ( value != valueCopy )
            {
                allValuesImmutable = NO;
                *stop = YES;
            }
        }];

        if ( allValuesImmutable )
            return [dictionary copy];   // values are immutable, so we can do a shallow copy

        // Do it the old fashioned way....

        NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];

        [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
            mutableDictionary[key] = fastDeepCopy(value);
        }];
        
        return [mutableDictionary copy];
    }
    
    return [value copy];
}


#pragma mark - Initialization


-(void)addImpsForProperty:(NTJsonProp *)property
{
    // Figure out the typeCode, getter and setter based on the property type...
    
    const char *typeCode = nil;
    id getBlock = nil;
    id setBlock = nil;
    
    switch(property.type)
    {
        case NTJsonPropTypeInt:
        {
            typeCode = @encode(int);
            setBlock = ^(NTJsonModel *model, int value)
            {
                [self setValue:@(value) forProperty:property inModel:model];
            };
            getBlock = ^int(NTJsonModel *model)
            {
                return [[self getValueForProperty:property inModel:model] intValue];
            };
            break;
        }
            
        case NTJsonPropTypeBool:
        {
            typeCode = @encode(BOOL);       // may map to bool or signed char, depening on, umm maybe 64 vs 32 bit? that's ok though.
            setBlock = ^(NTJsonModel *model, BOOL value)
            {
                [self setValue:@(value) forProperty:property inModel:model];
            };
            getBlock = ^BOOL(NTJsonModel *model)
            {
                return [[self getValueForProperty:property inModel:model] boolValue];
            };
            break;
        }
            
        case NTJsonPropTypeFloat:
        {
            typeCode = @encode(float);
            setBlock = ^(NTJsonModel *model, float value)
            {
                [self setValue:@(value) forProperty:property inModel:model];
            };
            getBlock = ^float(NTJsonModel *model)
            {
                return [[self getValueForProperty:property inModel:model] floatValue];
            };
            break;
        }
            
        case NTJsonPropTypeDouble:
        {
            typeCode = @encode(double);
            setBlock = ^(NTJsonModel *model, double value)
            {
                [self setValue:@(value) forProperty:property inModel:model];
            };
            getBlock = ^double(NTJsonModel *model)
            {
                return [[self getValueForProperty:property inModel:model] doubleValue];
            };
            break;
        }
            
        case NTJsonPropTypeLongLong:
        {
            typeCode = @encode(long long);
            setBlock = ^(NTJsonModel *model, long long value)
            {
                [self setValue:@(value) forProperty:property inModel:model];
            };
            getBlock = ^long long(NTJsonModel *model)
            {
                return [[self getValueForProperty:property inModel:model] longLongValue];
            };
            break;
        }
            
        case NTJsonPropTypeString:
        case NTJsonPropTypeStringEnum:
        case NTJsonPropTypeModel:
        case NTJsonPropTypeModelArray:
        case NTJsonPropTypeObject:
        case NTJsonPropTypeObjectArray:
        {
            typeCode = @encode(id);
            setBlock = ^(NTJsonModel *model, id value)
            {
                [self setValue:value forProperty:property inModel:model];
            };
            getBlock = ^id(NTJsonModel *model)
            {
                return [self getValueForProperty:property inModel:model];
            };
            break;
        }
            
        default:
            @throw [NSException exceptionWithName:@"NTJsonPropertyError" reason:[NSString stringWithFormat:@"Unexpected property type for %@.%@", NSStringFromClass(self.modelClass), property.name] userInfo:nil];
    }

    // Always add the getter...
    
    char getTypes[80];
    sprintf(getTypes, "%s@:", typeCode);
    IMP getImp = imp_implementationWithBlock(getBlock);
    SEL getSel = NSSelectorFromString(property.name);
    IMP getPrevImp = class_replaceMethod(self.modelClass, getSel, getImp, getTypes);
    
    if ( getPrevImp )
    {
        @throw [NSException exceptionWithName:@"NTJsonPropertyError"
                                       reason:[NSString stringWithFormat:@"An existing getter of an NTJsonModel property %@.%@ was found. Missing @dynamic?", NSStringFromClass(self.modelClass), property.name]
                                     userInfo:nil];
    }
    
    // Add setter if this is a read/write property...
    
    if ( !property.isReadOnly )
    {
        char setTypes[80];
        sprintf(setTypes, "v:@:%s", typeCode);
        IMP setImp = imp_implementationWithBlock(setBlock);
        SEL setSel = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [[property.name substringToIndex:1] uppercaseString], [property.name substringFromIndex:1]]);
        
        IMP setPrevImp = class_replaceMethod(self.modelClass, setSel, setImp, setTypes);
        
        if ( setPrevImp )
        {
            @throw [NSException exceptionWithName:@"NTJsonPropertyError"
                                           reason:[NSString stringWithFormat:@"An existing setter of an NTJsonModel property %@.%@ was found. Missing @dynamic?", NSStringFromClass(self.modelClass), property.name]
                                         userInfo:nil];
        }
    }
}


+(Protocol *)findMutableProtocolForClass:(Class)modelClass
{
    if ( classImplementsSelector(modelClass, @selector(__ntJsonModelMutableProtocol)) )
        return [modelClass __ntJsonModelMutableProtocol];
    
    return nil;
}


+(NSArray *)extractPropertiesForModelClass:(Class)modelClass
{
    unsigned int numProperties;
    objc_property_t *objc_properties = class_copyPropertyList(modelClass, &numProperties);
    
    NSMutableArray *properties = [NSMutableArray arrayWithCapacity:numProperties];
    
    for(unsigned int index=0; index<numProperties; index++)
    {
        objc_property_t objc_property = objc_properties[index];
        
        NTJsonProp *prop = [NTJsonProp propertyWithClass:modelClass objcProperty:objc_property];
        
        if ( prop )
            [properties addObject:prop];
    }
    
    free(objc_properties);
    
    // If there is a mutable protocol, then we also parse the properties out of that...
    
    Protocol *mutableProtocol = [self findMutableProtocolForClass:modelClass];
    
    if ( mutableProtocol )
    {
        // Force all properties to be read-only...
        
        for(NTJsonProp *prop in properties)
        {

            if (!prop.isReadOnly )
            {
                @throw [NSException exceptionWithName:@"NTJsonPropertyError"
                                               reason:[NSString stringWithFormat:@"NTJsonModel property %@.%@ must be declared read-only if a mutable protocol (%@) is declared.", NSStringFromClass(modelClass), prop.name, NSStringFromProtocol(mutableProtocol)]
                                             userInfo:nil];
            }
        }
        
        unsigned int numProperties;
        objc_property_t *objc_properties = protocol_copyPropertyList(mutableProtocol, &numProperties);
        
        for(unsigned int index=0; index<numProperties; index++)
        {
            objc_property_t objc_property = objc_properties[index];
            
            NTJsonProp *prop = [NTJsonProp propertyWithClass:modelClass objcProperty:objc_property];
            
            if ( !prop )
                continue ;
            
            // Replace any existing or append new properties...
            
            NSInteger existingIndex = [properties indexOfObjectPassingTest:^BOOL(NTJsonProp *item, NSUInteger idx, BOOL *stop) {
                return [item.name isEqualToString:prop.name];
            }];
            
            if ( existingIndex != NSNotFound )
            {
                [properties replaceObjectAtIndex:existingIndex withObject:prop];
            }
            else
            {
                [properties addObject:prop];
            }
        }
        
        free(objc_properties);
    }
    
    return[properties copy];
}


+(NSDictionary *)findAllRelatedPropertiesIn:(NSArray *)properties
{
    // Build our array of related properties...
    
    NSMutableDictionary *allRelatedProperties = [NSMutableDictionary dictionary];
    
    for(NTJsonProp *prop in properties)
    {
        NSMutableArray *relatedProperties = nil;
        
        for (NTJsonProp *related in properties)
        {
            if ( prop == related )
                continue;
            
            if ( [related.jsonKey isEqualToString:prop.jsonKey] )
            {
                if ( !relatedProperties )
                    relatedProperties = [NSMutableArray array];
                
                [relatedProperties addObject:related];
            }
        }
        
        if ( relatedProperties )
            allRelatedProperties[prop.name] = [relatedProperties copy];
    }
  
    return [allRelatedProperties copy];
}


-(NSArray *)relatedPropertiesForProperty:(NTJsonProp *)prop
{
    return self.allRelatedProperties[prop.name] ?: @[];
}


-(void)validateRelatedProperties
{
    for (NTJsonProp *prop in self.properties)
    {
        if ( prop.isReadOnly )
            continue;
        
        NSArray *relatedProperties = [self relatedPropertiesForProperty:prop];
        
        if ( !relatedProperties.count )
            continue;
        
        NSMutableArray *readwriteNames = nil;
        
        for(NTJsonProp *related in relatedProperties)
        {
            if ( !related.isReadOnly )
            {
                if ( !readwriteNames )  // delay creating this unless there is actually an error
                    readwriteNames = [NSMutableArray arrayWithObject:prop.name];
                
                [readwriteNames addObject:related.name];
            }
        }
        
        if ( readwriteNames.count > 1 )
        {
            @throw [NSException exceptionWithName:@"NTJsonPropertyError"
                                           reason:[NSString stringWithFormat:@"Only one readwrite property may refer to the same jsonPath, consider making secondary properties read-only. Properties: %@(%@), JsonKey: %@", NSStringFromClass(self.modelClass), [readwriteNames componentsJoinedByString:@", "], prop.jsonKey]
                                         userInfo:nil];
        }
    }
}


-(instancetype)initWithModelClass:(Class)modelClass
{
    if ( (self=[super init]) )
    {
        _modelClass = modelClass;
        
        // start with properties from our superclass...
        
        NSMutableArray *properties = [NSMutableArray array];
        
        if ( self.superSupport )
            [properties addObjectsFromArray:self.superSupport.properties];
        
        // Add our properties and create the implementations for them...
        
        BOOL isImmutable = YES;
        
        for(NTJsonProp *property in [self.class extractPropertiesForModelClass:self.modelClass])
        {
            // If another property exists with the same name, we are overriding it...
            
            __block NTJsonProp *prevProp = nil;
            
            [properties enumerateObjectsUsingBlock:^(NTJsonProp *item, NSUInteger idx, BOOL *stop)
            {
                if ( [item.name isEqualToString:property.name] )
                {
                    prevProp = item;
                    *stop = YES;
                }
            }];
            
            if ( prevProp ) // remove any previous property...
            {
                // todo: I suppose we could do validation on this property to make sure overring makes sense.
                [properties removeObjectIdenticalTo:prevProp];
            }
            
            [self addImpsForProperty:property];
            
            [properties addObject:property];
            
            if ( !property.isReadOnly )
                isImmutable = NO;
        }
        
        _properties = [properties copy];
        
        _isImmutableClass = isImmutable;
        
        // Get our related properties...
        
       _allRelatedProperties = [self.class findAllRelatedPropertiesIn:properties];
        
        // Now validate related properties...
        
        [self validateRelatedProperties];
     }
    
    return self;
}


#pragma mark - Properties


-(BOOL)isMutableClass
{
    return !_isImmutableClass;
}


-(BOOL)modelClassForJsonOverridden
{
    if ( !_modelClassForJsonOverridden )
    {
         _modelClassForJsonOverridden = @(classImplementsSelector(self.modelClass, @selector(modelClassForJson:)));
    }
    
    return [_modelClassForJsonOverridden boolValue];
}


-(NSArray *)propertyMetadata
{
    if ( !_propertyMetadata )
    {
        NSMutableArray *propertyMetadata = [NSMutableArray new];
        
        for(NTJsonProp *prop in self.properties)
        {
            [propertyMetadata addObject:
            @{
                @"name": prop.name,
                @"jsonKeyPath": prop.jsonKeyPath,
                @"modelClass": prop.modelClass,
                }];
        }
        
        _propertyMetadata = [propertyMetadata copy];
    }
    
    return _propertyMetadata;
}


#pragma mark - default json


+(NSDictionary *)setValue:(id)value forKeyPath:(NSString *)keyPath inDictionary:(NSDictionary *)dictionary
{
    NSMutableDictionary *newDictionary = (dictionary) ? [dictionary mutableCopy] : [NSMutableDictionary dictionary];
    
    NSUInteger dotPos = [keyPath rangeOfString:@"."].location;
    
    if ( dotPos != NSNotFound)
    {
        NSString *key = [keyPath substringToIndex:dotPos];
        NSString *remainingKeyPath = [keyPath substringFromIndex:dotPos+1];
        
        NSDictionary *nestedDictionary = [newDictionary objectForKey:key];
        
        if ( ![nestedDictionary isKindOfClass:[NSDictionary class]] )
            nestedDictionary = nil;
        
        newDictionary[key] = [self setValue:value forKeyPath:remainingKeyPath inDictionary:nestedDictionary];
    }
    else
        newDictionary[keyPath] = value;
    
    return [newDictionary copy];
}


-(NSDictionary *)defaultJsonWithParentClasses:(NSSet *)parentClasses
{
    
    parentClasses = (parentClasses) ? [parentClasses setByAddingObject:self.modelClass] : [NSSet setWithObject:self.modelClass];
    
    NSMutableDictionary *defaults = nil;
    
    for(NTJsonProp *prop in self.properties)
    {
        id defaultValue;
        
        if ( prop.type == NTJsonPropTypeModel ) // recursive here...
        {
            if ( [parentClasses containsObject:self.modelClass] ) // prevent infinite recursion if self referential
                defaultValue = nil;
            else
                defaultValue = [[prop.modelClass __ntJsonModelSupport] defaultJsonWithParentClasses:parentClasses]; // recursive
        }
        
        else
            defaultValue = prop.defaultValue;
        
        if ( defaultValue )
        {
            if ( !defaults )
                defaults = [NSMutableDictionary dictionary];
            
            if ( prop.remainingJsonKeyPath )
            {
                defaults[prop.jsonKey] = [self.class setValue:defaultValue forKeyPath:prop.remainingJsonKeyPath inDictionary:defaults[prop.jsonKey]];
            }
            else
                defaults[prop.jsonKey] = defaultValue;
        }
    }
    
    return [defaults copy];
}


-(NSDictionary *)defaultJson
{
    if ( !_defaultJson )
    {
        _defaultJson = [self defaultJsonWithParentClasses:nil] ?: (id)[NSNull null];
    }
    
    return (_defaultJson == (id)[NSNull null]) ? nil : _defaultJson;
}


#pragma mark - caching


-(id)getCacheValueForProperty:(NTJsonProp *)property inModel:(NTJsonModel *)model
{
    if ( property.shouldCache || model.isMutable )
    {
        id cachedValue = objc_getAssociatedObject(model, (__bridge void *)property);
        
        if ( cachedValue )
            return cachedValue;
    }
    
    return nil;
}


-(void)setCacheValue:(id)value forProperty:(NTJsonProp *)property inModel:(NTJsonModel *)model
{
    objc_setAssociatedObject(model, (__bridge void *)property, value, OBJC_ASSOCIATION_RETAIN);
}


#pragma mark - getValue


-(id)getValueForProperty:(NTJsonProp *)property inModel:(NTJsonModel *)model
{
    BOOL supportsCacheValidation = (property.type == NTJsonPropTypeObject && property.supportsCacheValidation) ? YES : NO;

    // get from cache, if it is present...
    
    id value = [self getCacheValueForProperty:property inModel:model];
    
    if ( value && !supportsCacheValidation )
        return value;   // short-circuit right here if it's safe
    
    // grab the value from our json...
    
    id jsonValue = [model.__json objectForKey:property.jsonKey];
    
    // if there's a jsonPath, walk it to get to the effective value...
    
    if ( property.remainingJsonKeyPath.length )
    {
        NSString *keyPath = property.remainingJsonKeyPath;
        
        while ( YES )
        {
            if ( ![jsonValue isKindOfClass:[NSDictionary class]] )
            {
                jsonValue = nil;
                break;
            }
            
            NSInteger dotPos = [keyPath rangeOfString:@"."].location;
            
            if ( dotPos == NSNotFound)  // the last part
            {
                jsonValue = [jsonValue objectForKey:keyPath];
                break;
            }
            
            NSString *key = [keyPath substringToIndex:dotPos];
            keyPath = [keyPath substringFromIndex:dotPos+1];
            
            jsonValue = [jsonValue objectForKey:key];
        }
    }

    // perform cache validation if we have an existing value...

    if ( value && supportsCacheValidation )
    {
        id newValue = [property object_validateCachedValue:value forJson:jsonValue];

        if ( !newValue )
            newValue = [property convertJsonToValue:jsonValue];

        if ( newValue && newValue != value )
        {
            value = newValue;
            [self setCacheValue:value forProperty:property inModel:model];
        }
    }
    else
    {
        // More normal case, we are returning a value for the first time or no caching is necessary.

        value = [property convertJsonToValue:jsonValue];
    
        // save in cache, if there was any conversion or we had to parse a path...
        
        if ( value != jsonValue || property.remainingJsonKeyPath.length > 0 )
            [self setCacheValue:value forProperty:property inModel:model];
    }
    
    return value;
}


#pragma mark - setValue


+(id)convertValue:(id)value toTypeOfValue:(id)originalValue
{
    if ( [originalValue isKindOfClass:[NSNumber class]] )
    {
        if ( [value isKindOfClass:[NSString class]] )
        {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            
            value = [formatter numberFromString:value];
        }
        
        if ( [value isKindOfClass:[NSNumber class]] && strcmp([value objCType], [originalValue objCType]) != 0 )
        {
            const char *objcType = [originalValue objCType];
            
            if      ( strcmp(objcType, @encode(bool)) == 0 )            value = [NSNumber numberWithBool:[value boolValue]];
            else if ( strcmp(objcType, @encode(signed char)) == 0 )     value = [NSNumber numberWithBool:[value boolValue]];
            else if ( strcmp(objcType, @encode(double)) == 0)           value = [NSNumber numberWithDouble:[value doubleValue]];
            else if ( strcmp(objcType, @encode(float)) == 0)            value = [NSNumber numberWithFloat:[value floatValue]];
            else if ( strcmp(objcType, @encode(int)) == 0)              value = [NSNumber numberWithInt:[value intValue]];
            else if ( strcmp(objcType, @encode(NSInteger)) == 0)        value = [NSNumber numberWithInteger:[value integerValue]];
            else if ( strcmp(objcType, @encode(long)) == 0)             value = [NSNumber numberWithLong:[value longValue]];
            else if ( strcmp(objcType, @encode(long long)) == 0)        value = [NSNumber numberWithLongLong:[value longLongValue]];
        }
        
        return value;
    }
    
    else if ( [originalValue isKindOfClass:[NSString class]] )
    {
        if ( [value respondsToSelector:@selector(stringValue)] )
            return [value stringValue];
    }
    
    return nil; // can't convert
}


+(id)tryConvertValue:(id)value toTypeOfValue:(id)originalValue
{
    
    id newValue = [self convertValue:value toTypeOfValue:originalValue];
    
    if ( !newValue || newValue == value )
        return value;   // either we failed or are already the correct type.
    
    // Now try converting back again to make sure we get the same value out (round-tripable)
    
    id testValue = [self convertValue:newValue toTypeOfValue:value];
    
    if ( !testValue || ![testValue isEqual:value] )
        return value;   // either we failed to convert back or our reconverted values doesn't match
    
    return newValue;
}


-(void)setValue:(id)value forProperty:(NTJsonProp *)prop inModel:(NTJsonModel *)model
{
    if ( !model.isMutable )
        @throw [NSException exceptionWithName:@"NTJsonModelImmutable"
                                       reason:[NSString stringWithFormat:@"Attempt to modify immutable NTJsonModel: %@.%@", NSStringFromClass(self.modelClass), prop.name]
                                     userInfo:nil];
    
    NSMutableDictionary *json = [model __json];
    
    // nil's are pretty easy to handle...
    
    if ( !value )
    {
        [self setCacheValue:nil forProperty:prop inModel:model];
        [json removeObjectForKey:prop.jsonKey];
        return ;
    }

    // Grab a COPY of the value, so we know it's immutable
    
    value = fastDeepCopy(value);       // we always grab an immutable copy
    
    // Get the JSON for our value...
    
    id jsonValue = [prop convertValueToJson:value];
    
    // For basic types, we attempt to maintain consistency with any existing json value...
    // this helps maintain consistency when assigning and comparing values even if the underlying JSON
    // type doesn't match the model properties type...
    
    if ( prop.type == NTJsonPropTypeBool || prop.type == NTJsonPropTypeInt || prop.type == NTJsonPropTypeLongLong
        || prop.type == NTJsonPropTypeFloat || prop.type == NTJsonPropTypeDouble
        || prop.type == NTJsonPropTypeString || prop.type == NTJsonPropTypeStringEnum )
    {
        id existingValue = json[prop.jsonKey];
        
        if ( existingValue )
            jsonValue = [__NTJsonModelSupport tryConvertValue:jsonValue toTypeOfValue:existingValue];
        
        else if ( [jsonValue isEqual:prop.defaultValue] )
            jsonValue = nil;        // if there is no existing value and we are setting to the default, don't actually do anything.
    }
    
    // Now, save in our json and our cache...

    if ( jsonValue )
        json[prop.jsonKey] = jsonValue;
    else
        [json removeObjectForKey:prop.jsonKey];
    
    [self setCacheValue:value forProperty:prop inModel:model];
    
    // Clear cached values for any related properties...
    
    for(NTJsonProp *related in [self relatedPropertiesForProperty:prop])
        [self setCacheValue:nil forProperty:related inModel:model];
}


#pragma mark - description


-(NSString *)descriptionForModel:(NTJsonModel *)model fullDescription:(BOOL)fullDescription parentModels:(NSArray *)parentModels
{
    NSMutableString *desc = [NSMutableString string];
    
    if ( model.isMutable )
        [desc appendString:@"mutable"];
    
    for(NTJsonProp *prop in self.properties)
    {
        id value = [self getValueForProperty:prop inModel:model];
        id defaultValue = prop.defaultValue;
        
        if ( !fullDescription && (value == defaultValue || [value isEqual:defaultValue]) )
            continue;   // ignore properties that don't look interesting
        
        if ( desc.length > 0 )
            [desc appendString:@", "];
        
        [desc appendFormat:@"%@=", prop.name];
        
        if ( value ==nil )
        {
            [desc appendString:@"nil"];
        }
        
        else if ( value == [NSNull null] )
        {
            [desc appendString:@"NSNull"];
        }
        
        else if ( [value isKindOfClass:[NSArray class]] )
        {
            NSArray *array = value;
            
            if ( fullDescription )
            {
                [desc appendString:@"["];
                
                [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     if ( idx > 0 )
                         [desc appendString:@", "];
                     
                     if ( obj == [NSNull null] )
                     {
                         [desc appendString:@"NSNull"];
                     }
                     
                     else if ( [obj isKindOfClass:[NTJsonModel class]] )
                     {
                         if ( [parentModels indexOfObjectIdenticalTo:obj] == NSNotFound )
                         {
                             __NTJsonModelSupport *support = [[obj class] __ntJsonModelSupport];
                             
                             [desc appendString:[support descriptionForModel:obj
                                                             fullDescription:fullDescription
                                                                parentModels:[parentModels arrayByAddingObject:model]]];
                         }
                         else
                         {
                             [desc appendFormat:@"%@({recursive}])", NSStringFromClass([obj class])];
                         }
                     }
                     
                     else
                     {
                         [desc appendString:[obj description]];
                     }
                 }];
            }
            else
            {
                // don't try to display array contents
                [desc appendFormat:@"[%lu items]", (unsigned long)array.count];
            }
        }
        
        else if ( [value isKindOfClass:[NSString class]] )
        {
            const int MAX_LEN = 40;
            
            NSString *string = value;
            
            if ( !fullDescription && string.length > MAX_LEN-3 )
                string = [NSString stringWithFormat:@"%@...", [string substringToIndex:MAX_LEN-3]];
            
            [desc appendFormat:@"\"%@\"", string];
        }
        
        else if ( [value isKindOfClass:[NSNumber class]] )
        {
            NSNumber *number = value;
            
            if ( strcmp(number.objCType, @encode(BOOL)) == 0 || strcmp(number.objCType, @encode(signed char)) == 0 )  // looks like a bool
                [desc appendString:[number boolValue] ? @"YES" : @"NO"];
            else
                [desc appendString:[number stringValue]];
        }
        
        else    // child objects, etc
        {
            if ( [value isKindOfClass:[NTJsonModel class]] )
            {
                if ( !fullDescription )
                {
                    [desc appendFormat:@"%@(...)", NSStringFromClass([value class])];
                }
                
                else if ( [parentModels indexOfObjectIdenticalTo:value] == NSNotFound )
                {
                    __NTJsonModelSupport *support = [[value class] __ntJsonModelSupport];
                    
                    [desc appendString:[support descriptionForModel:value
                                                    fullDescription:fullDescription
                                                       parentModels:[parentModels arrayByAddingObject:model]]];
                }
                else
                {
                    [desc appendFormat:@"%@({recursive}])", NSStringFromClass([value class])];
                }
            }
            
            else
                [desc appendString:[value description]];
        }
    }
    
    return [NSString stringWithFormat:@"%@(%@)", NSStringFromClass(model.class), desc];
}


@end
