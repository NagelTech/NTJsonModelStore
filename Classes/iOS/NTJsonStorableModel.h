//
//  NTJsonStorableModel.h
//  NTJsonModelStoreTests
//
//  Created by Ethan Nagel on 7/9/14.
//
//

#import "NTJsonModel.h"


@protocol NTJsonStorableModel <NTJsonModel>

@property (nonatomic,readonly) NTJsonRowId rowid;
@property (nonatomic,readonly) BOOL isJsonCurrent;

@end

@protocol NTJsonMutableStorableModel <NTJsonStorableModel>

@property (nonatomic) NTJsonRowId rowid;

@end

@interface NTJsonStorableModel : NTJsonModel<NTJsonStorableModel>

+(NTJsonModelStore *)defaultModelStore;
+(NSString *)defaultModelCollectionName;
+(NTJsonModelCollection *)defaultModelCollection;

+(void)addIndexWithKeys:(NSString *)keys;
+(void)addUniqueIndexWithKeys:(NSString *)keys;
+(void)addQueryableFields:(NSString *)fields;

+(NSError *)lastError;

+(void)flushCache;

+(void)beginEnsureSchemaWithCompletionHandler:(void (^)(NSError *error))completionHandler;
+(BOOL)ensureSchemaWithError:(NSError **)error;
+(BOOL)ensureSchema;

-(void)beginInsertWithCompletionHandler:(void (^)(NTJsonRowId rowid, NSError *error))completionHandler;
-(NTJsonRowId)insertWithError:(NSError **)error;
-(NTJsonRowId)insert;

+(void)beginInsertBatch:(NSArray *)models completionHandler:(void (^)(NSError *error))completionHandler;
+(BOOL)insertBatch:(NSArray *)models error:(NSError **)error;
+(BOOL)insertBatch:(NSArray *)models;

-(void)beginUpdateWithCompletionHandler:(void (^)(NSError *error))completionHandler;
-(BOOL)updateWithError:(NSError **)error;
-(BOOL)update;

-(void)beginRemoveWithCompletionHandler:(void (^)(NSError *error))completionHandler;
-(BOOL)removeWithError:(NSError **)error;
-(BOOL)remove;

+(void)beginCountWhere:(NSString *)where args:(NSArray *)args completionHandler:(void (^)(int count, NSError *error))completionHandler;
+(int)countWhere:(NSString *)where args:(NSArray *)args;
+(int)countWhere:(NSString *)where args:(NSArray *)args error:(NSError **)error;

+(void)beginCountWithCompletionHandler:(void (^)(int count, NSError *error))completionHandler;
+(int)countWithError:(NSError **)error;
+(int)count;

+(void)beginFindWhere:(NSString *)where args:(NSArray *)args orderBy:(NSString *)orderBy limit:(int)limit completionHandler:(void (^)(NSArray *models, NSError *error))completionHandler;
+(NSArray *)findWhere:(NSString *)where args:(NSArray *)args orderBy:(NSString *)orderBy limit:(int)limit error:(NSError **)error;
+(NSArray *)findWhere:(NSString *)where args:(NSArray *)args orderBy:(NSString *)orderBy limit:(int)limit;

+(void)beginFindWhere:(NSString *)where args:(NSArray *)args orderBy:(NSString *)orderBy completionHandler:(void (^)(NSArray *models, NSError *error))completionHandler;
+(NSArray *)findWhere:(NSString *)where args:(NSArray *)args orderBy:(NSString *)orderBy error:(NSError **)error;
+(NSArray *)findWhere:(NSString *)where args:(NSArray *)args orderBy:(NSString *)orderBy;

+(void)beginFindOneWhere:(NSString *)where args:(NSArray *)args completionHandler:(void (^)(id<NTJsonStorableModel> model, NSError *error))completionHandler;
+(instancetype)findOneWhere:(NSString *)where args:(NSArray *)args error:(NSError **)error;
+(instancetype)findOneWhere:(NSString *)where args:(NSArray *)args;

+(void)beginRemoveWhere:(NSString *)where args:(NSArray *)args completionHandler:(void (^)(int count, NSError *error))completionHandler;
+(int)removeWhere:(NSString *)where args:(NSArray *)args error:(NSError **)error;
+(int)removeWhere:(NSString *)where args:(NSArray *)args;

+(void)beginRemoveAllWithCompletionHandler:(void (^)(int count, NSError *error))completionHandler;
+(int)removeAllWithError:(NSError **)error;
+(int)removeAll;

+(void)beginSyncWithCompletionHandler:(void (^)())completionHandler;
+(BOOL)syncWait:(dispatch_time_t)duration;
+(void)sync;


@end
