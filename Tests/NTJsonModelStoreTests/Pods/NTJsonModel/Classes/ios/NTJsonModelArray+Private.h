//
//  NTJsonModelArray+Private.h
//  NTJsonModelSample
//
//  Created by Ethan Nagel on 4/18/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

#import "NTJsonModelContainer.h"
#import "NTJsonModelArray.h"


@interface NTJsonModelArray (Private) <NTJsonModelContainer>

@property (nonatomic, readonly) NSMutableArray *mutableJsonArray;

-(id)initWithModelClass:(Class)modelClass jsonArray:(NSArray *)jsonArray;
-(id)initWithModelClass:(Class)modelClass mutableJsonArray:(NSArray *)mutableJsonArray;

@end
