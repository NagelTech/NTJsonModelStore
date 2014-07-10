//
//  NTJsonModel.m
//  NTJsonModelSample
//
//  Created by Ethan Nagel on 4/8/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

#import <objc/runtime.h>

#import "NTJsonModel+Private.h"


@interface NTJsonModel () <NTJsonModelContainer>
{
    id _json;
    BOOL _isMutable;
    id<NTJsonModelContainer> __weak _parentJsonContainer;
}

@end


@implementation NTJsonModel


static char ALL_PROPERTY_INFO_ASSOC_KEY;
static char DEFAULT_JSON_ASSOC_KEY;


#pragma mark - One-time initialization


+(BOOL)addImpsForProperty:(NTJsonProp *)property
{
    id getBlock;
    id setBlock;
    const char *typeCode = nil;
    
    switch(property.type)
    {
        case NTJsonPropTypeInt:
        {
            typeCode = @encode(int);
            setBlock = ^(NTJsonModel *model, int value)
            {
                [model setValue:@(value) forProperty:property];
            };
            getBlock = ^int(NTJsonModel *model)
            {
                NSNumber *value = [model getValueForProperty:property];
                
                if ( ![value respondsToSelector:@selector(intValue)] )
                    value = property.defaultValue;
                
                return [value intValue];
            };
            break;
        }
            
        case NTJsonPropTypeBool:
        {
            typeCode = @encode(BOOL);
            setBlock = ^(NTJsonModel *model, BOOL value)
            {
                [model setValue:@(value) forProperty:property];
            };
            getBlock = ^BOOL(NTJsonModel *model)
            {
                NSNumber *value = [model getValueForProperty:property];
                
                if ( ![value respondsToSelector:@selector(boolValue)] )
                    value = property.defaultValue;
                
                return [value boolValue];
            };
            break;
        }
            
        case NTJsonPropTypeFloat:
        {
            typeCode = @encode(float);
            setBlock = ^(NTJsonModel *model, float value)
            {
                [model setValue:@(value) forProperty:property];
            };
            getBlock = ^float(NTJsonModel *model)
            {
                NSNumber *value = [model getValueForProperty:property];
                
                if ( ![value respondsToSelector:@selector(floatValue)] )
                    value = property.defaultValue;
                
                return [value floatValue];
            };
            break;
        }
            
        case NTJsonPropTypeDouble:
        {
            typeCode = @encode(double);
            setBlock = ^(NTJsonModel *model, double value)
            {
                [model setValue:@(value) forProperty:property];
            };
            getBlock = ^double(NTJsonModel *model)
            {
                NSNumber *value = [model getValueForProperty:property];
                
                if ( ![value respondsToSelector:@selector(doubleValue)] )
                    value = property.defaultValue;
                
                return [value doubleValue];
            };
            break;
        }
            
        case NTJsonPropTypeLongLong:
        {
            typeCode = @encode(long long);
            setBlock = ^(NTJsonModel *model, long long value)
            {
                [model setValue:@(value) forProperty:property];
            };
            getBlock = ^long long(NTJsonModel *model)
            {
                NSNumber *value = [model getValueForProperty:property];
                
                if ( ![value respondsToSelector:@selector(longLongValue)] )
                    value = property.defaultValue;
                
                return [value longLongValue];
            };
            break;
        }
            
        case NTJsonPropTypeString:
        case NTJsonPropTypeStringEnum:
        {
            typeCode = @encode(NSString *);
            setBlock = ^void(NTJsonModel *model, NSString *value)
            {
                [model setValue:value forProperty:property];
            };
            getBlock = ^NSString *(NTJsonModel *model)
            {
                id value = [model getValueForProperty:property];
                
                if ( ![value isKindOfClass:[NSString class]] && [value respondsToSelector:@selector(stringValue)] )
                    value = [value stringValue];
                
                return [value isKindOfClass:[NSString class]] ? value : nil;
            };
            break;
        }
            
        case NTJsonPropTypeModel:
        case NTJsonPropTypeModelArray:
        case NTJsonPropTypeObject:
        case NTJsonPropTypeObjectArray:
        {
            typeCode = @encode(id);
            setBlock = ^(NTJsonModel *model, id value)
            {
                [model setValue:value forProperty:property];
            };
            getBlock = ^id(NTJsonModel *model)
            {
                return [model getValueForProperty:property];
            };
            break;
        }
            
        default:
            @throw [NSException exceptionWithName:@"UnexpectedPropertyType" reason:[NSString stringWithFormat:@"Unexpected property type for %@.%@", NSStringFromClass(self), property.name] userInfo:nil];
    }
    
    char setTypes[80];
    char getTypes[80];
    
    sprintf(setTypes, "v:@:%s", typeCode);
    sprintf(getTypes, "%s@:", typeCode);
    
    IMP setImp = imp_implementationWithBlock(setBlock);
    IMP getImp = imp_implementationWithBlock(getBlock);
    
    SEL setSel = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [[property.name substringToIndex:1] uppercaseString], [property.name substringFromIndex:1]]);
    SEL getSel = NSSelectorFromString(property.name);;
    
    IMP getPrevImp = class_replaceMethod(self, getSel, getImp, getTypes);
    IMP setPrevImp = class_replaceMethod(self, setSel, setImp, setTypes);
    
    if ( getPrevImp || setPrevImp )
    {
        NSLog(@"Error: an existing implementation of an NTJsonModel property %@.%@ was found. Missing @dynamic?", NSStringFromClass(self), property.name);
        
        return NO; // Warnings
    }
    
    return YES; // success
}


