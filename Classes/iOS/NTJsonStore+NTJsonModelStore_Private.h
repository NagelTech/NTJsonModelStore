//
//  NTJsonStore+NTJsonModelStore_Private.h
//  NTJsonModelStoreTests
//
//  Created by Ethan Nagel on 7/9/14.
//
//

#import "NTJsonStore.h"

@class NTJsonModelStore;

@interface NTJsonStore (NTJsonModelStore_Private)

@property (nonatomic,weak) NTJsonModelStore *modelStore;

@end
