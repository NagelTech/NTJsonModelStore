# NTJsonModel

NTJsonModel provides and easy-to-use and high-performance wrapper for JSON objects. It features an intuitive model for declaring properties and works to preserve the original JSON.

NTJsonModel is unique in that it supports both immutable and mutable states for objects and gives you the tools to make this practical for model objects. If you take advantage of these features you can have immutable model objects, only "mutating" them in specific contexts, similar to the approach you would see in functional languages.


## [Overview](id: overview)

 * A lightweight wrapper over an existing JSON object. Creating objects is very effecient. All properties and arrays are lazy-loaded the first time they are requested.
 * Properties are declared using a combination of `@property` declarations and a macro, `NTJsonProperty`
 * Objects are created as either immutable or mutable. (Immutable is the default; mutable objects may be created using mutable initializers or with `mutableCopy`.) With a little extra work you use immutable objects throught your application, making changes only in controlled 'mutation' blocks.
 * Maintains the original JSON, including any json values that aren't mapped into the model.
 * Properties are declared using a combination of the @property declaration and a single line in the @implementation for each property (`NTJsonProperty` macro)
 * Supports converted properties (transparently converting a string to a `UIColor` for instance), working in both directions.
 * Object caching is supported as well, allowing an object ID in the JSON to be returned as an object loaded from a data store, for instance. 


## [Declaring properties](id: declaring-properties)

----

Properties are declared using a combination of the standard @property which gives us the data type and and a macro (`NTJsonProperty`) which adds meta-data such as the jsonPath. 

	@interface User : NTJsonModel
	
	@property (nonatomic) NSString *firstName;
	@property (nonatomic) NSString *lastName;
	@property (nonatomic) int age;

	@end
	
	@implementation User
	
	NTJsonProperty(firstName)
	NTJsonProperty(lastName)
	NTJsonProperty(age)
	
	@end
	
	// usage
	
	NSDictionary *json = ...
	
	User *user = [[User alloc] initWithJson:json];
	
	NSLog(@"Hello, %@", user.firstName);


### [NTJsonProperty Macro](id: ntjsonproperty-macro)

