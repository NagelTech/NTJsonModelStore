//
//  NTJsonModelCollection.m
//  NTJsonModelStoreTests
//
//  Created by Ethan Nagel on 7/9/14.
//
//

#import "NTJsonModelStore+Private.h"


@interface NTJsonModelCollection ()
{
    NTJsonCollection __weak *_collection;
    Class _modelClass;
    NSMutableDictionary *_modelInfo;
}

@property (nonatomic,readonly) NSMutableDictionary *modelInfo;

-(void)saveModelInfo;

@end


@implementation NTJsonModelCollection


-(NSString *)modelInfoKey
{
    return [NSString stringWithFormat:@"%@/modelInfo", _collection.name];
}


-(NSMutableDictionary *)modelInfo
{
    if ( !_modelInfo )
        _modelInfo = [[_collection.store metadataWithKey:[self modelInfoKey]] mutableCopy] ?: [NSMutableDictionary dictionary];
    
    return _modelInfo;
}


-(void)saveModelInfo
{
    [_collection.store saveMetadataWithKey:[self modelInfoKey] value:_modelInfo];
}


-(void)setModelClass:(Class)modelClass
{
    if ( self.modelClass == modelClass )
        return ;
    
    if ( modelClass && ![modelClass isSubclassOfClass:[NTJsonModel class]] )
        @throw [NSException exceptionWithName:@"InvalidModelClass" reason:@"Invalid Model Class" userInfo:nil];
    
    _modelClass = modelClass;
    
    self.modelInfo[@"modelClass"] = NSStringFromClass(_modelClass);
    [self saveModelInfo];
    
    _collection.defaultJson = [_modelClass defaultJson];
}


-(Class)modelClass
{
    if ( !_modelClass )
    {
        Class modelClass = NSClassFromString(self.modelInfo[@"modelClass"]);
        
        _modelClass = modelClass ?: [NSNull class];
    }
    
    return (_modelClass == [NSNull class]) ? nil : _modelClass;
}


-(instancetype)initWithCollection:(NTJsonCollection *)collection
{
    self = [super init];
    
    if ( self )
    {
        _collection = collection;
        
        if ( self.modelClass )
            _collection.defaultJson = [_modelClass defaultJson];
    }
    
    return self;
}


-(void)applyConfig:(NSDictionary *)config
{
    NSString *modelClass = config[@"modelClass"];
    
    if ( [modelClass isKindOfClass:[NSString class]] )
        self.modelClass = NSClassFromString(modelClass);
    
    [_collection applyConfig:config];
}


-(BOOL)applyConfigFile:(NSString *)filename
{
    NSDictionary *config = [NTJsonStore loadConfigFile:filename];
    
    if ( !config )
        return NO;
    
    [self applyConfig:config];
    
    return YES;
}


-(NSString *)name
{
    return _collection.name;
}


-(NTJsonModelStore *)store
{
    return _collection.store.modelStore;
}


-(NSError *)lastError
{
    return _collection.lastError;
}



-(int)cacheSize
{
    return _collection.cacheSize;
}


-(void)setCacheSize:(int)cacheSize
{
    [_collection setCacheSize:cacheSize];
}


-(void)addIndexWithKeys:(NSString *)keys
{
    [_collection addIndexWithKeys:keys];
}


-(void)addUniqueIndexWithKeys:(NSString *)keys
{
    [_collection addUniqueIndexWithKeys:keys];
}


-(void)addQueryableFields:(NSString *)fields
{
    [_collection addQueryableFields:fields];
}


-(void)flushCache
{
    [_collection flushCache];
}


-(void)beginEnsureSchemaWithCompletionQueue:(dispatch_queue_t)completionQueue completionHandler:(void (^)(NSError *error))completionHandler
{
    [_collection beginEnsureSchemaWithCompletionQueue:completionQueue completionHandler:completionHandler];
}


-(void)beginEnsureSchemaWithCompletionHandler:(void (^)(NSError *error))completionHandler
{
    [_collection beginEnsureSchemaWithCompletionHandler:completionHandler];
}


-(BOOL)ensureSchemaWithError:(NSError **)error
{
    return [_collection ensureSchemaWithError:error];
}


-(BOOL)ensureSchema
{
    return [_collection ensureSchema];
}


-(void)beginInsert:(id<NTJsonStorableModel>)model completionQueue:(dispatch_queue_t)completionQueue completionHandler:(void (^)(NTJsonRowId rowid, NSError *error))completionHandler
{
    [_collection beginInsert:[model asJson] completionQueue:completionQueue completionHandler:completionHandler];
}


-(void)beginInsert:(id<NTJsonStorableModel>)model completionHandler:(void (^)(NTJsonRowId rowid, NSError *error))completionHandler
{
    [_collection beginInsert:[model asJson] completionHandler:completionHandler];
}


-(NTJsonRowId)insert:(id<NTJsonStorableModel>)model error:(NSError **)error
{
    return [_collection insert:[model asJson] error:error];
}


