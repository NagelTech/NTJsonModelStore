NTJsonModel
===========

[in development] A high performance model object wrapper for JSON.


To Do
-----

- Make mutability explicit. objects may be created read-only (initWithJson:) or mutable (initMutableWthJson:).  mutableCopy or copy to convert.
  Mutable objects rely on the cache for reading and writing values, json is ceated on demand. This maintains the performance for read-only cases
  and handles lots ot edge cases the "becomeMutable" approach struggles with. This is at the expense of some simplicity for the developer.

- Add capability to validate cached values (have they changed). This would be a part of the conversion machinery in NTJsonProp. This will allow us
to check isJsonValid for cached objects and re-get them when needed.

 - Handle cases where multiple properties point to the same JsonKeyPath. The Cache would need to be cleared for all matching properties
   when the underlying json is changed. This will make creating look up properties (where only the ID is in the JSON) work well. In order
   to make look up properties work well, we may also need to add the ability to do cache expiration.
 
 - Add a method to be easily notified when properties are changed? Technically KVO can do the job, but it's so clumsy and we can't allow
   the user to override existing properties... or can we?
   
 - need to make sure everything is threadsafe. (Or not?)

 - add tests for arrays that are members of a model. (Test JsonContainer functionality)
 
Done-ish
--------
   
 - ~~Continuing on ideas for optimizing for read-only modes. Instances are created as immutable by default, there
   is an explicit action to make mutable (mutableCopy.) In mutable mode, we can eliminate caching to simplify things.
   This removes the requirement for the "rootModel" pointer and also will get us to one pointer for the dictionary 
   (which is either mutable or not.) init creates mutable instances, also mutableModelWithJson:.~~
   
 - ~~need to handle setting a "normal" array of object into an array (a transformation I suppose.)~~
   
 - ~~Many complications arise from supporting immutable and mutable modes. Actually many complications arise from supporting
   the mutable mode. Read only objects would be much simpler to maintain.~~ Solution: ~~objects must be copied to move between
   mutable and immutable states.~~ Well "becomeMutable" seems to be possible after all.
   
 - ~~Array performance may suffer when doing things like sorting (sorting an array of items within a root model.)~~ Handled
 by requiring the mutableCopy and restructuring now array caching is done (eliminate sparse array)
 
  - ~~Lots of work to do on transforming values still (only a couple type are supported and no transformations.)~~
  
  - ~~We can use an associated objects as our cache store.~~
   
  - ~~Need to detect when properties are defined without @dynamic - these will have properties and
 a backing store. throw exception.~~
 
  - ~~Best case for property access performance is NSDictionary access. Minimum would be 1 lookup for the property info
   and a second one to get the property value (either from the cache or from the dictionary its self.)~~

 - ~~Need to work out exactly how properties will be defined. (What is the right mix between "magical"
 syntax and explicit declarations?)~~

 - ~~Store meta data using magical macros ;)~~

 - ~~Object Arrays need work. They need to use NTJsonModelArray and work basically the same way. Disabled for now.~~



 

 

