//
//  NTJsonCollection+NTJsonModelStore_Private.m
//  NTJsonModelStoreTests
//
//  Created by Ethan Nagel on 7/9/14.
//
//

#import <objc/runtime.h>

#import "NTJsonModelStore+Private.h"


@implementation NTJsonCollection (NTJsonModelStore_Private)


-(NTJsonModelCollection *)modelCollection
{
    NTJsonModelCollection *modelCollection = objc_getAssociatedObject(self, @selector(modelCollection));
    
    if ( !modelCollection )
    {
        modelCollection = [[NTJsonModelCollection alloc] initWithCollection:self];
        objc_setAssociatedObject(self, @selector(modelCollection), modelCollection, OBJC_ASSOCIATION_RETAIN);
    }
    
    return modelCollection;
}


@end