-(NTJsonRowId)insert:(id<NTJsonStorableModel>)model
{
    return [_collection insert:[model asJson]];
}


-(void)beginInsertBatch:(NSArray *)models completionQueue:(dispatch_queue_t)completionQueue completionHandler:(void (^)(NSError *error))completionHandler
{
    [_collection beginInsertBatch:[models asJson] completionQueue:completionQueue completionHandler:completionHandler];
}


-(void)beginInsertBatch:(NSArray *)models completionHandler:(void (^)(NSError *error))completionHandler
{
    [_collection beginInsertBatch:[models asJson] completionHandler:completionHandler];
}


-(BOOL)insertBatch:(NSArray *)models error:(NSError **)error
{
    return [_collection insertBatch:[models asJson] error:error];
}


-(BOOL)insertBatch:(NSArray *)models
{
    return [_collection insertBatch:[models asJson]];
}


-(void)beginUpdate:(id<NTJsonStorableModel>)model completionQueue:(dispatch_queue_t)completionQueue completionHandler:(void (^)(NSError *error))completionHandler
{
    [_collection beginUpdate:[model asJson] completionQueue:completionQueue completionHandler:completionHandler];
}


-(void)beginUpdate:(id<NTJsonStorableModel>)model completionHandler:(void (^)(NSError *error))completionHandler
{
    [_collection beginUpdate:[model asJson] completionHandler:completionHandler];
}


-(BOOL)update:(id<NTJsonStorableModel>)model error:(NSError **)error
{
    return [_collection update:[model asJson] error:error];
}


-(BOOL)update:(id<NTJsonStorableModel>)model
{
    return [_collection update:[model asJson]];
}


-(void)beginRemove:(id<NTJsonStorableModel>)model completionQueue:(dispatch_queue_t)completionQueue completionHandler:(void (^)(NSError *error))completionHandler
{
    [_collection beginRemove:[model asJson] completionQueue:completionQueue completionHandler:completionHandler];
}


-(void)beginRemove:(id<NTJsonStorableModel>)model completionHandler:(void (^)(NSError *error))completionHandler
{
    [_collection beginRemove:[model asJson] completionHandler:completionHandler];
}


-(BOOL)remove:(id<NTJsonStorableModel>)model error:(NSError **)error
{
    return [_collection remove:[model asJson] error:error];
}


-(BOOL)remove:(id<NTJsonStorableModel>)model
{
    return [_collection remove:[model asJson]];
}


-(void)beginCountWhere:(NSString *)where args:(NSArray *)args completionQueue:(dispatch_queue_t)completionQueue completionHandler:(void (^)(int count, NSError *error))completionHandler
{
    [_collection beginCountWhere:where args:args completionQueue:completionQueue completionHandler:completionHandler];
}


-(void)beginCountWhere:(NSString *)where args:(NSArray *)args completionHandler:(void (^)(int count, NSError *error))completionHandler
{
    [_collection beginCountWhere:where args:args completionHandler:completionHandler];
}


-(int)countWhere:(NSString *)where args:(NSArray *)args
{
    return [_collection countWhere:where args:args];
}


-(int)countWhere:(NSString *)where args:(NSArray *)args error:(NSError **)error
{
    return [_collection countWhere:where args:args error:error];
}


-(void)beginCountWithCompletionQueue:(dispatch_queue_t)completionQueue completionHandler:(void (^)(int count, NSError *error))completionHandler
{
    [_collection beginCountWithCompletionQueue:completionQueue completionHandler:completionHandler];
}


-(void)beginCountWithCompletionHandler:(void (^)(int count, NSError *error))completionHandler
{
    [_collection beginCountWithCompletionHandler:completionHandler];
}


-(int)countWithError:(NSError **)error
{
    return [_collection countWithError:error];
}


-(int)count
{
    return [_collection count];
}


-(void)beginFindWhere:(NSString *)where args:(NSArray *)args orderBy:(NSString *)orderBy limit:(int)limit completionQueue:(dispatch_queue_t)completionQueue completionHandler:(void (^)(NSArray *models, NSError *error))completionHandler
{
    [_collection beginFindWhere:where args:args orderBy:orderBy limit:limit completionQueue:completionQueue completionHandler:^(NSArray *items, NSError *error)
    {
        completionHandler([self.modelClass arrayWithJsonArray:items], error);
    }];
}


-(void)beginFindWhere:(NSString *)where args:(NSArray *)args orderBy:(NSString *)orderBy limit:(int)limit completionHandler:(void (^)(NSArray *models, NSError *error))completionHandler
{
    [_collection beginFindWhere:where args:args orderBy:orderBy limit:limit completionHandler:^(NSArray *items, NSError *error)
    {
        completionHandler([self.modelClass arrayWithJsonArray:items], error);
    }];
}


-(NSArray *)findWhere:(NSString *)where args:(NSArray *)args orderBy:(NSString *)orderBy limit:(int)limit error:(NSError **)error
{
    return [self.modelClass arrayWithJsonArray:[_collection findWhere:where args:args orderBy:orderBy limit:limit error:error]];
}