+(NSArray *)jsonPropertiesForClass:(Class)class
{
    unsigned int numProperties;
    objc_property_t *objc_properties = class_copyPropertyList(class, &numProperties);
    
    NSMutableArray *properties = [NSMutableArray arrayWithCapacity:numProperties];
    
    for(unsigned int index=0; index<numProperties; index++)
    {
        objc_property_t objc_property = objc_properties[index];
        
        NTJsonProp *prop = [NTJsonProp propertyWithClass:self objcProperty:objc_property];

        if ( prop )
            [properties addObject:prop];
    }
    
    free(objc_properties);

    return [properties copy];
}


+(void)initialize
{
    if ( self == [NTJsonModel class] )
        return ; // nothing to initialize for ourselves...
    
    if ( [self jsonAllPropertyInfo] )
        return ; // already initiailized
    
    NSMutableDictionary *jsonAllPropertyInfo = [NSMutableDictionary dictionary];
    BOOL success = YES;
    
    // start with properties from our superclass...
    
    if ( self.superclass != [NTJsonModel class] )
        [jsonAllPropertyInfo addEntriesFromDictionary:[self.superclass jsonAllPropertyInfo]];
    
    // Add our properties and create the implementations for them...
    
    for(NTJsonProp *property in [self jsonPropertiesForClass:self])
    {
        success = success && [self addImpsForProperty:property];
        jsonAllPropertyInfo[property.name] = property;
    }
    
    if ( !success )
    {
        @throw [NSException exceptionWithName:@"NTJsonModelErrors" reason:[NSString stringWithFormat:@"Errors encountered initializing properties for NTJsonModel class %@, see log for more information.", NSStringFromClass(self)] userInfo:nil];
    }

    objc_setAssociatedObject(self, &ALL_PROPERTY_INFO_ASSOC_KEY, [jsonAllPropertyInfo copy], OBJC_ASSOCIATION_RETAIN);
}


#pragma mark - Constructors


-(id)init
{
    self = [super init];
    
    if ( self )
    {
        _json = [NSMutableDictionary dictionary];
        _isMutable = YES;
    }
    
    return self;
}


-(id)initWithJson:(NSDictionary *)json
{
    self = [super init];
    
    if ( self )
    {
        _json = json;
        _isMutable = NO;
    }
    
    return self;
}


-(id)initWithMutableJson:(NSMutableDictionary *)mutableJson
{
    self = [super init];
    
    if ( self )
    {
        _json = mutableJson;
        _isMutable = YES;
    }
    
    return self;
}


+(instancetype)modelWithJson:(NSDictionary *)json
{
    if ( !json )
        return nil;
    
    return [[self alloc] initWithJson:json];
}


+(instancetype)modelWithMutableJson:(NSMutableDictionary *)mutableJson
{
    if ( !mutableJson )
        return nil;
    
    return [[self alloc] initWithMutableJson:mutableJson];
}


