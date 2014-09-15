//
//  NTJsonPropertyInfo.h
//  NTJsonModelSample
//
//  Created by Ethan Nagel on 5/30/14.
//  Copyright (c) 2014 NagelTech. All rights reserved.
//


typedef struct
{
    /// The JSON path to the data. Defaults to the name of the property.
    const char *jsonPath;
    
    /// The property type for array items
    Class elementType;
    
    /// Array of possible values for an enumerated type. Useful for String-based enumerations...
    __unsafe_unretained NSArray *enumValues;
    
    /// YES to treat this as a cached object
    BOOL cachedObject;

} __NTJsonPropertyInfo;


#define __NTJsonProperty(property, ...) @dynamic property; +(__NTJsonPropertyInfo)__NTJsonProperty__##property { return (__NTJsonPropertyInfo) { __VA_ARGS__ };   }
#define __NTJsonProperty_0(property)              __NTJsonProperty(property)
#define __NTJsonProperty_1(property,a)            __NTJsonProperty(property, .a)
#define __NTJsonProperty_2(property,a,b)          __NTJsonProperty(property, .a, .b)
#define __NTJsonProperty_3(property,a,b,c)        __NTJsonProperty(property, .a, .b, .c)
#define __NTJsonProperty_4(property,a,b,c,d)      __NTJsonProperty(property, .a, .b, .c, .d)
#define __NTJsonProperty_5(property,a,b,c,d,e)    __NTJsonProperty(property, .a, .b, .c, .d, .e)
#define __NTJsonProperty_6(property,a,b,c,d,e,f)  __NTJsonProperty(property, .a, .b, .c, .d, .e, .f)

#define __NTJsonProperty_X(X,a,b,c,d,e,f,FUNC, ...) FUNC

#define NTJsonProperty(property, ...) __NTJsonProperty_X(,##__VA_ARGS__, __NTJsonProperty_6(property, __VA_ARGS__), __NTJsonProperty_5(property, __VA_ARGS__), __NTJsonProperty_4(property, __VA_ARGS__), __NTJsonProperty_3(property, __VA_ARGS__), __NTJsonProperty_2(property, __VA_ARGS__), __NTJsonProperty_1(property, __VA_ARGS__), __NTJsonProperty_0(property))

