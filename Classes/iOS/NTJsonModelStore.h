//
//  NTJsonModelStore.h
//  NTJsonModelStoreTests
//
//  Created by Ethan Nagel on 7/9/14.
//
//

#import <Foundation/Foundation.h>

#import "NTJsonStoreTypes.h"
#import "NTJsonModelCollection.h"
#import "NTJsonModel+NTJsonModelStore.h"


@class NTJsonStore;


@interface NTJsonModelStore : NSObject

+(instancetype)defaultModelStore;

@property (nonatomic,readonly)      NTJsonStore *store;

@property (nonatomic,readonly)      NSString *storePath;
@property (nonatomic,readonly)      NSString *storeName;

@property (nonatomic,readonly)      NSString *storeFilename;
@property (nonatomic,readonly)      BOOL exists;

@property (nonatomic,readonly)      NSArray *collections;

-(id)init;
-(id)initWithName:(NSString *)storeName;
-(id)initWithPath:(NSString *)storePath name:(NSString *)storeName;

-(void)applyConfig:(NSDictionary *)config;
-(BOOL)applyConfigFile:(NSString *)filename;

-(void)close;

-(NTJsonModelCollection *)collectionWithName:(NSString *)collectionName;

-(void)beginEnsureSchemaWithCompletionQueue:(dispatch_queue_t)completionQueue completionHandler:(void (^)(NSArray *errors))completionHandler;
-(void)beginEnsureSchemaWithCompletionHandler:(void (^)(NSArray *errors))completionHandler;
-(NSArray *)ensureSchema;

-(void)beginSyncModelCollections:(NSArray *)modelCollections withCompletionQueue:(dispatch_queue_t)completionQueue completionHandler:(void (^)())completionHandler;
-(void)beginSyncWithCompletionQueue:(dispatch_queue_t)completionQueue completionHandler:(void (^)())completionHandler;
-(void)beginSyncWithCompletionHandler:(void (^)())completionHandler;
-(void)syncModelCollections:(NSArray *)modelCollections wait:(dispatch_time_t)timeout;
-(void)syncWait:(dispatch_time_t)timeout;
-(void)sync;


@end