#pragma mark - Array Helpers


+(NSArray *)arrayWithJsonArray:(NSArray *)jsonArray
{
    if ( ![jsonArray isKindOfClass:[NSArray class]] )
        return nil;
    
    return [[NTJsonModelArray alloc] initWithModelClass:self jsonArray:jsonArray];
}


+(NSMutableArray *)arrayWithMutableJsonArray:(NSMutableArray *)mutableJsonArray
{
    if ( ![mutableJsonArray isKindOfClass:[NSArray class]] )
        return nil;

    return [[NTJsonModelArray alloc] initWithModelClass:self mutableJsonArray:mutableJsonArray];
}


#pragma mark - Properties


-(NSDictionary *)json
{
    return _json;
}


-(NSMutableDictionary *)mutableJson
{
    return (_isMutable) ? _json : nil;
}


-(id<NTJsonModelContainer>)parentJsonContainer
{
    return _parentJsonContainer;
}


-(void)setParentJsonContainer:(id<NTJsonModelContainer>)parentJsonContainer
{
    _parentJsonContainer = parentJsonContainer;
}


#pragma mark - NSCopying & NSMutableCopying


id NTJsonModel_mutableDeepCopy(id json)
{
    if ( [json isKindOfClass:[NSDictionary class]] )
    {
        NSMutableDictionary *mutable = [NSMutableDictionary dictionaryWithCapacity:[json count]];
        
        for (id key in [json allKeys])
        {
            id value = [json objectForKey:key];
            
            if ( [value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]] )
                value = NTJsonModel_mutableDeepCopy(value);
            
            [mutable setObject:value forKey:key];
        }
        
        return mutable;
    }
    
    else if ( [json isKindOfClass:[NSArray class]] )
    {
        NSMutableArray *mutable = [NSMutableArray arrayWithCapacity:[json count]];
        
        for(id item in json)
        {
            id value = item;
            
            if ( [value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]] )
                value = NTJsonModel_mutableDeepCopy(value);
            
            [mutable addObject:value];
        }
        
        return mutable;
    }
    
    else
        return json;
}


id NTJsonModel_deepCopy(id json)
{
    if ( [json isKindOfClass:[NSDictionary class]] )
    {
        NSMutableDictionary *mutable = [NSMutableDictionary dictionaryWithCapacity:[json count]];
        
        for (id key in [json allKeys])
        {
            id value = [json objectForKey:key];
            
            if ( [value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]] )
                value = NTJsonModel_mutableDeepCopy(value);
            
            [mutable setObject:value forKey:key];
        }
        
        return [mutable copy];  // return immutable copy
    }
    
    else if ( [json isKindOfClass:[NSArray class]] )
    {
        NSMutableArray *mutable = [NSMutableArray arrayWithCapacity:[json count]];
        
        for(id item in json)
        {
            id value = item;
            
            if ( [value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]] )
                value = NTJsonModel_mutableDeepCopy(value);
            
            [mutable addObject:value];
        }
        
        return [mutable copy];
    }
    
    else
        return json;
}


-(id)mutableCopyWithZone:(NSZone *)zone
{
    NSMutableDictionary *mutableJson = NTJsonModel_mutableDeepCopy(self.json);
    
    return [[self.class allocWithZone:zone] initWithMutableJson:mutableJson];
}


-(id)copyWithZone:(NSZone *)zone
{
    NSDictionary *json = (self.isMutable) ? NTJsonModel_deepCopy(self.json) : self.json;
    
    return [[self.class allocWithZone:zone] initWithJson:json];
}


#pragma mark - becomeMutable


-(void)setMutableJson:(NSMutableDictionary *)mutableJson        // recursive
{
    _json = mutableJson;
    _isMutable = YES;
    
    for(NTJsonProp *property in self.class.jsonAllPropertyInfo.allValues)
    {
        if ( !property.shouldCache )
            continue;
        
        id cacheValue = [self getCacheValueForProperty:property];
        
        if ( !cacheValue )
            continue;
        
        if ( [cacheValue conformsToProtocol:@protocol(NTJsonModelContainer)] )
        {
            // Models are remapped so they point to the new JSON
            id jsonValue = [self.json objectForKey:property.jsonKeyPath];
            [cacheValue setMutableJson:jsonValue];
        }
    }
}


