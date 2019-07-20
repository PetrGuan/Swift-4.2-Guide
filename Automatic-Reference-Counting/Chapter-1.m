// You have ownership of the object.
id obj = [[NSObject alloc] init];

// You have ownership of the object.
id obj = [NSObject new];

// Obtain an object without creating it yourself or having ownership
id obj = [NSMutableArray array];
[obj retain]; // now you have ownership of it.

id obj = [[NSObject alloc] init];
[obj release]; // now the object is relinquished, you cannot access it anymore.

- (id)object
{
    id obj = [[NSObject alloc] init];
    // The obj exists, and you don't have ownership of it.
    [obj autorelease]; // Register to a release pool
    return obj;
}

+ (id)alloc
{
    return [self allocWithZone: NSDefaultMallocZone()];
}

+ (id)allocWithZone:(NSZone *)z
{
    return NSAllocateObject(self, 0, z);
}

struct obj_layout
{
    NSUInteger retained;
};

inline id
NSAllocateObject(Class aClass, NSUInteger extraBytes, NSZone *zone)
{
    int size = /* needed size to store the object */;
    id new = NSZoneMalloc(zone, size);
    memset(new, 0, size);
    new = (id)&((struct obj_layout *)new)[1];
}

// Without Zone, no need to prevent fragmentation
+ (id)alloc
{
    int size = sizeof(struct obj_layout) + size_of_the_object;
    struct obj_layout *p = (struct obj_layout *)calloc(1, size);
    return (id)(p + 1);
}

id obj = [[NSObject alloc] init];
// retainCount=1 is displayed.
NSLog(@"retainCount=%d", [obj retainCount]);

// NSObject.m retainCount
- (NSUInteger)retainCount
{
    return NSExtraRefCount(self) + 1;
}

inline NSUInteger
NSExtraRefCount(id anObject)
{
    return ((struct obj_layout *)anObject)[-1].retained;
}

- (id)retain
{
    NSIncrementExtraRefCount(self);
    return self;
}

inline void
NSIncrementExtraRefCount(id anObject)
{
    if (((struct obj_layout *)anObject)[-1].retained == UINT_MAX - 1)
    {
        [NSException raise: NSInternalInconsistencyException format: @"NSIncrementExtraRefCount() asked to increment too far"];
    }
    ((struct obj_layout *)anObject)[-1].retained++;
}

- (void)release
{
    if (NSDecrementExtraRefCountWasZero(self))
    {
        [self dealloc];    
    }
}

inline BOOL
NSDecrementExtraRefCountWasZero(id anObject)
{
    if (((struct obj_layout *)anObject)[-1].retained == 0)
    {
        return YES;
    }
    else
    {
        ((struct obj_layout *)anObject)[-1].retained--;
        return NO;
    }
}

- (void)dealloc
{
    NSDeallocateObject(self);
}

inline void
NSDeallocateObject(id anObject)
{
    struct obj_layout *o = &((struct obj_layout *)anObject)[-1];
    // Dispose of a memory block
    free(o);
}

NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
id obj = [[NSObject alloc] init];
[obj autorelease];
[pool drain]; // Will release all registered obj

// NSObject.m 
- (id)autorelease
{
    [NSAutoreleasePool addObject:self];
}

// NSAutoreleasePool.m
+ (void)addObject:(id anObj)
{
    NSAutoreleasePool *pool = getting active NSAutoreleasePool;
    if (pool != nil)
    {
        [pool addObject:anObj];
    }
    else
    {
        // Log
    }
}

