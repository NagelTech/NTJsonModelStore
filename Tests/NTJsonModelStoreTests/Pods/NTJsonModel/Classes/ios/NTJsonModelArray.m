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
    id _jsonArray;
    BOOL _isMutable;
    id<NTJsonModelContainer> __weak _parentJsonContainer;
    
    NSMutableArray *_valueCache;
}

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


-(id)initWithModelClass:(Class)modelClass jsonArray:(NSArray *)jsonArray
{
    self = [super init];
    
    if ( self )
    {
        _modelClass = modelClass;
        _jsonArray = jsonArray;
        _isMutable = NO;
        _valueCache = nil;
    }
    
    return self;
}


-(id)initWithModelClass:(Class)modelClass mutableJsonArray:(NSArray *)mutableJsonArray
{
    self = [super init];
    
    if ( self )
    {
        _modelClass = modelClass;
        _jsonArray = mutableJsonArray;
        _isMutable = YES;
        _valueCache = nil;
    }
    
    return self;
}


#pragma mark - Properties


-(NSArray *)jsonArray
{
    return _jsonArray;
}


-(NSMutableArray *)mutableJsonArray
{
    return (_isMutable) ? _jsonArray : nil;
}


-(id<NTJsonModelContainer>)parentJsonContainer
{
    return _parentJsonContainer;
}


-(void)setParentJsonContainer:(id<NTJsonModelContainer>)parentJsonContainer
{
    _parentJsonContainer = parentJsonContainer;
}


#pragma mark - cache support


-(id)cachedObjectAtIndex:(NSUInteger)index
{
    if ( !_valueCache )
        return nil; // nothing in the cache here
    
    if ( index >= _valueCache.count )
        return nil; //past the end of what we have cached
    
    id value = _valueCache[index];
    
    return (value == [NTJsonModelArrayEmptyElement emptyElement] ? nil : value);
}


-(void)ensureCacheSize:(NSUInteger)size
{
    if ( !_valueCache )
        _valueCache = [NSMutableArray arrayWithCapacity:size];
    
    while ( _valueCache.count < size )
        [_valueCache addObject:[NTJsonModelArrayEmptyElement emptyElement]];
}


#pragma mark - NSCopying, NSMutableCopying


-(id)copyWithZone:(NSZone *)zone
{
    NSArray *jsonArray = (self.isMutable) ? NTJsonModel_deepCopy(self.mutableJsonArray) : self.jsonArray;
    
    return [[NTJsonModelArray alloc] initWithModelClass:_modelClass jsonArray:jsonArray];
}


-(id)mutableCopyWithZone:(NSZone *)zone
{
    NSMutableArray *mutableJsonArray = NTJsonModel_mutableDeepCopy(self.jsonArray);
    
    return [[NTJsonModelArray alloc] initWithModelClass:_modelClass mutableJsonArray:mutableJsonArray];
}



#pragma mark - becomeMutable


-(void)setMutableJson:(id)mutableJson // recursive
{
    _jsonArray = mutableJson;
    _isMutable = YES;
    
    if ( _valueCache )
    {
        for(int index=0; index<_valueCache.count; index++)
        {
            id<NTJsonModelContainer> cachedValue = _valueCache[index];
            
            if ( cachedValue == [NTJsonModelArrayEmptyElement emptyElement] )
                continue;    // empty
            
            id value = _jsonArray[index];
            
            [cachedValue setMutableJson:value];
        }
    }
}


-(void)becomeMutable
{
    if ( self.isMutable )
        return ;
    
    if ( self.parentJsonContainer )
    {
        [self.parentJsonContainer becomeMutable];
        return ;
    }
    
    [self setMutableJson:NTJsonModel_mutableDeepCopy(_jsonArray)];
}


#pragma mark - NSArray overrides


-(NSUInteger)count
{
    return self.jsonArray.count;
}


-(id)objectAtIndex:(NSUInteger)index
{
    // Grab from the cache if it exists...
    
    id value = [self cachedObjectAtIndex:index];
    
    if ( value )
        return value;
    
    id jsonValue = self.jsonArray[index];
    
    // handle nulls right away
    
    if ( jsonValue == [NSNull null] )
        return jsonValue;
    
    // transform

    if ( self.isMutable )
        value = [[_modelClass alloc] initWithMutableJson:jsonValue];
    else
        value = [[_modelClass alloc] initWithJson:jsonValue];
    
    [value setParentJsonContainer:self];
    
    // cache...
    
    [self ensureCacheSize:index];
    _valueCache[index] = value;
    
    return value;
}


#pragma mark - NAMutableArray overrides


-(void)insertObject:(id)value atIndex:(NSUInteger)index
{
    // todo: check nil
    
    if ( !self.isMutable )
        [self becomeMutable];
    
    if ( value != [NSNull null] && ![value isKindOfClass:self.modelClass] )
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Attempt to insert invalid class type into NTJsonModel array" userInfo:nil];
    
    // Make sure it's mutable
    
    NTJsonModel *model = value;
    
    if ( model.parentJsonContainer )
        @throw [NSException exceptionWithName:@"MultipleParents" reason:@"Cannot add item to NTJsonModelArray because it is already a member of another object." userInfo:nil];
    
    if ( !model.isMutable )
        [model becomeMutable];
    
    [model setParentJsonContainer:self];
    
    // Cache...
    
    [self ensureCacheSize:index];
    [_valueCache insertObject:model atIndex:index];
    
    // Store...
    
    [self.mutableJsonArray insertObject:model.mutableJson atIndex:index];
}


-(void)removeObjectAtIndex:(NSUInteger)index
{
    if ( !self.isMutable )
        [self becomeMutable];

    if ( _valueCache && _valueCache.count >= index )
    {
        NTJsonModel *cachedValue = _valueCache[index];
        
        if ( [cachedValue conformsToProtocol:@protocol(NTJsonModelContainer)] )
            [cachedValue setParentJsonContainer:nil];
        
        [_valueCache removeObjectAtIndex:index];
    }
    
    [self.mutableJsonArray removeObjectAtIndex:index];
}


-(void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)value
{
    // todo: check nil

    if ( !self.isMutable )
        [self becomeMutable];
    
    if ( value != [NSNull null] && ![value isKindOfClass:self.modelClass] )
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Attempt to insert invalid class type into NTJsonModel Array" userInfo:nil];
    
    // Make sure it's mutable
    
    NTJsonModel *model = value;
    
    if ( model.parentJsonContainer )
        @throw [NSException exceptionWithName:@"MultipleParents" reason:@"Cannot add item to NTJsonModelArray because it is already a member of another object." userInfo:nil];
    
    if ( !model.isMutable )
        [model becomeMutable];
    
    [model setParentJsonContainer:self];
    
    // Cache...
    
    [self ensureCacheSize:index+1];
    
    NTJsonModel *cachedValue = _valueCache[index];
    
    if ( [cachedValue conformsToProtocol:@protocol(NTJsonModelContainer)] )
        [cachedValue setParentJsonContainer:nil];
    
    [_valueCache replaceObjectAtIndex:index withObject:model];
    
    // Store...
    
    [self.mutableJsonArray replaceObjectAtIndex:index withObject:model.mutableJson];
}


-(void)addObject:(id)anObject
{
    [self insertObject:anObject atIndex:self.count];
}


-(void)removeLastObject
{
    if ( !self.count )
        @throw [NSException exceptionWithName:NSRangeException reason:@"range exception" userInfo:nil];
    
    [self removeObjectAtIndex:self.count-1];
}


@end

