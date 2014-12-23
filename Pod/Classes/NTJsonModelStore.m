//
//  NTJsonModelStore.m
//  NTJsonModelStoreTests
//
//  Created by Ethan Nagel on 7/9/14.
//
//

#import "NTJsonModelStore+Private.h"


@interface NTJsonModelStore ()
{
    NTJsonStore *_store;
}

@end


@implementation NTJsonModelStore


+(instancetype)defaultModelStore
{
    static NTJsonModelStore *defaultModelStore = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultModelStore = [[NTJsonModelStore alloc] init];
        
        // Load a default configuration, if it exists
        
        [defaultModelStore applyConfigFile:@"NTJsonModelStore.config"];
    });
    
    return defaultModelStore;
}


-(id)initWithPath:(NSString *)storePath name:(NSString *)storeName
{
    self = [super init];
    
    if ( self )
    {
        _store = [[NTJsonStore alloc] initWithPath:storePath name:storeName];
        _store.modelStore = self;
    }
    
    return self;
}


-(id)initWithName:(NSString *)storeName
{
    self = [super init];
    
    if ( self )
    {
        _store = [[NTJsonStore alloc] initWithName:storeName];
        _store.modelStore = self;
    }
    
    return self;
}


-(id)init
{
    self = [super init];
    
    if ( self )
    {
        _store = [[NTJsonStore alloc] init];
        _store.modelStore = self;
    }
    
    return self;
}


-(void)applyConfig:(NSDictionary *)config
{
    // Apply the store's configuration, less any collections - we do the collections special...
    
    NSMutableDictionary *tempConfig = [config mutableCopy];
    
    [tempConfig removeObjectForKey:@"collections"]; // if it exists
    
    [_store applyConfig:tempConfig];
    
    NSDictionary *collections = config[@"collections"];
    
    if ( [collections isKindOfClass:[NSDictionary class]] )
    {
        for(NSString *collectionName in collections.allKeys)
        {
            NSDictionary *collectionConfig = collections[collectionName];
            
            if ( [collectionConfig isKindOfClass:[NSDictionary class]] )
            {
                NTJsonModelCollection *collection = [self collectionWithName:collectionName];
                
                [collection applyConfig:collectionConfig];
            }
        }
    }
}


-(BOOL)applyConfigFile:(NSString *)filename
{
    NSDictionary *config = [NTJsonStore loadConfigFile:filename];
    
    if ( !config )
        return NO;
    
    [self applyConfig:config];
    
    return YES;
}

-(NSString *)storePath
{
    return _store.storePath;
}


-(NSString *)storeName
{
    return _store.storeName;
}


-(NSString *)storeFilename
{
    return _store.storeFilename;
}


-(BOOL)exists
{
    return _store.exists;
}


-(void)close
{
    [_store close];
}


-(NSArray *)collectionsFromModelCollections:(NSArray *)modelCollections
{
    if ( !modelCollections )
        return nil;
    
    NSMutableArray *collections = [NSMutableArray arrayWithCapacity:modelCollections.count];
    
    for (NTJsonModelCollection *modelCollection in modelCollections)
    {
        [collections addObject:modelCollection.collection];
    }
    
    return [collections copy];
}


-(NSArray *)modelCollectionsFromCollections:(NSArray *)collections
{
    if ( !collections )
        return nil;
    
    NSMutableArray *modelCollections = [NSMutableArray arrayWithCapacity:collections.count];
    
    for (NTJsonCollection *collection in collections)
    {
        [modelCollections addObject:collection.modelCollection];
    }
    
    return [modelCollections copy];
}


-(NSArray *)collections
{
    return [self modelCollectionsFromCollections:_store.collections];
}


-(NTJsonModelCollection *)collectionWithName:(NSString *)collectionName
{
    return [_store collectionWithName:collectionName].modelCollection;
}


-(void)beginEnsureSchemaWithCompletionQueue:(dispatch_queue_t)completionQueue completionHandler:(void (^)(NSArray *errors))completionHandler
{
    [_store beginEnsureSchemaWithCompletionQueue:completionQueue completionHandler:completionHandler];
}


-(void)beginEnsureSchemaWithCompletionHandler:(void (^)(NSArray *errors))completionHandler
{
    [_store beginEnsureSchemaWithCompletionHandler:completionHandler];
}


-(NSArray *)ensureSchema
{
    return [_store ensureSchema];
}


-(void)beginSyncModelCollections:(NSArray *)modelCollections withCompletionQueue:(dispatch_queue_t)completionQueue completionHandler:(void (^)())completionHandler
{
    [_store beginSyncCollections:[self collectionsFromModelCollections:modelCollections] withCompletionQueue:completionQueue completionHandler:completionHandler];
}


-(void)beginSyncWithCompletionQueue:(dispatch_queue_t)completionQueue completionHandler:(void (^)())completionHandler
{
    [_store beginSyncWithCompletionQueue:completionQueue completionHandler:completionHandler];
}


-(void)beginSyncWithCompletionHandler:(void (^)())completionHandler
{
    [_store beginSyncWithCompletionHandler:completionHandler];
}


-(void)syncModelCollections:(NSArray *)modelCollections wait:(dispatch_time_t)timeout
{
    [_store syncCollections:[self collectionsFromModelCollections:modelCollections] wait:timeout];
}


-(void)syncWait:(dispatch_time_t)timeout
{
    [_store syncWait:timeout];
}


-(void)sync
{
    [_store sync];
}


@end

