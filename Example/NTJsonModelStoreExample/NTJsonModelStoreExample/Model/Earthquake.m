//
//  Earthquake.m
//  NTJsonModelStoreExample
//
//  Created by Ethan Nagel on 12/22/14.
//  Copyright (c) 2014 Nagel Technologies, Inc. All rights reserved.
//

#import "Earthquake.h"

#import "GeoJSONPoint.h"


@implementation Earthquake

NTJsonUniqueIndex(code)
NTJsonIndex(magnitude)
NTJsonIndex(title)
NTJsonIndex(time)

NTJsonProperty(code, jsonPath="properties.code")
NTJsonProperty(title, jsonPath="properties.title")
NTJsonProperty(magnitude, jsonPath="properties.mag")
NTJsonProperty(time, jsonPath="properties.time")


+(NTJsonModelCollection *)defaultModelCollection
{
    static NTJsonModelCollection *modelCollection;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        modelCollection = [[self defaultModelStore] collectionWithName:[self defaultModelCollectionName]];
        modelCollection.modelClass = self;
    });
    
    return modelCollection;
}


-(CLLocation *)location
{
    return ([self.geometry isKindOfClass:[GeoJSONPoint class]]) ? ((GeoJSONPoint *)self.geometry).coordinate : nil;
}


@end
