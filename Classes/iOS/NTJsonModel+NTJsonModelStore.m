//
//  NTJsonModel+NTJsonModelStore.m
//  NTJsonModelStoreTests
//
//  Created by Ethan Nagel on 7/9/14.
//
//

#import <objc/runtime.h>

#import "NTJsonModelStore.h"


@interface NTJsonModel (NTJsonModel_Stolen)

+(BOOL)modelClassForJsonOverridden; // this should be published somehow in NTJsonModel.h/c, for now we are stealing it

@end


@implementation NTJsonModel (NTJsonModelStore)


NTJsonProperty(rowid, jsonPath="__rowid__")


+(NTJsonModelStore *)defaultModelStore
{
    return [NTJsonModelStore defaultModelStore];
}


+(NSString *)defaultModelCollectionName
{
    return NSStringFromClass(self);
}


+(NTJsonModelCollection *)defaultModelCollection
{
    NTJsonModelCollection *defaultModelCollection = objc_getAssociatedObject(self, @selector(defaultModelCollection));

    if ( !defaultModelCollection )
    {
        // See if we have a polymorphic base class...
        
        Class baseClass = nil;
        
        for(Class c=[self superclass]; c && c != [NTJsonModel class]; c = [c superclass])
        {
            if ( [c modelClassForJsonOverridden] )
            {
                baseClass = c;
                break;
            }
        }
        
        if ( baseClass )    // if we have a polymorph, use it's modelCollection
        {
            defaultModelCollection = [baseClass defaultModelCollection];
        }
        
        else // normal case, just create a collection using the default name.
        {
            defaultModelCollection = [[self defaultModelStore] collectionWithName:[self defaultModelCollectionName]];
            defaultModelCollection.modelClass = self;
        }
        
        objc_setAssociatedObject(self, @selector(defaultModelCollection), defaultModelCollection, OBJC_ASSOCIATION_RETAIN);
    }
    
    return defaultModelCollection;
}


+(void)addIndexWithKeys:(NSString *)keys
{
    [[self defaultModelCollection] addIndexWithKeys:keys];
}


+(void)addUniqueIndexWithKeys:(NSString *)keys
{
    [[self defaultModelCollection] addUniqueIndexWithKeys:keys];
}


+(void)addQueryableFields:(NSString *)fields
{
    [[self defaultModelCollection] addQueryableFields:fields];
}


+(NSError *)lastError
{
    return [[self defaultModelCollection] lastError];
}


+(void)flushCache
{
    [[self defaultModelCollection] flushCache];
}


+(void)beginEnsureSchemaWithCompletionHandler:(void (^)(NSError *))completionHandler
{
    [[self defaultModelCollection] beginEnsureSchemaWithCompletionHandler:completionHandler];
}


+(BOOL)ensureSchemaWithError:(NSError *__autoreleasing *)error
{
    return [[self defaultModelCollection] ensureSchemaWithError:error];
}


+(BOOL)ensureSchema
{
    return [[self defaultModelCollection] ensureSchema];
}


-(void)beginInsertWithCompletionHandler:(void (^)(NTJsonRowId rowid, NSError *error))completionHandler
{
    [[self.class defaultModelCollection] beginInsert:self completionHandler:completionHandler];
}


-(NTJsonRowId)insertWithError:(NSError **)error
{
    return [[self.class defaultModelCollection] insert:self error:error];
}


-(NTJsonRowId)insert
{
    return [[self.class defaultModelCollection] insert:self];
}


+(void)beginInsertBatch:(NSArray *)models completionHandler:(void (^)(NSError *error))completionHandler
{
    [[self defaultModelCollection] beginInsertBatch:models completionHandler:completionHandler];
}


+(BOOL)insertBatch:(NSArray *)models error:(NSError **)error
{
    return [[self defaultModelCollection] insertBatch:models error:error];
}


+(BOOL)insertBatch:(NSArray *)models
{
    return [[self defaultModelCollection] insertBatch:models];
}


-(void)beginUpdateWithCompletionHandler:(void (^)(NSError *error))completionHandler
{
    [[self.class defaultModelCollection] beginUpdate:self completionHandler:completionHandler];
}


-(BOOL)updateWithError:(NSError **)error
{
    return [[self.class defaultModelCollection] update:self error:error];
}


-(BOOL)update
{
    return [[self.class defaultModelCollection] update:self];
}


-(void)beginRemoveWithCompletionHandler:(void (^)(NSError *error))completionHandler
{
    [[self.class defaultModelCollection] beginRemove:self completionHandler:completionHandler];
}


-(BOOL)removeWithError:(NSError **)error
{
    return [[self.class defaultModelCollection] remove:self error:error];
}


