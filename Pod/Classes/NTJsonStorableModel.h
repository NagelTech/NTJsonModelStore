//
//  NTJsonStorableModel.h
//  NTJsonModelStoreTests
//
//  Created by Ethan Nagel on 7/9/14.
//
//

#import "NTJsonStoreTypes.h"
#import "NTJsonModel.h"
#import "NTJsonModelStore.h"


#define __NTJsonMetadata1(prefix, prop1) \
+(NSString *)__NTJsonMetadata__##prefix##_##prop1 { return @#prop1; } \
-(void)__NTJsonMetadata__##prefix##_##prop1 { typeof(self.prop1) v1 __attribute__((unused)); }

#define __NTJsonMetadata2(prefix, prop1,prop2) \
+(NSString *)__NTJsonMetadata__##prefix##_##prop1##_##prop2 { return @#prop1 ", " #prop2; } \
-(void)__NTJsonMetadata__##prefix##_##prop1##_##prop2 { typeof(self.prop1) v1 __attribute__((unused)); typeof(self.prop1) v2 __attribute__((unused)); }

#define __NTJsonMetadata3(prefix, prop1,prop2,prop3) \
+(NSString *)__NTJsonMetadata__##prefix##_##prop1##_##prop2##_##prop3 { return @#prop1 ", " #prop2 ", " #prop3; } \
-(void)__NTJsonMetadata__##prefix##_##prop1##_##prop2##_##prop3 { typeof(self.prop1) v1 __attribute__((unused)); typeof(self.prop2) v2 __attribute__((unused)); typeof(self.prop3) v3 __attribute__((unused)); }

#define __NTJsonMetadata4(prefix, prop1,prop2,prop3,prop4) \
+(NSString *)__NTJsonMetadata__##prefix##_##prop1##_##prop2##_##prop3##_##prop4 { return @#prop1 ", " #prop2 ", " #prop3 ", " #prop4; } \
-(void)__NTJsonMetadata__##prefix##_##prop1##_##prop2##_##prop3##_##prop4 { typeof(self.prop1) v1 __attribute__((unused)); typeof(self.prop2) v2 __attribute__((unused)); typeof(self.prop3) v3 __attribute__((unused)); typeof(self.prop4) v4 __attribute__((unused)); }

#define __NTJsonMetadata5(prefix, prop1,prop2,prop3,prop4,prop5) \
+(NSString *)__NTJsonMetadata__##prefix##_##prop1##_##prop2##_##prop3##_##prop4##_##prop5 { return @#prop1 ", " #prop2 ", " #prop3 ", " #prop4 ", " #prop5; } \
-(void)__NTJsonMetadata__##prefix##_##prop1##_##prop2##_##prop3##_##prop4##_##prop5 { typeof(self.prop1) v1 __attribute__((unused)); typeof(self.prop2) v2 __attribute__((unused)); typeof(self.prop3) v3 __attribute__((unused)); typeof(self.prop4) v4 __attribute__((unused)); typeof(self.prop5) v5 __attribute__((unused)); }

#define __NTJsonMetadata6(prefix, prop1,prop2,prop3,prop4,prop5,prop6) \
+(NSString *)__NTJsonMetadata__##prefix##_##prop1##_##prop2##_##prop3##_##prop4##_##prop5##_##prop6 { return @#prop1 ", " #prop2 ", " #prop3 ", " #prop4 ", " #prop5 ", " #prop6; } \
-(void)__NTJsonMetadata__##prefix##_##prop1##_##prop2##_##prop3##_##prop4##_##prop5##_##prop6 { typeof(self.prop1) v1 __attribute__((unused)); typeof(self.prop2) v2 __attribute__((unused)); typeof(self.prop3) v3 __attribute__((unused)); typeof(self.prop4) v4 __attribute__((unused)); typeof(self.prop5) v5 __attribute__((unused)); typeof(self.prop6) v6 __attribute__((unused)); }