-(void)becomeMutable
{
    if ( self.isMutable )
        return ;
    
    if ( self.parentJsonContainer )
    {
        // we are not the root object, forward the request on...
        [self.parentJsonContainer becomeMutable];
        return ;
    }
    
    // we are the root, so we actually have work to do...
    
    [self setMutableJson:NTJsonModel_mutableDeepCopy(_json)];  // recursive
}


#pragma mark - Property Info management


+(NSArray *)jsonPropertyInfo
{
    return @[];
}


+(NSDictionary *)jsonAllPropertyInfo
{
    return objc_getAssociatedObject(self, &ALL_PROPERTY_INFO_ASSOC_KEY);
}


#pragma mark - default json


+(NSDictionary *)_defaultJsonWithParentClasses:(NSSet *)parentClasses
{
    parentClasses = (parentClasses) ? [parentClasses setByAddingObject:[self class]] : [NSSet setWithObject:[self class]];
    
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    
    for(NTJsonProp *prop in [self jsonAllPropertyInfo].allValues)
    {
        id defaultValue;
        
        if ( prop.type == NTJsonPropTypeModel ) // recursive here...
        {
            if ( [parentClasses containsObject:[self class]] ) // prevent infinite recursion if self referential
                defaultValue = nil;
            else
                defaultValue = [self _defaultJsonWithParentClasses:parentClasses];
        }
        
        else
            defaultValue = prop.defaultValue;
        
        if ( defaultValue )
            [defaults NTJsonModel_setObject:defaultValue forKeyPath:prop.jsonKeyPath];
    }
    
    return (defaults.count) ? defaults : nil;
}


+(NSDictionary *)defaultJson
{
    NSDictionary *defaultJson = objc_getAssociatedObject(self, &DEFAULT_JSON_ASSOC_KEY);
    
    if ( !defaultJson )
    {
        defaultJson = NTJsonModel_deepCopy([self _defaultJsonWithParentClasses:nil]) ?: (id)[NSNull null];
        
        objc_setAssociatedObject(self, &DEFAULT_JSON_ASSOC_KEY, defaultJson, OBJC_ASSOCIATION_RETAIN);
    }
    
    return (defaultJson == (id)[NSNull null]) ? nil : defaultJson;
}


#pragma mark - caching


-(id)getCacheValueForProperty:(NTJsonProp *)property
{
    if ( property.shouldCache )
    {
        id cachedValue = objc_getAssociatedObject(self, (__bridge void *)property);
        
        if ( cachedValue )
            return cachedValue;
    }
    
    return nil;
}


-(void)setCacheValue:(id)value forProperty:(NTJsonProp *)property
{
    if ( !property.shouldCache )
        return ;
    
    // If there is currently a container in this slot, clear it...
    
    id cachedValue = objc_getAssociatedObject(self, (__bridge void *)property);
    
    if ( [cachedValue conformsToProtocol:@protocol(NTJsonModelContainer)] )
        [cachedValue setParentJsonContainer:nil];
    
    objc_setAssociatedObject(self, (__bridge void *)property, value, OBJC_ASSOCIATION_RETAIN);
    
    // Assign the container parent (if valid)...
    
    if ( [value conformsToProtocol:@protocol(NTJsonModelContainer)] )
        [value setParentJsonContainer:self];
}


#pragma mark - get/set values


