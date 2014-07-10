//
//  NTJsonProp.m
//  NTJsonModelSample
//
//  Created by Ethan Nagel on 4/8/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//

#import "NTJsonModel+Private.h"


@interface NTJsonProp ()
{
    Class _modelClass;
    
    id _defaultValue;

    id _convertValueToJsonTarget;
    SEL _convertValueToJsonSelector;

    id _convertJsonToValueTarget;
    SEL _convertJsonToValueSelector;
}

@end


@implementation NTJsonProp


#pragma mark - Initializer


static NSString *ObjcAttributeType = @"T";
static NSString *ObjcAttributeReadonly = @"R";
static NSString *ObjcAttributeCopy = @"C";
static NSString *ObjcAttributeRetain = @"&";
static NSString *ObjcAttributeNonatomic = @"N";
static NSString *ObjcAttributeCustomGetter = @"G";
static NSString *ObjcAttributeCustomSetter = @"S";
static NSString *ObjcAttributeDynamic = @"D";
static NSString *ObjcAttributeWeak = @"D";
static NSString *ObjcAttributeIvar = @"V";


+(NSDictionary *)attributesForObjcProperty:(objc_property_t)objcProperty
{
    NSArray *attributePairs = [@(property_getAttributes(objcProperty)) componentsSeparatedByString:@","];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:attributePairs.count];
    
    for(NSString *attributePair in attributePairs)
        attributes[[attributePair substringToIndex:1]] = [attributePair substringFromIndex:1];

    return [attributes copy];
}


+(instancetype)propertyWithClass:(Class)class objcProperty:(objc_property_t)objcProperty
{
    NSDictionary *attributes = [self attributesForObjcProperty:objcProperty];
    
    // If it's not dynamic, then it's not one of our properties...
    
    if ( !attributes[ObjcAttributeDynamic] )
        return nil;
    
    NTJsonProp *prop = [[NTJsonProp alloc] init];
    
    prop->_modelClass = class;
    prop->_name = @(property_getName(objcProperty));
    
    // Figure out the base type...
    
    NSString *objcType = attributes[ObjcAttributeType];

    NSDictionary *simplePropertyTypes =
    @{
      @(@encode(int)): @(NTJsonPropTypeInt),
      @(@encode(BOOL)): @(NTJsonPropTypeBool),  // == char, but that's an unlikely type for a property
      @(@encode(bool)): @(NTJsonPropTypeBool),
      @(@encode(float)): @(NTJsonPropTypeFloat),
      @(@encode(double)): @(NTJsonPropTypeDouble),
      @(@encode(long long)): @(NTJsonPropTypeLongLong),
      @"@\"NSString\"": @(NTJsonPropTypeString),
      };

    NSNumber *simplePropertyType = simplePropertyTypes[objcType];
    
    if ( simplePropertyType )
    {
        prop->_type = [simplePropertyType intValue];
    }
    
    else if ( [objcType hasPrefix:@"@"] )
    {
        // Parse class name and protocols...
        
        // example: @"class<protocol1><protocol2>"
        
        NSRegularExpression *classNameRegEx = [[NSRegularExpression alloc] initWithPattern:@"@\"(\\w+).*\"" options:0 error:nil];
        NSTextCheckingResult *classNameMatch = [classNameRegEx firstMatchInString:objcType options:0 range:NSMakeRange(0, objcType.length)];
        NSString *className = [objcType substringWithRange:[classNameMatch rangeAtIndex:1]];
        
        NSRegularExpression *prototolsRegEx = [[NSRegularExpression alloc] initWithPattern:@"<(\\w+)>" options:0 error:nil];
        
        NSMutableArray *protocols = [NSMutableArray array];
        
        [prototolsRegEx enumerateMatchesInString:objcType options:0 range:NSMakeRange(0,objcType.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
        {
            [protocols addObject:[objcType substringWithRange:[result rangeAtIndex:1]]];
        }];
        
        NSSet *arrayClassNames = [NSSet setWithArray:@[@"NSArray", @"NSMutableArray", @"NTJsonModelArray"]];
        
        if ( [arrayClassNames containsObject:className] )
        {
            // It's an array type...
            
            NSString *elementClassName = [protocols firstObject];   // todo: we will need to deal with multiple protocols
            
            if ( !elementClassName )
                elementClassName = @"NSObject";
            
            prop->_typeClass = NSClassFromString(elementClassName);  // todo: validate
            prop->_type = [prop->_typeClass isSubclassOfClass:[NTJsonModel class]] ? NTJsonPropTypeModelArray : NTJsonPropTypeObjectArray;
        }
        
        else
        {
            prop->_typeClass = NSClassFromString(className); // todo: validate
            prop->_type = [prop->_typeClass isSubclassOfClass:[NTJsonModel class]] ? NTJsonPropTypeModel : NTJsonPropTypeObject;
        }
    }

    if ( !prop->_type )
        @throw [NSException exceptionWithName:@"NTJsonModelInvalidType" reason:[NSString stringWithFormat:@"Unsupported type for property %@.%@ (%@)", NSStringFromClass(class), prop->_name, objcType] userInfo:nil];

    // Ok, now get remaining details from propInfo...
    
    __NTJsonPropertyInfo propInfo;
    
    SEL propInfoSelector = NSSelectorFromString([NSString stringWithFormat:@"__NTJsonProperty__%@", prop->_name]);
    
    if ( [class respondsToSelector:propInfoSelector] )
    {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[class methodSignatureForSelector:propInfoSelector]];
        invocation.target = class;
        invocation.selector = propInfoSelector;
        [invocation invoke];
        
        [invocation getReturnValue:&propInfo];
    }
    
    else
        memset(&propInfo, 0, sizeof(propInfo)); // zero is all defaults.

    prop->_jsonKeyPath = (propInfo.jsonPath) ? @(propInfo.jsonPath) : prop->_name;
    
    if ( propInfo.elementType && (prop->_type == NTJsonPropTypeModel || prop->_type == NTJsonPropTypeObject) )
    {
        prop->_typeClass = propInfo.elementType;
        prop->_type = [prop->_typeClass isSubclassOfClass:[NTJsonModel class]] ? NTJsonPropTypeModel : NTJsonPropTypeObject;
    }
    
    if ( propInfo.enumValues && (prop->_type == NTJsonPropTypeString ||prop->_type == NTJsonPropTypeStringEnum) )
    {
        prop->_type = NTJsonPropTypeStringEnum;
        prop->_enumValues = [NSSet setWithArray:propInfo.enumValues];
    }
    
    return prop;
}


