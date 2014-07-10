//
//  NTJsonModelArray.h
//  NTJsonModelSample
//
//  Created by Ethan Nagel on 4/9/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

#import <Foundation/Foundation.h>


@class NTJsonModel;

@interface NTJsonModelArray : NSMutableArray <NSCopying, NSMutableCopying>

@property (nonatomic, readonly) Class modelClass;
@property (nonatomic, readonly) NSArray *jsonArray;
@property (nonatomic, readonly) BOOL isMutable;

-(id)copyWithZone:(NSZone *)zone;
-(id)mutableCopyWithZone:(NSZone *)zone;

-(void)becomeMutable;

@end
