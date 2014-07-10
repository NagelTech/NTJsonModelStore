//
//  NTJsonModel+Private.h
//  NTJsonModelSample
//
//  Created by Ethan Nagel on 4/8/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

#import <objc/objc.h>

#import "NSMutableDictionary+NTJsonModelPrivate.h"

#import "NTJsonModelContainer.h"
#import "NTJsonModel.h"

#import "NTJsonModelArray+Private.h"
#import "NTJsonProp+Private.h"

#import "NTJsonPropertyInfo.h"


@interface NTJsonModel (Private) <NTJsonModelContainer>

@property (nonatomic,readwrite) NSMutableDictionary *mutableJson;

@end

id NTJsonModel_deepCopy(id json);
id NTJsonModel_mutableDeepCopy(id json);