#define __NTJsonMetadata7(prefix, prop1,prop2,prop3,prop4,prop5,prop6,prop7) \
+(NSString *)__NTJsonMetadata__##prefix##_##prop1##_##prop2##_##prop3##_##prop4##_##prop5##_##prop6##_##prop7 { return @#prop1 ", " #prop2 ", " #prop3 ", " #prop4 ", " #prop5 ", " #prop6 ", " #prop7; } \
-(void)__NTJsonMetadata__##prefix##_##prop1##_##prop2##_##prop3##_##prop4##_##prop5##_##prop6##_##prop7 { typeof(self.prop1) v1 __attribute__((unused)); typeof(self.prop2) v2 __attribute__((unused)); typeof(self.prop3) v3 __attribute__((unused)); typeof(self.prop4) v4 __attribute__((unused)); typeof(self.prop5) v5 __attribute__((unused)); typeof(self.prop6) v6 __attribute__((unused)); typeof(self.prop7) v7 __attribute__((unused)); }

#define __NTJsonMetadata8(prefix, prop1,prop2,prop3,prop4,prop5,prop6,prop7,prop8) \
+(NSString *)__NTJsonMetadata__##prefix##_##prop1##_##prop2##_##prop3##_##prop4##_##prop5##_##prop6##_##prop7##_##prop8 { return @#prop1 ", " #prop2 ", " #prop3 ", " #prop4 ", " #prop5 ", " #prop6 ", " #prop7 ", " #prop8; } \
-(void)__NTJsonMetadata__##prefix##_##prop1##_##prop2##_##prop3##_##prop4##_##prop5##_##prop6##_##prop7##_##prop8 { typeof(self.prop1) v1 __attribute__((unused)); typeof(self.prop2) v2 __attribute__((unused)); typeof(self.prop3) v3 __attribute__((unused)); typeof(self.prop4) v4 __attribute__((unused)); typeof(self.prop5) v5 __attribute__((unused)); typeof(self.prop6) v6 __attribute__((unused)); typeof(self.prop7) v7 __attribute__((unused)); typeof(self.prop8) v8 __attribute__((unused)); }

#define __NTJsonMetadataX(a,b,c,d,e,f,g,h,FUNC, ...) FUNC

#define __NTJsonMetadata(prefix, ...) __NTJsonMetadataX(__VA_ARGS__, __NTJsonMetadata8(prefix, __VA_ARGS__), __NTJsonMetadata7(prefix, __VA_ARGS__), __NTJsonMetadata6(prefix, __VA_ARGS__), __NTJsonMetadata5(prefix, __VA_ARGS__), __NTJsonMetadata4(prefix, __VA_ARGS__), __NTJsonMetadata3(prefix, __VA_ARGS__), __NTJsonMetadata2(prefix, __VA_ARGS__), __NTJsonMetadata1(prefix, __VA_ARGS__))

#define NTJsonIndex(...) __NTJsonMetadata(IX, __VA_ARGS__)
#define NTJsonUniqueIndex(...) __NTJsonMetadata(UX, __VA_ARGS__)
#define NTJsonQueryableFields(...) __NTJsonMetadata(QF, __VA_ARGS__)
#define NTJsonCacheSize(cacheSize) +(NSNumber *)__NTJsonMetadata__CS { return @(cacheSize); }


@interface NTJsonStorableModel : NTJsonModel

@property (nonatomic,readonly) NTJsonRowId rowid;
@property (nonatomic,readonly) BOOL isJsonCurrent;


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

+(void)beginFindOneWhere:(NSString *)where args:(NSArray *)args completionHandler:(void (^)(NTJsonStorableModel *model, NSError *error))completionHandler;
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


@protocol NTJsonMutableStorableModel <NTJsonMutableModel>

@property (nonatomic) NTJsonRowId rowid;

@end


typedef NTJsonStorableModel<NTJsonMutableStorableModel> NTJsonMutableStorableModel;

