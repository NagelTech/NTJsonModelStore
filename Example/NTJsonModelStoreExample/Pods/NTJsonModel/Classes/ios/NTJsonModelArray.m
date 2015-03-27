//
//  NTJsonModelArray.m
//  NTJsonModelSample
//
//  Created by Ethan Nagel on 4/9/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

#import "NTJsonModel+Private.h"


@interface NTJsonModelArrayEmptyElement : NSObject

+(id)emptyElement;

@end



@interface NTJsonModelArray ()
{
    Class _modelClass;
    NTJsonProp *_property;
    NSArray *_json;
    
    NSMutableArray *_valueCache;
}

@property (nonatomic,readonly) BOOL isModel;
@property (nonatomic,readonly) Class typeClass;
@property (nonatomic,readonly) BOOL supportsCacheValidation;

@end


@implementation NTJsonModelArrayEmptyElement


+(id)emptyElement
{
    static NTJsonModelArrayEmptyElement *emptyElement = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        emptyElement = [[NTJsonModelArrayEmptyElement alloc] init];
    });
    
    return emptyElement;
}


@end


@implementation NTJsonModelArray


#pragma mark - Initialization


-(id)initWithModelClass:(Class)modelClass json:(NSArray *)json
{
    self = [super init];
    
    if ( self )
    {
        _modelClass = modelClass;
        _json = [json copy];
        _valueCache = [NSMutableArray arrayWithCapacity:_json.count];
    }
    
    return self;
}


-(id)initWithProperty:(NTJsonProp *)property json:(NSArray *)json
{
    self = [super init];
    
    if ( self )
    {
        _property = property;
        _json = [json copy];
        _valueCache = [NSMutableArray arrayWithCapacity:_json.count];
    }
    
    return self;
}


#pragma mark - Properties


-(NSArray *)__NSJsonModelArray_json
{
    return _json;
}


-(BOOL)isModel
{
    if ( _property )
        return (_property.type == NTJsonPropTypeModelArray) ? YES : NO;
    else
        return YES;
}


-(Class)modelClass
{
    if ( _modelClass )
        return _modelClass;
    else
        return (_property.type == NTJsonPropTypeModelArray) ? _property.typeClass : Nil;
}


-(Class)typeClass
{
    return (_modelClass) ? _modelClass : _property.typeClass;
}


-(BOOL)supportsCacheValidation
{
    return (_property) ? NO : _property.supportsCacheValidation;
}


#pragma mark - cache support


-(id)cachedObjectAtIndex:(NSUInteger)index
{
    @synchronized(_valueCache)
    {
        if ( index >= _valueCache.count )
            return nil; //past the end of what we have cached
        
        id value = _valueCache[index];
        
        return (value == [NTJsonModelArrayEmptyElement emptyElement] ? nil : value);
    }
}


-(void)setCachedValue:(id)value atIndex:(NSUInteger)index
{
    @synchronized(_valueCache)
    {
        while ( _valueCache.count < index )
            [_valueCache addObject:[NTJsonModelArrayEmptyElement emptyElement]];

        _valueCache[index] = value;
    }
}


#pragma mark - NSCopying, NSMutableCopying


-(id)copyWithZone:(NSZone *)zone
{
    return self;    // it's already immutable
}


-(id)mutableCopyWithZone:(NSZone *)zone
{
    return [NSMutableArray arrayWithArray:self];
}


#pragma mark - NSArray overrides


-(NSUInteger)count
{
    return _json.count;
}


-(id)objectAtIndex:(NSUInteger)index
{
    id value = [self cachedObjectAtIndex:index];

    if ( value && !self.supportsCacheValidation )
        return value;   // short-curcuit right here if it's safe...

    id jsonValue = _json[index];

    if ( self.isModel )
    {
        // handle NSNulls or invalid types right away

        if ( ![jsonValue isKindOfClass:[NSDictionary class]] )
            value = [NSNull null];
        else
            value = [[self.modelClass alloc] initWithJson:jsonValue];

        // cache...

        if ( value )
            [self setCachedValue:value atIndex:index];

        return value;
    }

    // it's an object array - perform cache validation

    id newValue = (value) ? [_property object_validateCachedValue:value forJson:jsonValue] : nil;

    if ( !newValue )
        newValue = [_property object_convertJsonToValue:jsonValue];

    if ( newValue && newValue != value  )
    {
        value = newValue;
        [self setCachedValue:value atIndex:index];
    }

    return value;
}


@end


