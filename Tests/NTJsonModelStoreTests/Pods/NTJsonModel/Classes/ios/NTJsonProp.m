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
    
    NSString *name = @(property_getName(objcProperty));
    
    // Get to our propInfo...
    
    SEL propInfoSelector = NSSelectorFromString([NSString stringWithFormat:@"__NTJsonProperty__%@", name]);
    
    if ( ![class respondsToSelector:propInfoSelector] )
        return nil; // it's not one of ours...
    
    // Create our class and set the basics...
    
    NTJsonProp *prop = [[NTJsonProp alloc] init];
    
    prop->_modelClass = class;
    prop->_name = name;
    
    // Get to our propInfo...
    
    __NTJsonPropertyInfo propInfo;
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[class methodSignatureForSelector:propInfoSelector]];
    invocation.target = class;
    invocation.selector = propInfoSelector;
    [invocation invoke];
    
    [invocation getReturnValue:&propInfo];
    
    // Figure out the base type...
    
    NSString *objcType = attributes[ObjcAttributeType];

    NSDictionary *simplePropertyTypes =
    @{
      @(@encode(int)): @(NTJsonPropTypeInt),
      @(@encode(signed char)): @(NTJsonPropTypeBool),  // sometimes BOOls look like this, that's an unlikely type for a property
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
        
        NSSet *arrayClassNames = [NSSet setWithArray:@[@"NSArray"]];        // only this one type for now
        
        if ( [arrayClassNames containsObject:className] )
        {
            // It's an array type, let's figure out the element type...
            // this can com from two different places, so we need to do a bit of validation here...
            
            Class elementClass = propInfo.elementType;
            NSString *protocolElementClassName = [protocols firstObject];
            
            if ( elementClass && protocolElementClassName.length ) // both were defined
            {
                @throw [NSException exceptionWithName:@"NTJsonModelInvalidType" reason:[NSString stringWithFormat:@"Array element type is defined as a protocol as well as explicitly in NTPropInfo: %@.%@ (%@ and %@)", NSStringFromClass(class), prop->_name, NSStringFromClass(elementClass), protocolElementClassName] userInfo:nil];
            }
            else if ( !elementClass && !protocolElementClassName.length ) // neither were defined
            {
                elementClass = [NSObject class];
            }
            else if ( protocolElementClassName.length )    // only defined in protocol
            {
                elementClass = NSClassFromString(protocolElementClassName);
                
                if ( !elementClass )
                {
                    @throw [NSException exceptionWithName:@"NTJsonModelInvalidType" reason:[NSString stringWithFormat:@"Invalid elementName defined as protocol: %@.%@ (%@)", NSStringFromClass(class), prop->_name, protocolElementClassName] userInfo:nil];
                }
            }
            
            if ( elementClass == [NSObject class] )
            {
                // Untyped arrays are handled as simple objects...
                prop->_type = NTJsonPropTypeObject;
                prop->_typeClass = NSClassFromString(className);
            }
            else
            {
                prop->_type = [elementClass isSubclassOfClass:[NTJsonModel class]] ? NTJsonPropTypeModelArray : NTJsonPropTypeObjectArray;
                prop->_typeClass = elementClass;
            }
        }
        
        else if ( [className isEqualToString:@"NSMutableArray"] || [className isEqualToString:@"NSMutableDictionary"] )
        {
            @throw [NSException exceptionWithName:@"NTJsonModelInvalidType" reason:[NSString stringWithFormat:@"Mutable Arrays/Dictionaries are not supported. Property: %@.%@ (%@)", NSStringFromClass(class), prop->_name, objcType] userInfo:nil];
        }
        
        else
        {
            prop->_typeClass = NSClassFromString(className); // todo: validate
            prop->_type = [prop->_typeClass isSubclassOfClass:[NTJsonModel class]] ? NTJsonPropTypeModel : NTJsonPropTypeObject;
        }
    }

    if ( !prop->_type )
        @throw [NSException exceptionWithName:@"NTJsonModelInvalidType" reason:[NSString stringWithFormat:@"Unsupported type for property %@.%@ (%@)", NSStringFromClass(class), prop->_name, objcType] userInfo:nil];
    
    prop->_isReadOnly = (attributes[ObjcAttributeReadonly]) ? YES : NO;
    
    // Parse the keypath...

    NSString *jsonKeyPath = (propInfo.jsonPath) ? @(propInfo.jsonPath) : prop->_name;
    
    NSInteger dotPos = [jsonKeyPath rangeOfString:@"."].location;
    
    if ( dotPos != NSNotFound )
    {
        prop->_jsonKey = [jsonKeyPath substringToIndex:dotPos];
        prop->_remainingJsonKeyPath = [jsonKeyPath substringFromIndex:dotPos+1];
    }
    else
        prop->_jsonKey = jsonKeyPath;
    
    if ( propInfo.enumValues && (prop->_type == NTJsonPropTypeString ||prop->_type == NTJsonPropTypeStringEnum) )
    {
        prop->_type = NTJsonPropTypeStringEnum;
        prop->_enumValues = [NSSet setWithArray:propInfo.enumValues];
    }
    
    prop->_cachedObject = propInfo.cachedObject;
    
    if ( prop->_cachedObject )
    {
        // When a model is used as a cached object, we need to treat it as a simple object.
        
        if ( prop->_type == NTJsonPropTypeModel )
            prop->_type = NTJsonPropTypeObject;
        
        else if ( prop->_type == NTJsonPropTypeModelArray )
            prop->_type = NTJsonPropTypeObjectArray;
    }
    
    if ( prop->_remainingJsonKeyPath.length && !prop->_isReadOnly )
    {
        @throw [NSException exceptionWithName:@"NTJsonModelInvalidType" reason:[NSString stringWithFormat:@"Properties with nested jsonKeyPaths must currently be read-only for property %@.%@ (%@)", NSStringFromClass(class), prop->_name, objcType] userInfo:nil];
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
    
    if ( self.remainingJsonKeyPath.length )
        [desc appendFormat:@", jsonKeyPath=\"%@.%@\"", self.jsonKey, self.remainingJsonKeyPath];
    
    else if ( ![self.jsonKey isEqualToString:self.name] )
        [desc appendFormat:@", jsonKeyPath=\"%@\"", self.jsonKey];
    
    if ( self.type == NTJsonPropTypeStringEnum )
        [desc appendFormat:@", enumValues=[%@]", [[self.enumValues allObjects] componentsJoinedByString:@", "]];
    
    if ( self.isReadOnly )
        [desc appendFormat:@", readonly"];
    
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


-(NSString *)jsonKeyPath
{
    if ( !self.remainingJsonKeyPath.length )
        return self.jsonKey;
    
    return [NSString stringWithFormat:@"%@.%@", self.jsonKey, self.remainingJsonKeyPath];
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


-(id)object_convertJsonToValue:(id)json
{
    if ( self.type != NTJsonPropTypeObject && self.type != NTJsonPropTypeObjectArray )
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"convertJsonToValue: only supports Objects currently." userInfo:nil];
    
    if ( !_convertJsonToValueSelector )
    {
        NSString *convertJsonToProperty = [NSString stringWithFormat:@"convertJsonTo%@%@:", [[self.name substringToIndex:1] uppercaseString], [self.name substringFromIndex:1]];
        
        BOOL found = [self probeConverterToValue:YES Target:self.modelClass selector:NSSelectorFromString(convertJsonToProperty)];
        
        if ( !found )
        {
            NSString *convertJsonToClass = [NSString stringWithFormat:@"convertJsonTo%@:", NSStringFromClass(self.typeClass)];
            
            found = [self probeConverterToValue:YES Target:self.modelClass selector:NSSelectorFromString(convertJsonToClass)];
        }
        
        if ( !found )
            found = [self probeConverterToValue:YES Target:self.typeClass selector:@selector(convertJsonToValue:)];

        if ( !found )
            @throw [NSException exceptionWithName:@"UnableToConvert" reason:[NSString stringWithFormat:@"Unable to find a JsonToValue converter for %@.%@ of type %@.",  NSStringFromClass(self.modelClass), self.name, NSStringFromClass(self.typeClass)] userInfo:nil];
    }

    // somehow this is the "safe" way to call performSelector using ARC. Ironic? Yep!
    // http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
    
    id (*method)(id self, SEL _cmd, id json) = (void *)[_convertJsonToValueTarget methodForSelector:_convertJsonToValueSelector];
    
    return method(_convertJsonToValueTarget, _convertJsonToValueSelector, json);
}


-(id)object_convertValueToJson:(id)value
{
    if ( self.type != NTJsonPropTypeObject && self.type != NTJsonPropTypeObjectArray )
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"convertValueToJson: only supports Objects currently." userInfo:nil];
    
    if ( !_convertValueToJsonSelector )
    {
        NSString *convertPropertyToJson = [NSString stringWithFormat:@"convert%@%@ToJson:", [[self.name substringToIndex:1] uppercaseString], [self.name substringFromIndex:1]];
        
        BOOL found = [self probeConverterToValue:NO Target:self.modelClass selector:NSSelectorFromString(convertPropertyToJson)];
        
        if ( !found )
        {
            NSString *convertClassToJson = [NSString stringWithFormat:@"convert%@ToJson:", NSStringFromClass(self.typeClass)];
            
            found = [self probeConverterToValue:NO Target:self.modelClass selector:NSSelectorFromString(convertClassToJson)];
        }
        
        if ( !found )
            found = [self probeConverterToValue:NO Target:self.typeClass selector:@selector(convertValueToJson:)];

        if ( !found )
            @throw [NSException exceptionWithName:@"UnableToConvert" reason:[NSString stringWithFormat:@"Unable to find a ValueToJson converter for %@.%@ of type %@.",  NSStringFromClass(self.modelClass), self.name, NSStringFromClass(self.typeClass)] userInfo:nil];
    }
    
    // somehow this is the "safe" way to call performSelector using ARC. Ironic? Yep!
    // http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
    
    id (*method)(id self, SEL _cmd, id json) = (void *)[_convertValueToJsonTarget methodForSelector:_convertValueToJsonSelector];
    
    return method(_convertValueToJsonTarget, _convertValueToJsonSelector, value);
}