-(id)getValueForProperty:(NTJsonProp *)property
{
    // get from cache, if it is present...
    
    id value = (property.shouldCache) ? [self getCacheValueForProperty:property] : nil;
    
    if ( value )
        return value;
    
    // grab the value from our json...
    
    id jsonValue = [self.json objectForKey:property.jsonKeyPath];
    
    // transform it...
    
    switch (property.type)
    {
        case NTJsonPropTypeInt:
        case NTJsonPropTypeBool:
        case NTJsonPropTypeFloat:
        case NTJsonPropTypeDouble:
        case NTJsonPropTypeLongLong:
        case NTJsonPropTypeString:
        {
            value = jsonValue;  // more validation/conversion happens in the thunks
            break;
        }
            
        case NTJsonPropTypeStringEnum:
        {
            NSString *enumValue = [property.enumValues member:jsonValue];
            value = (enumValue) ? enumValue : jsonValue;
            break;
        }
            
        case NTJsonPropTypeModel:
        {
            if ( !jsonValue )
                value = nil;
            else if ( self.isMutable )
                value = [[property.typeClass alloc] initWithMutableJson:jsonValue];
            else
                value = [[property.typeClass alloc] initWithJson:jsonValue];

            break;
        }
            
        case NTJsonPropTypeModelArray:
        {
            if ( !jsonValue )
                jsonValue = nil;
            else if ( self.isMutable )
                value = [[NTJsonModelArray alloc] initWithModelClass:property.typeClass mutableJsonArray:jsonValue];
            else
                value = [[NTJsonModelArray alloc] initWithModelClass:property.typeClass jsonArray:jsonValue];
            break ;
        }
            
        case NTJsonPropTypeObject:
        {
            value = [property convertJsonToValue:jsonValue];
            break;
        }
            
        case NTJsonPropTypeObjectArray:
        {
            // todo: use ModelArray
            break;
        }
    }

    // save in cache, if indicated...
    
    if ( property.shouldCache && value != jsonValue )
        [self setCacheValue:value forProperty:property];
    
    return value;
}


-(void)setValue:(id)value forProperty:(NTJsonProp *)property
{
    // todo: see if the value is actually changing
    
    // make sure we are mutable...
    
    if ( !self.isMutable )
        [self becomeMutable];
    
    // if nil is passed in we simply remove the value
    
    if ( !value )
    {
        if (property.shouldCache)
            [self setCacheValue:nil forProperty:property];
        
        [_json removeObjectForKey:property.jsonKeyPath];
        return ;
    }

    // Convert to json...
    
    id jsonValue = nil;
    Class expectedValueType = Nil;
    
    switch (property.type)
    {
        case NTJsonPropTypeInt:
        case NTJsonPropTypeBool:
        case NTJsonPropTypeFloat:
        case NTJsonPropTypeDouble:
        case NTJsonPropTypeLongLong:
            expectedValueType = [NSNumber class];
            jsonValue = value;
            break;
            
        case NTJsonPropTypeString:
            expectedValueType = [NSString class];
            jsonValue = value;
            break;

        case NTJsonPropTypeStringEnum:
        {
            expectedValueType = [NSString class];
            NSString *enumValue = [property.enumValues member:value];
            jsonValue = (enumValue) ? enumValue : value;
            break;
        }
            
        case NTJsonPropTypeModel:
            expectedValueType = [NTJsonModel class];
            jsonValue = [value respondsToSelector:@selector(json)] ? [value json] : nil;
            break;
            
        case NTJsonPropTypeModelArray:
            expectedValueType = [NTJsonModelArray class];
            jsonValue = [value respondsToSelector:@selector(jsonArray)] ? [value jsonArray] : nil;
            break ;

            
        case NTJsonPropTypeObject:
            expectedValueType = property.typeClass;
            jsonValue = [property convertValueToJson:value];
            break;
            
        case NTJsonPropTypeObjectArray:
            // to do - conversion
            break;
    }
    
    // Validate we got the correct expected type...
    
    if ( ![value isKindOfClass:expectedValueType] )
        @throw [NSException exceptionWithName:@"InvalidType" reason:@"Invalid type when setting property" userInfo:nil];
    
    // validate this object is not associated with another parent already...
    
    if ( [value conformsToProtocol:@protocol(NTJsonModelContainer)] )
    {
        id<NTJsonModelContainer> container = value;
        
        if ( container.parentJsonContainer )
            @throw [NSException exceptionWithName:@"MultipleParents" reason:@"Cannot add item to NTJsonModel because it is alrready a member of another object." userInfo:nil];
        
        if ( !container.isMutable )
            [container becomeMutable];
    }
    
    // if we don't have a value now then we have a problem
    
    if ( !jsonValue )
        @throw [NSException exceptionWithName:@"InvalidJsonObject" reason:@"Unable to convert property to JSON object" userInfo:nil];
    
    // actually set the json...
    
    self.mutableJson[property.jsonKeyPath] = jsonValue;
    
    // cache the value, if indicated
    
    if ( property.shouldCache && value != jsonValue )
        [self setCacheValue:value forProperty:property];
}


@end