-(NSArray *)findWhere:(NSString *)where args:(NSArray *)args orderBy:(NSString *)orderBy limit:(int)limit
{
    return [self.modelClass arrayWithJsonArray:[_collection findWhere:where args:args orderBy:orderBy limit:limit]];
}


-(void)beginFindWhere:(NSString *)where args:(NSArray *)args orderBy:(NSString *)orderBy completionQueue:(dispatch_queue_t)completionQueue completionHandler:(void (^)(NSArray *models, NSError *error))completionHandler
{
    [_collection beginFindWhere:where args:args orderBy:orderBy completionQueue:completionQueue completionHandler:^(NSArray *items, NSError *error)
     {
         completionHandler([self.modelClass arrayWithJsonArray:items], error);
     }];
}


-(void)beginFindWhere:(NSString *)where args:(NSArray *)args orderBy:(NSString *)orderBy completionHandler:(void (^)(NSArray *models, NSError *error))completionHandler
{
    [_collection beginFindWhere:where args:args orderBy:orderBy completionHandler:^(NSArray *items, NSError *error)
     {
         completionHandler([self.modelClass arrayWithJsonArray:items], error);
     }];
}


-(NSArray *)findWhere:(NSString *)where args:(NSArray *)args orderBy:(NSString *)orderBy error:(NSError **)error
{
    return [self.modelClass arrayWithJsonArray:[_collection findWhere:where args:args orderBy:orderBy error:error]];
}


-(NSArray *)findWhere:(NSString *)where args:(NSArray *)args orderBy:(NSString *)orderBy
{
    return [self.modelClass arrayWithJsonArray:[_collection findWhere:where args:args orderBy:orderBy]];
}


-(void)beginFindOneWhere:(NSString *)where args:(NSArray *)args completionQueue:(dispatch_queue_t)completionQueue completionHandler:(void (^)(id<NTJsonStorableModel>model, NSError *error))completionHandler
{
    [_collection beginFindOneWhere:where args:args completionQueue:completionQueue completionHandler:^(NSDictionary *item, NSError *error)
    {
        completionHandler([self.modelClass modelWithJson:item], error);
    }];
}


-(void)beginFindOneWhere:(NSString *)where args:(NSArray *)args completionHandler:(void (^)(id<NTJsonStorableModel>model, NSError *error))completionHandler
{
    [_collection beginFindOneWhere:where args:args completionHandler:^(NSDictionary *item, NSError *error)
    {
        completionHandler([self.modelClass modelWithJson:item], error);
    }];
}


-(id)findOneWhere:(NSString *)where args:(NSArray *)args error:(NSError **)error
{
    return [self.modelClass modelWithJson:[_collection findOneWhere:where args:args error:error]];
}


-(id)findOneWhere:(NSString *)where args:(NSArray *)args
{
    return [self.modelClass modelWithJson:[_collection findOneWhere:where args:args]];
}

-(void)beginRemoveWhere:(NSString *)where args:(NSArray *)args completionQueue:(dispatch_queue_t)completionQueue completionHandler:(void (^)(int count, NSError *error))completionHandler
{
    [_collection beginRemoveWhere:where args:args completionQueue:completionQueue completionHandler:completionHandler];
}


-(void)beginRemoveWhere:(NSString *)where args:(NSArray *)args completionHandler:(void (^)(int count, NSError *error))completionHandler
{
    [_collection beginRemoveWhere:where args:args completionHandler:completionHandler];
}


-(int)removeWhere:(NSString *)where args:(NSArray *)args error:(NSError **)error
{
    return [_collection removeWhere:where args:args error:error];
}


-(int)removeWhere:(NSString *)where args:(NSArray *)args
{
    return [_collection removeWhere:where args:args];
}


-(void)beginRemoveAllWithCompletionQueue:(dispatch_queue_t)completionQueue completionHandler:(void (^)(int count, NSError *error))completionHandler
{
    [_collection beginRemoveAllWithCompletionQueue:completionQueue completionHandler:completionHandler];
}


-(void)beginRemoveAllWithCompletionHandler:(void (^)(int count, NSError *error))completionHandler
{
    [_collection beginRemoveAllWithCompletionHandler:completionHandler];
}


-(int)removeAllWithError:(NSError **)error
{
    return [_collection removeAllWithError:error];
}


-(int)removeAll
{
    return [_collection removeAll];
}


-(void)beginSyncWithCompletionQueue:(dispatch_queue_t)completionQueue completionHandler:(void (^)())completionHandler
{
    [_collection beginSyncWithCompletionQueue:completionQueue completionHandler:completionHandler];
}


-(void)beginSyncWithCompletionHandler:(void (^)())completionHandler
{
    [_collection beginSyncWithCompletionHandler:completionHandler];
}


-(BOOL)syncWait:(dispatch_time_t)duration
{
    return [_collection syncWait:duration];
}


-(void)sync
{
    [_collection sync];
}


-(NSString *)description
{
    return [_collection description];
}


@end