-(id)convertJsonToValue:(id)json
{
    id value = json;
    
    switch (self.type)
    {
        case NTJsonPropTypeInt:
        {
            if ( ![value isKindOfClass:[NSNumber class]] )
                value = [value respondsToSelector:@selector(intValue)] ? @([value intValue]) : self.defaultValue;
            else if ( strcmp([value objCType], @encode(int)) != 0 )
                value = [NSNumber numberWithInt:[value intValue]];
            break;
        }
            
        case NTJsonPropTypeBool:
        {
            if ( ![value isKindOfClass:[NSNumber class]] )
                value = [value respondsToSelector:@selector(boolValue)] ? @([value boolValue]) : self.defaultValue;
            else if ( strcmp([value objCType], @encode(bool)) != 0 && strcmp([value objCType], @encode(signed char)) != 0 )
                value = [NSNumber numberWithBool:[value boolValue]];
            break;
        }
            
        case NTJsonPropTypeFloat:
        {
            if ( ![value isKindOfClass:[NSNumber class]] )
                value = [value respondsToSelector:@selector(floatValue)] ? @([value floatValue]) : self.defaultValue;
            else if ( strcmp([value objCType], @encode(float)) != 0 )
                value = [NSNumber numberWithFloat:[value floatValue]];
            break;
        }
            
        case NTJsonPropTypeDouble:
        {
            if ( ![value isKindOfClass:[NSNumber class]] )
                value = [value respondsToSelector:@selector(doubleValue)] ? @([value doubleValue]) : self.defaultValue;
            else if ( strcmp([value objCType], @encode(double)) != 0 )
                value = [NSNumber numberWithDouble:[value doubleValue]];
            break;
        }
            
            
        case NTJsonPropTypeLongLong:
        {
            if ( ![value isKindOfClass:[NSNumber class]] )
                value = [value respondsToSelector:@selector(longLongValue)] ? @([value longLongValue]) : self.defaultValue;
            else if ( strcmp([value objCType], @encode(long long)) != 0 )
                value = [NSNumber numberWithLongLong:[value longLongValue]];
            break;
        }
            
        case NTJsonPropTypeString:
        {
            if ( ![value isKindOfClass:[NSString class]] )
                value = [value respondsToSelector:@selector(stringValue)] ? [value stringValue] : self.defaultValue;
            break;
        }
            
        case NTJsonPropTypeStringEnum:
        {
            if ( ![value isKindOfClass:[NSString class]] )
                value = [value respondsToSelector:@selector(stringValue)] ? [value stringValue] : self.defaultValue;
            
            value = [self.enumValues member:value] ?: value;
            break;
        }
            
        case NTJsonPropTypeModel:
        {
            value = [value isKindOfClass:[NSDictionary class]] ? [[self.typeClass alloc] initWithJson:value] : self.defaultValue;
            break;
        }
            
        case NTJsonPropTypeObject:
        {
            value = [self object_convertJsonToValue:value] ?: self.defaultValue;
            break;
        }
            
        case NTJsonPropTypeObjectArray:
        case NTJsonPropTypeModelArray:
        {
            value = [value isKindOfClass:[NSArray class]] ? [[NTJsonModelArray alloc] initWithProperty:self json:value] : self.defaultValue;
            break ;
        }
    }
    
    return value;
}


