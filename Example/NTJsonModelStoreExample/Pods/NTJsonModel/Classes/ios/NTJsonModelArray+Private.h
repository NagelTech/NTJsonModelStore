//
//  NTJsonModelArray+Private.h
//  NTJsonModelSample
//
//  Created by Ethan Nagel on 4/18/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

@class NTJsonModel;
@class NTJsonProp;

@interface NTJsonModelArray : NSArray <NSCopying, NSMutableCopying>

@property (nonatomic, readonly) Class modelClass;
@property (nonatomic, readonly) NSArray *__NSJsonModelArray_json;

-(id)initWithModelClass:(Class)modelClass json:(NSArray *)json;
-(id)initWithProperty:(NTJsonProp *)property json:(NSArray *)json;

-(id)copyWithZone:(NSZone *)zone;
-(id)mutableCopyWithZone:(NSZone *)zone;

@end