-(BOOL)remove
{
    return [[self.class defaultModelCollection] remove:self];
}


+(void)beginCountWhere:(NSString *)where args:(NSArray *)args completionHandler:(void (^)(int count, NSError *error))completionHandler
{
    [[self defaultModelCollection] beginCountWhere:where args:args completionHandler:completionHandler];
}


+(int)countWhere:(NSString *)where args:(NSArray *)args
{
    return [[self.class defaultModelCollection] countWhere:where args:args];
}


+(int)countWhere:(NSString *)where args:(NSArray *)args error:(NSError **)error
{
    return [[self.class defaultModelCollection] countWhere:where args:args error:error];
}


+(void)beginCountWithCompletionHandler:(void (^)(int count, NSError *error))completionHandler
{
    [[self.class defaultModelCollection] beginCountWithCompletionHandler:completionHandler];
}


+(int)countWithError:(NSError **)error
{
    return [[self.class defaultModelCollection] countWithError:error];
}


+(int)count
{
    return [[self.class defaultModelCollection] count];
}


+(void)beginFindWhere:(NSString *)where args:(NSArray *)args orderBy:(NSString *)orderBy limit:(int)limit completionHandler:(void (^)(NSArray *models, NSError *error))completionHandler
{
    [[self defaultModelCollection] beginFindWhere:where args:args orderBy:orderBy limit:limit completionHandler:completionHandler];
}


+(NSArray *)findWhere:(NSString *)where args:(NSArray *)args orderBy:(NSString *)orderBy limit:(int)limit error:(NSError **)error
{
    return [[self defaultModelCollection]findWhere:where args:args orderBy:orderBy limit:limit error:error];
}


+(NSArray *)findWhere:(NSString *)where args:(NSArray *)args orderBy:(NSString *)orderBy limit:(int)limit
{
    return [[self defaultModelCollection] findWhere:where args:args orderBy:orderBy limit:limit];
}


+(void)beginFindWhere:(NSString *)where args:(NSArray *)args orderBy:(NSString *)orderBy completionHandler:(void (^)(NSArray *models, NSError *error))completionHandler
{
    [[self defaultModelCollection] beginFindWhere:where args:args orderBy:orderBy completionHandler:completionHandler];
}


+(NSArray *)findWhere:(NSString *)where args:(NSArray *)args orderBy:(NSString *)orderBy error:(NSError **)error
{
    return [[self defaultModelCollection] findWhere:where args:args orderBy:orderBy error:error];
}


+(NSArray *)findWhere:(NSString *)where args:(NSArray *)args orderBy:(NSString *)orderBy
{
    return [[self defaultModelCollection] findWhere:where args:args orderBy:orderBy];
}


+(void)beginFindOneWhere:(NSString *)where args:(NSArray *)args completionHandler:(void (^)(NTJsonModel *model, NSError *error))completionHandler
{
    [[self defaultModelCollection] beginFindOneWhere:where args:args completionHandler:completionHandler];
}


+(instancetype)findOneWhere:(NSString *)where args:(NSArray *)args error:(NSError **)error
{
    return [[self defaultModelCollection] findOneWhere:where args:args error:error];
}


+(instancetype)findOneWhere:(NSString *)where args:(NSArray *)args
{
    return [[self defaultModelCollection] findOneWhere:where args:args];
}


+(void)beginRemoveWhere:(NSString *)where args:(NSArray *)args completionHandler:(void (^)(int count, NSError *error))completionHandler
{
    [[self defaultModelCollection] beginRemoveWhere:where args:args completionHandler:completionHandler];
}


+(int)removeWhere:(NSString *)where args:(NSArray *)args error:(NSError **)error
{
    return [[self defaultModelCollection] removeWhere:where args:args error:error];
}


+(int)removeWhere:(NSString *)where args:(NSArray *)args
{
    return [[self defaultModelCollection] removeWhere:where args:args];
}

+(void)beginRemoveAllWithCompletionHandler:(void (^)(int count, NSError *error))completionHandler
{
    [[self defaultModelCollection] beginRemoveAllWithCompletionHandler:completionHandler];
}


+(int)removeAllWithError:(NSError **)error
{
    return [[self defaultModelCollection] removeAllWithError:error];
}


+(int)removeAll
{
    return [[self defaultModelCollection] removeAll];
}


+(void)beginSyncWithCompletionHandler:(void (^)())completionHandler
{
    [[self defaultModelCollection] beginSyncWithCompletionHandler:completionHandler];
}


+(BOOL)syncWait:(dispatch_time_t)duration
{
    return [[self defaultModelCollection] syncWait:duration];
}


+(void)sync
{
    [[self defaultModelCollection] sync];
}


@end

