//
//  NSMutableDictionary+NTJsonModelPrivate.h
//  NTJsonModelSample
//
//  Created by Ethan Nagel on 5/1/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (NTJsonModelPrivate)


-(void)NTJsonModel_setObject:(id)obj forKeyPath:(NSString *)keyPath;


@end
