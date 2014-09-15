//
//  NTJsonModel+Private.h
//  NTJsonModelSample
//
//  Created by Ethan Nagel on 4/8/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

#import <objc/objc.h>

#import "NTJsonModel.h"

#import "NTJsonModelArray+Private.h"
#import "NTJsonProp+Private.h"

#import "NTJsonPropertyInfo.h"


@class __NTJsonModelSupport;


@interface NTJsonModel (Private)

+(__NTJsonModelSupport *)__ntJsonModelSupport;

-(id)__json;

@end


