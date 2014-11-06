//
//  __NTJsonModelSupport.h
//  NTJsonModelSample
//
//  Created by Ethan Nagel on 9/4/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

#import <Foundation/Foundation.h>


@class NTJsonModel;

@interface __NTJsonModelSupport : NSObject

@property (nonatomic,readonly) Class modelClass;
@property (nonatomic,readonly) NSArray *properties;
@property (nonatomic,readonly) NSDictionary *defaultJson;
@property (nonatomic,readonly) BOOL modelClassForJsonOverridden;

-(instancetype)initWithModelClass:(Class)modelClass;

-(NSString *)descriptionForModel:(NTJsonModel *)model fullDescription:(BOOL)fullDescription parentModels:(NSArray *)parentModels;

@end