#pragma mark - description


-(NSString *)typeDescription
{
    switch(self.type)
    {
        case NTJsonPropTypeString: return(@"String");
        case NTJsonPropTypeInt: return(@"Int");
        case NTJsonPropTypeBool: return(@"Bool");
        case NTJsonPropTypeFloat: return(@"Float");
        case NTJsonPropTypeDouble: return(@"Double");
        case NTJsonPropTypeLongLong: return(@"LongLong");
        case NTJsonPropTypeModel: return([NSString stringWithFormat:@"%@{Model}", NSStringFromClass(self.typeClass)]);
        case NTJsonPropTypeModelArray: return([NSString stringWithFormat:@"%@{Model}[]", NSStringFromClass(self.typeClass)]);
        case NTJsonPropTypeStringEnum: return(@"StringEnum");
        case NTJsonPropTypeObject: return([NSString stringWithFormat:@"%@", NSStringFromClass(self.typeClass)]);
        case NTJsonPropTypeObjectArray: return([NSString stringWithFormat:@"%@[]", NSStringFromClass(self.typeClass)]);
    }
}


-(NSString *)description
{
    NSMutableString *desc = [NSMutableString string];
    
    [desc appendFormat:@"%@.%@(type=%@", NSStringFromClass(self.modelClass), self.name, [self typeDescription]];
    
    if ( ![self.jsonKeyPath isEqualToString:self.name] )
        [desc appendFormat:@", jsonKeyPath=\"%@\"", self.jsonKeyPath];
    
    if ( self.type == NTJsonPropTypeStringEnum )
        [desc appendFormat:@", enumValues=[%@]", [[self.enumValues allObjects] componentsJoinedByString:@", "]];
    
    [desc appendString:@")"];
    
    return [desc copy];
}


#pragma mark - Properties


-(BOOL)shouldCache
{
    return (self.type == NTJsonPropTypeModel
            || self.type == NTJsonPropTypeModelArray
            || self.type == NTJsonPropTypeObject
            || self.type == NTJsonPropTypeObjectArray);
}


+(id)defaultValueForType:(NTJsonPropType)type
{
    switch (type)
    {
        case NTJsonPropTypeInt:
            return @(0);
            
        case NTJsonPropTypeBool:
            return @(NO);
            
        case NTJsonPropTypeFloat:
            return @((float)0);
            
        case NTJsonPropTypeDouble:
            return @((double)0);
            
        case NTJsonPropTypeLongLong:
            return ((long long)0);
            
        default:
            return nil;
    }
}


-(id)defaultValue
{
    if ( !_defaultValue )
        _defaultValue = [self.class defaultValueForType:self.type];
    
    return _defaultValue;
}


