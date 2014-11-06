//
//  NTJsonModel.m
//  NTJsonModelSample
//
//  Created by Ethan Nagel on 4/8/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

#import <objc/runtime.h>

#import "NTJsonModel+Private.h"

#import "__NTJsonModelSupport.h"


@interface NTJsonModel ()
{
    id _json;
    BOOL _isMutable;
}

@end


@interface NTJsonModel (Mutable) <NTJsonMutableModel>

@end


@implementation NTJsonModel


#pragma mark - One-time initialization


+(__NTJsonModelSupport *)__ntJsonModelSupport
{
    return objc_getAssociatedObject(self, @selector(__ntJsonModelSupport));
}


+(void)initialize
{
    if ( ![self __ntJsonModelSupport] )
    {
        // The init call here does all initialization, including adding property getter/setters.
        // If it fails, an exception will be thrown.
        
        __NTJsonModelSupport *support = [[__NTJsonModelSupport alloc] initWithModelClass:self];
        
        if ( !support ) // unlikely, but just in case...
            @throw [NSException exceptionWithName:@"NTJsonPropertyError" reason:@"Unknown error initializing NTJsonModel class" userInfo:nil];
        
        objc_setAssociatedObject(self, @selector(__ntJsonModelSupport), support, OBJC_ASSOCIATION_RETAIN);
        
        return ;
    }
}


#pragma mark - Constructors


+(Class)modelClassForJson:(NSDictionary *)json
{
    return self;
}


-(instancetype)init
{
    self = [super init];
    
    if ( self )
    {
        _json = @{};
        _isMutable = NO;
    }
    
    return self;
}


-(instancetype)initWithJson:(NSDictionary *)json
{
    if ( [self.class __ntJsonModelSupport].modelClassForJsonOverridden )
    {
        Class modelClass = [self.class modelClassForJson:json];
        
        if ( modelClass != self.class )
            return [[modelClass alloc] initWithJson:json];
    }
    
    self = [super init];
    
    if ( self )
    {
        _json = [json copy];
        _isMutable = NO;
    }
    
    return self;
}


-(instancetype)initWithMutationBlock:(void (^)(id mutable))mutationBlock
{
    NTJsonModel *mutable = [self initMutable];
    
    if ( mutable )
        mutationBlock(mutable);
    
    return [mutable copy];
}


-(instancetype)initMutable
{
    self = [super init];
    
    if ( self )
    {
        _json = [NSMutableDictionary dictionary];
        _isMutable = YES;
    }
    
    return self;
}


-(instancetype)initMutableWithJson:(NSDictionary *)json
{
    if ( [self.class __ntJsonModelSupport].modelClassForJsonOverridden )
    {
        Class modelClass = [self.class modelClassForJson:json];
        
        if ( modelClass != self.class )
            return [[modelClass alloc] initMutableWithJson:json];
    }

    self = [super init];
    
    if ( self )
    {
        _json = [json mutableCopy];
        _isMutable = YES;
    }
    
    return self;
}


+(instancetype)modelWithJson:(NSDictionary *)json
{
    if ( ![json isKindOfClass:[NSDictionary class]] )
        return nil;
    
    return [[self alloc] initWithJson:json];
}


+(instancetype)modelWithMutationBlock:(void (^)(id mutable))mutationBlock
{
    return [[self alloc] initWithMutationBlock:mutationBlock];
}


+(instancetype)mutableModelWithJson:(NSDictionary *)json
{
    if ( ![json isKindOfClass:[NSDictionary class]] )
        return nil;
    
    return [[self alloc] initMutableWithJson:json];
}


-(id)mutate:(void (^)(id mutable))mutationBlock
{
    NTJsonModel *mutable = [self mutableCopy];
    
    mutationBlock(mutable);
    
    return [mutable copy];
}


#pragma mark - Array Helpers


+(NSArray *)arrayWithJsonArray:(NSArray *)jsonArray
{
    if ( ![jsonArray isKindOfClass:[NSArray class]] )
        return nil;
    
    return [[NTJsonModelArray alloc] initWithModelClass:self json:jsonArray];
}


+(NSMutableArray *)mutableArrayWithJsonArray:(NSArray *)jsonArray
{
    if ( ![jsonArray isKindOfClass:[NSArray class]] )
        return nil;

    NSMutableArray *array = [NSMutableArray arrayWithCapacity:jsonArray.count];
    
    for(NSDictionary *json in jsonArray)
        [array addObject:[[self alloc] initMutableWithJson:json]];
    
    return array;
}


#pragma mark - Properties


+(BOOL)modelClassForJsonOverridden
{
    return [self __ntJsonModelSupport].modelClassForJsonOverridden;
}


+(NSDictionary *)defaultJson
{
    return [self __ntJsonModelSupport].defaultJson;
}


-(id)__json
{
    return _json;
}


-(NSDictionary *)asJson
{
    return [_json copy];
}


#pragma mark - NSCopying & NSMutableCopying


-(id)mutableCopyWithZone:(NSZone *)zone
{
    return [[self.class alloc] initMutableWithJson:[self asJson]];
}


-(id)copyWithZone:(NSZone *)zone
{
    if ( !self.isMutable )
        return self;
    
    return [[self.class alloc] initWithJson:[self asJson]];
}


#pragma mark - Equality & hash


-(BOOL)isEqualToModel:(NTJsonModel *)model
{
    if ( model == self )
        return YES;
    
    return [self->_json isEqualToDictionary:model->_json];
}


-(BOOL)isEqual:(id)object
{
    if ( object == self )
        return YES;
    
    if ( ![object isKindOfClass:self.class] )  // or do we compare to self.class?
        return NO;
    
    return [self isEqualToModel:object];
}


-(NSUInteger)hash
{
    return [_json hash];  // NSDictionary hash sucks, maybe we should try a little harder here?
}


#pragma mark - description


-(NSString *)description
{
    return [[self.class __ntJsonModelSupport] descriptionForModel:self fullDescription:NO parentModels:@[]];
}


-(NSString *)fullDescription
{
    return [[self.class __ntJsonModelSupport] descriptionForModel:self fullDescription:YES parentModels:@[]];
}


@end


@implementation NTJsonModel (Mutable)

// we need to implement the category to make sure the compiler actually generates the meta data for NTJsonMutableModel

@end