-(id)convertValueToJson:(id)value
{
    switch (self.type)
    {
        case NTJsonPropTypeInt:
        case NTJsonPropTypeBool:
        case NTJsonPropTypeFloat:
        case NTJsonPropTypeDouble:
        case NTJsonPropTypeLongLong:
        case NTJsonPropTypeString:
        case NTJsonPropTypeStringEnum:
            return value;   // the runtime should have given these to us in the correct format already.
            
        case NTJsonPropTypeModel:
        case NTJsonPropTypeModelArray:
            return [value asJson];
            
        case NTJsonPropTypeObjectArray:
        {
            NSArray *valueArray = value;
            NSMutableArray *jsonArray = [NSMutableArray arrayWithCapacity:valueArray.count];
            
            if ( [valueArray isKindOfClass:[NSArray class]] )
            {
                for(id itemValue in valueArray)
                {
                    id itemJson = [self object_convertValueToJson:itemValue];
                    
                    if ( itemJson )
                        [jsonArray addObject:itemJson];
                }
            }
            
            return [jsonArray copy];
        }
            
        case NTJsonPropTypeObject:
            return [self object_convertValueToJson:value];
            
        default:
            @throw [NSException exceptionWithName:@"NTJsonUnexpectedType" reason:@"Unexpected Property Type" userInfo:nil];
    }
}


@end