NTJsonProperty is a fancy macro that requires the property name as the first parameter. Additionally it has several optional parameters that are of the form key=value.

 * `jsonPath="path"` - Sets the JSON path for this property. By default this matches the property name. Nested jsonPaths (ie "a.b") are allowed for read-only properties
 * `enumValues=NSArray` - Defines an array of strings that define valid values for this property. See [String-based enumerations](#string-based-enumerations).
 * `cachedObject=YES` - Specifies that this should be treated as a cached object, which is a special case of conversion. See [Object Caching](#object-caching) for more information.
 * `elementType=class` - Allows you to set the element type for an Array. The protocol syntax may also be used, which is a bit more elegant. See [Declaring typed arrays](#declaring-typed-arrays), below.
 

### [Declaring typed arrays](id:declaring-typed-arrays)

NTJsonModel supports typed arrays which will automatically be converted into child NTJsonModels or other native types the first time they are accessed. This can be done using the `NTJsonProperty` `elementType=` parameter or using prococols. To use protocols, simply declare a protocol with the same name as the class and make the array conform to the protocol. (Thanks to [JsonModel](http://www.jsonmodel.com/) for poineering this approach.) Here's an example:
 
	@protocol Address // empty
	@end
	
	@interface Address
	
	@property (nonatomic) NSString *street;
	@property (nonatomic) NSString *city;
	
	@end
	
	@interface User : NTJsonModel
	
	...
	
	@property (nonatomic) NSArray<Address> *addresses;
	
	@end
	
	
	@implementation User
	
	NTJsonProperty(address)
	
	-- or, without protocols --
	
	NTJsonProperty(address, elementType=[Address class])
	
	@end
	

### [String-based enumerations](id:string-based-enumerations)

NTJsonModel supports string-based enumerations using the `enumValues=` NTJsonProperty parameter. See the example below for an example of using it. If the JSON value matches any of the enumerations that exact value will be returned allowing you to use `==` instead of `isEqualToString:`, which can be very convenient.

	typedef NSString *UserType;
	
	extern UserType UserTypePrimary;
	extern UserType UserTypeSecondary;
	
	@interface User : NTJsonModel
	
	...
	
	@property (nontatomic) UserType type;
	
	+(NSArray *)types;
	
	@end
	
	UserType UserTypePrimary = @"primary";
	UserType UserTypeSecondary = @"secondary";
	
	@implementation 
	
	NTJsonProperty(type, enumValues=[User types])
	
	@end
	
	...
	
	User *user = ...
	
	if ( user.type == UserTypePrimary )
		...


## [Immutable and Mutable objects](id: immutable-and-mutable-objects)

----

Each model object may be created as mutable or immutable. Immutable objects are thread-safe, and very effecient. calling `-initWithJson:` or `+mutableModelWithJson:` creates an immutable model. Additionally, you may call `copy` on any object to get an immutable version. (Calling `copy` on an immutable object simply returns the sender.) You may check if a model is mutable or immutable using the `isMutable` property. **Attempting to set a property value on an immutable instance will throw an exception.**

This is similar to the approach that we see with objects like `NSMutableArray` and `NSArray`, but we have only a single object to work with which can be created in either a mutable or immutable state. (With a little more work, there is a way to get the compiler to enforce mutable and immutable properties, see [Mutable protocols](#mutable-protocols)

Mutable objects are not thread-safe and you must enforce this yourself. You may create a mutable instance using `initMutable` (Which creates an empty mutable instance), `initMutableWithJson` or `mutableModelWithJson:`. Additionally, you can get a mutable version calling `mutableCopy` on any model.

When setting properties, the system will try to keep the JSON as consistent with the current data as possible. For instance, If you have a property you have exposed as an int but it is stored as a string in the JSON, setting it will cause the system to set a string to the JSON (it will always be exposed as an int property.) If the underlying JSON was an int already then it would store an int.

Immutable objects are designed to be high-perfomance and thread-safe. It's good practice to use immutable objects whenever possible and create mutable copies when changes are needed. 


### [Updating properties](id: updating-properties)

Using immutable objects can create suprising results when you have mutable properties since there is only a single object. You might expect the following to work, but it would throw an exception:

	User *user = [User modelWithJson:userJson];
	user.age = 21;	// Fails with an exception, user is immutable!
	
You can always create mutable objects instead, so this would work:

	User *user = [User mutableModelWithJson:userJson];
	user.age = 21;	// succeeds
	
Things can get complex if you are mixing immutable and mutable objects in your code too much. Ideally, you should use immutable objects and only "mutate" them in very controlled situations. You can get the same effect as the above by creating a mutable copy, updating that then storing an immutable version:
	
	User *user = [User modelWithJson:userJson];
	User *mutableUser = [user mutableCopy];
	mutableUser.age = 21;	// allowed, this is a mutable object
	user = [mutableUser copy];
	
Of course this a lot of boilerplate to change a single property; the `mutate:` method is here to simplify things for you - see the next section.


## [Using the `mutate:` method](id: using-the-mutate-method)

The mutate method encapsulates the common pattern of creating a mutable copy of an object, making changes then getting an immutable copy of the result:

`-(id)mutate:(void (^)(id mutable))mutationBlock;`

This method creates a mutable copy of the sender, passes that to the mutation block and returns an immutable copy of the result.  As you can see, the above code is _much_ cleaner using mutate:

	User *user = [User modelWithJson:userJson];
	
	user = [user mutate:^(User *mutable) {
		mutable.age = 21;
	}];

This makes things your code much safer and clearer.

Unfortunately, the compiler won't warn you if you attempt to set a property on an immutable object (you _will_ get an exception at runtime, however.) The next section shows how you, with a little more work, can get the compiler to enforce mutablility for you model objects.


### [Mutable protocols](id:mutable-protocols)

With a little more work in declaring your models, it's possible to get the compiler to help enforce mutability for your objects. This involves decalring all roperties as readonly in your class and creating a "paired" protocol with readwrite versions of the updatable properties. You can then use the class under normal (immutable) conditions and apply the protocol when you explicity create a mutable instance (or copy) of an object. This is easiest to see in code - here is an updated version of our `User` model:

	@interface User : NTJsonModel
	
	@property (nonatomic,readonly) NSString *firstName;
	@property (nonatomic,readonly) NSString *lastName;
	@property (nonatomic,readonly) int age;

	@end
	
	@protocol MutableUser <NTJsonMutableModel>

	@property (nonatomic) NSString *firstName;
	@property (nonatomic) NSString *lastName;
	@property (nonatomic) int age;

	@end
	
	typedef User<MutableUser> MutableUser;
	
	...
	
	@implementation User
	
	NTJsonMutable(MutableUser)	// this is required!
	
	NTJsonProperty(firstName)
	NTJsonProperty(lastName)
	NTJsonProperty(age)
	
	@end
	
Here's an example:
	
	User *user = [User modelWithJson:userJson];
	
this will cause a compiler error:
	
	user.age = 21;	// compiler error
	
but this will work just fine:
	
	user = [user mutate:^(MutableUser *mutable) {
		mutable.age = 21;	// all good!
	}];

This is a little more work in declaring the properties (and there is some extra work when creating methods that change properties), but having the compiler help you avoid mistakes with mutability is very (very) helpful, especially with larger applications.

Here are some additional details:

 - Under the hood we actually implement the setters in the protocol in the class, they just aren't exposed. The `NTJsonMutable` macro is what binds the protocol to the class and allows ths setters to be created. If you omit this step, you will get a 'method not found' exception when attempting to set properties.
 - The protocol should inherit from the paired classes' protocol. If we subclassed user with a new class, say `AdminUser` we could create a protocol `MutableAdminUser` which would implement `MutableUser`.
 - You may find it very tempting to actually implement the protocol in the class -- _don't_! While this seems perfectly reasonable, it will change the meta-data for the properties and create issues with the dynamic nature of NTJson properties. Take my word for it here, it may seem to work, but you will have problems.
 - Declaring a `typedef` as an instance of the class that implements the mutable protocol is optional but will simplify the syntax when using the mutable protocol later. The basic format for this with class 'XXX' is `typedef XXX<MutableXXX> *MutableXXX;` Which translates to create a type named `MutableXXX` that is a class `XXX` which implements protocol `MutableXXX`.
 - All NTJson properties in the class _must_ be declared `readonly` if you have a mutable protocol (declared with the `NTJsonMutable` macro.) Any `readwrite` NTJson properties will reqult in an exception the first time the type is accessed.
 - If you create methods that modify the object (mutable), declare the method in the mutable protocol. Since the properties are declared as `readonly` in the class, any attempt to modify the properties -- even in a method you intend to be mutable -- will result in a compiler error. A special property `mutableSelf` will allow you to explicitly access the setters for your properties. ()This is actually your `self` pointer cast to the mutable protocol.)
 

## []Property Conversion

----

While JSON is easy to parse and very universal, it does lack richness. NTJsonModel makes it easy to define converters (or transformers) that are automatically called to convert the underlying JSON to rich values. The system will search for a class method that can satisfy the conversion by checking in three places:

1. Looking for a property-name override on the Model class. The signature convention is `+(id)convert<propertyName>ToJson:(id)json` and `+(id)convertJsonTo<propertyName>(id)json.` Additionally, cached value validation may be optionally done with `+(BOOL)validate<propertyName>JsonValue:(id)value`
2. Looking for a class-name override on the value class. The signature convention is `+(id)convert<className>ToJson:(id)json` and `+(id)convertJsonTo<className>:(id)value.` Additionally, cached value validation may be optionally done with `+(BOOL)validate<className>JsonValue:(id)value`
3. Looking for an implementation of the 'NTJsonPropertyConversion' protocol on the value class. The signature convention is `+(id)convertValueToJson:(id)value` and `+(id)convertJsonToValue:(id)value.` Additionally, cached value validation may be optionally done with `+(BOOL)validateJsonValue:(id)value`

In the following example:

	@interface User : NTJsonModel
	
	@property (nonatomic) NSDate *dateCreated;
	
	@end
	
The system would search for the following selectors:

1. `+(id)convertDateCreatedToJson:(id)json`,  `+(id)convertJsonToDateCreated(id)json` or  `+(BOOL)validateDateCreatedJsonValue:(id)value` in class `User`
2. `+(id)convertNSDateToJson:(id)json`, `+(id)convertJsonToNSDate:(id)value.` or `+(BOOL)validateNSDateJsonValue:(id)value`in class `User`
3. `+(id)convertValueToJson:(id)value`, `+(id)convertJsonToValue:(id)value.` or `+(BOOL)validateJsonValue:(id)value` in class `NSDate`

The system will perform the conversion the first time it reads the value and cache the results, so repeated calls will be effecient. If there is a chance the value could expire, you can implement `-(BOOL)validateJsonValue:(id)value` If implemented this will be called each time the value is accessed; returning `NO` will cause the system to get the latest value 


### [Object Caching](id:object-caching)

The same machinery that allows conversion of primitives such as `NSDate`s, `UIColor`s or `NSURL`'s from and to JSON can be used to cache lookups of objects from a datastore. 

	@interface FeedItem : NTJsonModel
	
	@property (nonatomic) User *user;
	
	@end
	
	@implementation FeedItem
	
	NTJsonProperty(user, jsonPath='user_id', cachedObject=YES)
	
	@end
	
	...

	@implementation User
	
	+(id)convertJsonToValue:(id	)json
	{
		NSString *userId = json;
		NSDictionary *userJson = (get json for User from data store with userId)
		
		return [User modelWithJson:userJson];
	}
	
	+(id)convertValueToJson:(id)value
	{
		User *user = value;
		
		return user.userId;
	}
	

## Polymorphic Objects

----

It's not unusual to have "plymorphic" objects in JSON, where a base class has several descendent classes that vary based on some field (the object type.) NTJsonModel can automatically create the correct descendent class, all you need to do is declare the following method in the base class:

	+(Class)modelClassForJson:(NSDictionary *)json;
	
This method should inspect the json and return the descendent class to create an instance of.

Let's say we have an array of 'Shapes' which may be rectangles or squares. the json might look something like this:

	[
		{"type": "rectangle", "x": 8, "y": 16, "width": 64, "height": 32},
		{"type": "circle", "x": 32, "y": 32, "radius": 16}
	]

Resulting in the following interfaces (excluding mutable protocols here for brevity)

	@interface Shape : NTJsonModel
	@property (nonatomic,readonly) NSString *type;
	@property (nonatomic,readonly) double x;
	@property (nonatomic,readonly) double y;
	@end
	
	@interface Rectangle: Shape
	@property (nonatomic,readonly) double width;
	@property (nonatomic,readonly) double height;
	@end
	
	@interface Circle: Shape
	@property (nonatomic,readonly) double radius;
	@end
	
The Shape implemenation would declare the following:

	+(Class)modelClassForJson:(NSDictionary *)json
	{
		if ( [json[@"type"] isEqualToString:@"rectangle"] )
			return [Rectangle class];
			
		else if ( []json[@"type"] isEqualToString:@"circle"] )
			return [Circle class];
		
		return [Shape class];	// default
	}
	
Now, creating an instance of Shape will actually create the correct type (Rectangle or Circle), depending on the JSON.	
	
Objects may be created based on the JSON content by overriding `+modelClassForJson:`


## Converting Json Arrays

----

NTJsonModel includes helper methods (and classes) that convert an entire array of JSON objects to model objects. These methods return a special implementation of NSArray that is lazy-loaded - the actual NTJsonModel objects are only created as they are referenced. Using our shapes example above, you could write something like:

	NSArray *shapesJson = (get array of JSON objects from somewhere)
	NSArray *shapes = [Shape arayWithJsonArray:shapesJson];
	
	for (Shape *shape in shapes)
	{
		// do something cool
	}
	
In the above example each Shape object will be instantiated as it is used in the loop.


## Odds and Ends

----

* `isEqual:` and `hash` work as expected.
* `description` will output non-default properties and tries hard to output something that is useful. Additionally, `fullDescription` will out a more detailed version, recursing into nested objects and showing the contents of arrays.


