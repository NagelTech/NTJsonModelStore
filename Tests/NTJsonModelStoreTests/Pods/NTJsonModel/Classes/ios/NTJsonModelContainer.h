//
//  NTJsonModelContainer.h
//  NTJsonModelSample
//
//  Created by Ethan Nagel on 4/21/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol NTJsonModelContainer <NSObject>

@required

@property (nonatomic,readonly) BOOL isMutable;
@property (nonatomic,weak) id<NTJsonModelContainer> parentJsonContainer;

-(void)setMutableJson:(id)mutableJson;

-(void)becomeMutable;

@end


