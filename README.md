# NTJsonModelStore


Provides a JSON-Based Schemaless store, with integrated model objects.

This library is a thin layer combining two independent but complementary projects:

 - **[NTJsonStore](https://github.com/NagelTech/NTJsonStore)** - a schemaless document-oriented data store that will be immediately familiar of you have used MongoDB or similar systems.
 - **[NTJsonModel](https://github.com/NagelTech/NTJsonModel)** - an easy-to-use wrapper for JSON objects. It features an intuitive model for declaring properties and works to preserve the original JSON. NTJsonModel is unique in that it supports both immutable and mutable states for objects and gives you the tools to make this practical for model objects. If you take advantage of these features you can have immutable model objects, only "mutating" them in specific contexts, similar to the approach you would see in functional languages.
 
You will find that the whole is greater than the sum of the parts.

## [Overview](id: overview)

NTJsonModelStore is a schemaless document-oriented data store that will be immediately familiar of you have used MongoDB or similar systems. Result JSON documents are wrapped in an easy-to-use and high-performance wrapper - NTJONModels. It features an intuitive model for declaring properties and works to preserve the original JSON.
The models ojects returned are unique in that they support both immutable and mutable states for objects and gives you the tools to make this practical for model objects. If you take advantage of these features you can have immutable model objects, only "mutating" them in specific contexts, similar to the approach you would see in functional languages.

Key features include:
 
 - **Document-oriented JSON storage.** the underlyig JSON is stored as JSON-compliant NSDictionaries. (Anything that could be returned by `NSJSONSerialization` is supported - `NSNull`, `NSString`, `NSNumber`, `NSArray` and `NSDictionary`.) 
 - **Flexible & safe model objects.** Documents are returned as NTJsonModel objects which are a wrapper around the existing JSON-compliant dictionary. All model objects are returned as in an immutable state, helping you make your code more predictable. (Results may be mutated using `mutableCopy` or some convenient helper functions - see `mutate:`)
 - **Full index support.** Data is ultimately stored in SQLITE, so you get the full performance and flexibility of SQLITE indexes. Unique and non-unique indexes, multiple keys and keys that are nested in the JSON are all supported.
 - **Flexible queries.** Queries may contain any value that appears in your JSON document, including nested values using dot notation. Anything that is allowed in a SQLITE WHERE clause is allowed, as long as you stick to a single collection (TABLE.)
 - **Reduced upgrade headaches.** Because the data is essentially schemaless, you are not required to "upgrade" the data store with application updates. Of course this might put an additional burden on the code that is using the data because you may encounter old or new data, but it's usually easy enough to work around. Say goodbye to complex [Core Data Migrations](http://www.objc.io/issue-4/core-data-migration.html).
 - **Simple multi-threading support.** Any call may be performed synchronously or asynchronously. The system will make sure operations for each collection happen in the same order. There is no concept of multiple contexts to deal with. A simpler model means you don't spend hours debugging things like [Core Data's context merge nightmare](http://stackoverflow.com/questions/24657437/core-data-background-context-best-practice).
 - **Declarative configuration.** All configuration (property mapping, indexes, etc) can be done right along with your model class implementation using some fancy macros.
 
 ## A Simple example
 
Let's take a look at NTJsonModelStore in action...

	@interface User : NTJsonStorableModel
	
	@property (nonatomic,readonly) NSString *firstName;
	@property (nonatomic,readonly) NSString *lastName;
	@property (nonatomic,readonly) int age;

	@end
	
	@protocol MutableUser <NTJsonMutableStorableModel>

	@property (nonatomic) NSString *firstName;
	@property (nonatomic) NSString *lastName;
	@property (nonatomic) int age;

	@end
	
	typedef User<MutableUser> MutableUser;
	
	...
	
	@implementation User
	
	NTJsonMutable(MutableUser)	
	
	NTJsonProperty(firstName)
	NTJsonProperty(lastName)
	NTJsonProperty(age)
	
	NTJsonIndex(lastName, firstName)
	
	@end
	
	...
	
	-(void)incrementAgesWithPrefix:(NSString *)prefix
	{
		NSArray *users = [User findWhere:@"lastName LIKE ?" args:@[prefix stringByAppendingString:@"%"]]];
		
		for(User *user in users)
		{
			User *updatedUser = [user mutate:id ^(MutableUser *)mutable {
				++mutable.age;
			})];
			
			[User update:updatedUser];
		}
	}
	

