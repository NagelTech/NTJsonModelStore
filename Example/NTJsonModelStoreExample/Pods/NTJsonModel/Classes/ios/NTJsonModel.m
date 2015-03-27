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


@implementation NTJsonModel


#pragma mark - Class properties


+(__NTJsonModelSupport *)__ntJsonModelSupport
{
    __NTJsonModelSupport *support = objc_getAssociatedObject(self, @selector(__ntJsonModelSupport));

    if ( !support )
    {
        // Don't allow this to run more than once, even on multiple threads...

        @synchronized(self)
        {
           support = objc_getAssociatedObject(self, @selector(__ntJsonModelSupport));

            if ( !support )
            {
                support = [[__NTJsonModelSupport alloc] initWithModelClass:self];

                if ( !support ) // unlikely, but just in case...
                    @throw [NSException exceptionWithName:@"NTJsonPropertyError" reason:@"Unknown error initializing NTJsonModel class" userInfo:nil];

                objc_setAssociatedObject(self, @selector(__ntJsonModelSupport), support, OBJC_ASSOCIATION_RETAIN);
            }
        } // synchronized
    } // if

    return support;
}


+(Protocol *)__ntJsonModelMutableProtocol
{
    return @protocol(NTJsonMutableModel);
}


#pragma mark - resolveInstanceMethod


+(BOOL)resolveInstanceMethod:(SEL)sel
{
    // This ensures that we have been initialized and our property getters/setters have been implemented

    [self __ntJsonModelSupport];

    return [super resolveInstanceMethod:sel];
}


#pragma mark - Constructors


+(Class)modelClassForJson:(NSDictionary *)json
{
    return self;
}


-(id)init
{
    self = [super init];
    
    if ( self )
    {
        _json = @{};
        _isMutable = NO;
    }
    
    return self;
}


-(id)initWithJson:(NSDictionary *)json
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


-(id)initWithMutationBlock:(void (^)(id mutable))mutationBlock
{
    NTJsonModel *mutable = [self initMutable];
    
    if ( mutable )
        mutationBlock(mutable);
    
    return [mutable copy];
}


-(id)initMutable
{
    self = [super init];
    
    if ( self )
    {
        _json = [NSMutableDictionary dictionary];
        _isMutable = YES;
    }
    
    return self;
}


-(id)initMutableWithJson:(NSDictionary *)json
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


+(id)modelWithJson:(NSDictionary *)json
{
    if ( ![json isKindOfClass:[NSDictionary class]] )
        return nil;
    
    return [[self alloc] initWithJson:json];
}


+(id)modelWithMutationBlock:(void (^)(id mutable))mutationBlock
{
    return [[self alloc] initWithMutationBlock:mutationBlock];
}


+(id)mutableModelWithJson:(NSDictionary *)json
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


+(NSArray *)jsonPropertyMetadata
{
    return [self __ntJsonModelSupport].propertyMetadata;
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

    if ( !model )
        return NO;

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


#pragma mark - NSCoding


-(id)initWithCoder:(NSCoder *)aDecoder
{
    if ( (self=[super init]) )
    {
        _isMutable = [aDecoder decodeBoolForKey:@"isMutable"];
        _json = [aDecoder decodeObjectForKey:@"json"];
    }

    return self;
}


-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:_isMutable forKey:@"isMutable"];
    [aCoder encodeObject:_json forKey:@"json"];
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



