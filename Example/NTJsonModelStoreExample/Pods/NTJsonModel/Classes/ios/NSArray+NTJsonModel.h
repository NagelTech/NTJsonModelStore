//
//  NSArray+NTJsonModel.h
//  NTJsonModelSample
//
//  Created by Ethan Nagel on 9/8/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray (NTJsonModel)

/**
 *  returns a JSON representation of the array
 *
 *  @return an NSArray where the elements are all JSON-encoded
 */
-(id)asJson;

@end
