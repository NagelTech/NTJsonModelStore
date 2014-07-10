//
//  NTJsonCollection+NTJsonModelStore_Private.h
//  NTJsonModelStoreTests
//
//  Created by Ethan Nagel on 7/9/14.
//
//

#import "NTJsonCollection.h"


@class NTJsonModelCollection;


@interface NTJsonCollection (NTJsonModelStore_Private)

@property (nonatomic,readonly) NTJsonModelCollection *modelCollection;

@end

