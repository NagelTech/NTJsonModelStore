//
//  NTJsonStore+NTJsonModelStore_Private.m
//  NTJsonModelStoreTests
//
//  Created by Ethan Nagel on 7/9/14.
//
//

#import <objc/runtime.h>

#import "NTJsonModelStore+Private.h"


@implementation NTJsonStore (NTJsonModelStore_Private)


-(NTJsonModelStore *)modelStore
{
    return objc_getAssociatedObject(self, @selector(modelStore));
}


-(void)setModelStore:(NTJsonModelStore *)modelStore
{
    objc_setAssociatedObject(self, @selector(modelStore), modelStore, OBJC_ASSOCIATION_ASSIGN);
}


@end