-(Class)modelClass
{
    return _modelClass;
}


-(void)setModelClass:(Class)modelClass
{
    _modelClass = modelClass;
}


#pragma mark - Conversion support


-(BOOL)probeConverterToValue:(BOOL)toValue Target:(id)target selector:(SEL)selector
{
    if ( ![target respondsToSelector:selector] )
        return NO;
    
    if ( toValue )
    {
        _convertJsonToValueTarget = target;
        _convertJsonToValueSelector = selector;
    }
    
    else // toJson
    {
        _convertValueToJsonTarget = target;
        _convertValueToJsonSelector = selector;
    }
    
    return YES;
}


-(id)convertJsonToValue:(id)json
{
    if ( self.type != NTJsonPropTypeObject && self.type != NTJsonPropTypeObjectArray )
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"convertJsonToValue: only supports Objects currently." userInfo:nil];
    
    if ( !_convertJsonToValueSelector )
    {
        NSString *convertJsonToProperty = [NSString stringWithFormat:@"convertJsonTo%@%@:", [[self.name substringToIndex:1] uppercaseString], [self.name substringFromIndex:1]];
        NSString *convertJsonToClass = [NSString stringWithFormat:@"convertJsonTo%@:", NSStringFromClass(self.typeClass)];
        
        BOOL found = [self probeConverterToValue:YES Target:self.modelClass selector:NSSelectorFromString(convertJsonToProperty)];
        
        if ( !found )
            found = [self probeConverterToValue:YES Target:self.modelClass selector:NSSelectorFromString(convertJsonToClass)];
        
        if ( !found )
            found = [self probeConverterToValue:YES Target:self.typeClass selector:@selector(convertJsonToValue:)];
        
        if ( !found )
            @throw [NSException exceptionWithName:@"UnableToConvert" reason:[NSString stringWithFormat:@"Unable to find a JsonToValue converter for %@.%@ of type %@. Tried %@ +%@, %@ +%@ and %@ +convertJsonToValue:",  NSStringFromClass(self.modelClass), self.name, NSStringFromClass(self.typeClass), NSStringFromClass(self.modelClass), convertJsonToProperty, NSStringFromClass(self.modelClass), convertJsonToClass, NSStringFromClass(self.modelClass)] userInfo:nil];
    }

    // somehow this is the "safe" way to call performSelector using ARC. Ironic? Yep!
    // http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
    
    id (*method)(id self, SEL _cmd, id json) = (void *)[_convertJsonToValueTarget methodForSelector:_convertJsonToValueSelector];
    
    return method(_convertJsonToValueTarget, _convertJsonToValueSelector, json);
}


-(id)convertValueToJson:(id)value
{
    if ( self.type != NTJsonPropTypeObject && self.type != NTJsonPropTypeObjectArray )
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"convertValueToJson: only supports Objects currently." userInfo:nil];
    
    if ( !_convertValueToJsonSelector )
    {
        NSString *convertPropertyToJson = [NSString stringWithFormat:@"convert%@%@ToJson:", [[self.name substringToIndex:1] uppercaseString], [self.name substringFromIndex:1]];
        NSString *convertClassToJson = [NSString stringWithFormat:@"convert%@ToJson:", NSStringFromClass(self.typeClass)];
        
        BOOL found = [self probeConverterToValue:NO Target:self.modelClass selector:NSSelectorFromString(convertPropertyToJson)];
        
        if ( !found )
            found = [self probeConverterToValue:NO Target:self.modelClass selector:NSSelectorFromString(convertClassToJson)];
        
        if ( !found )
            found = [self probeConverterToValue:NO Target:self.typeClass selector:@selector(convertValueToJson:)];
        
        if ( !found )
            @throw [NSException exceptionWithName:@"UnableToConvert" reason:[NSString stringWithFormat:@"Unable to find a ValueToJson converter for %@.%@ of type %@. Tried %@ +%@, %@ +%@ and %@ +convertValueToJson:",  NSStringFromClass(self.modelClass), self.name, NSStringFromClass(self.typeClass), NSStringFromClass(self.modelClass), convertPropertyToJson, NSStringFromClass(self.modelClass), convertClassToJson, NSStringFromClass(self.modelClass)] userInfo:nil];
    }
    
    // somehow this is the "safe" way to call performSelector using ARC. Ironic? Yep!
    // http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
    
    id (*method)(id self, SEL _cmd, id json) = (void *)[_convertValueToJsonTarget methodForSelector:_convertValueToJsonSelector];
    
    return method(_convertValueToJsonTarget, _convertValueToJsonSelector, value);
}


@end
