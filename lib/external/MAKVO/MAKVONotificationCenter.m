//
//  MAKVONotificationCenter.m
//  MAKVONotificationCenter
//
//  Created by Michael Ash on 10/15/08.
//  Updated by Neil Edwards 12/03/11

#import "MAKVONotificationCenter.h"
#import "GlobalUtilities.h"

#import <libkern/OSAtomic.h>
#import <objc/message.h>


@interface _MAKVONotificationHelper : NSObject
{
	id			_observer;
	SEL			_selector;
	id			_userInfo;
	
	id			_target;
	NSString*	_keyPath;
}
@property (nonatomic, assign)	id	_observer;
@property (nonatomic, assign)	SEL	_selector;
@property (nonatomic, retain)	id	_userInfo;
@property (nonatomic, assign)	id	_target;
@property (nonatomic, retain)	NSString	*_keyPath;

- (id)initWithObserver:(id)observer object:(id)target keyPath:(NSString *)keyPath selector:(SEL)selector userInfo: (id)userInfo options: (NSKeyValueObservingOptions)options;
- (void)deregister;

@end

@implementation _MAKVONotificationHelper
@synthesize _observer;
@synthesize _selector;
@synthesize _userInfo;
@synthesize _target;
@synthesize _keyPath;

static char MAKVONotificationHelperMagicContext;

- (id)initWithObserver:(id)observer object:(id)target keyPath:(NSString *)keyPath selector:(SEL)selector userInfo: (id)userInfo options: (NSKeyValueObservingOptions)options
{
	if((self = [self init]))
	{
		_observer = observer;
		_selector = selector;
		_userInfo = [userInfo retain];
		
		_target = target;
		_keyPath = [keyPath retain];
		
		[target addObserver:self
				 forKeyPath:keyPath
					options:options
					context:&MAKVONotificationHelperMagicContext];
	}
	return self;
}

- (void)dealloc
{
	[_userInfo release];
	[_keyPath release];
	[super dealloc];
}

#pragma mark -

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	BetterLog(@"");
	
    if(context == &MAKVONotificationHelperMagicContext)
	{
		// we only ever sign up for one notification per object, so if we got here
		// then we *know* that the key path and object are what we want
		// Note:If you see a doesnotRecogniseSelector crash here check the selector is public
		((void (*)(id, SEL, NSString *, id, NSDictionary *, id))objc_msgSend)(_observer, _selector, keyPath, object, change, _userInfo);
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)deregister
{
	
	[_target removeObserver:self forKeyPath:_keyPath];
}

@end


@implementation MAKVONotificationCenter

+ (id)defaultCenter
{
	static MAKVONotificationCenter *center = nil;
	if(!center)
	{
		// do a bit of clever atomic setting to make this thread safe
		// if two threads try to set simultaneously, one will fail
		// and the other will set things up so that the failing thread
		// gets the shared center
		MAKVONotificationCenter *newCenter = [[self alloc] init];
		if(!OSAtomicCompareAndSwapPtrBarrier(nil, newCenter, (void *)&center))
			[newCenter release];
	}
	return center;
}

- (id)init
{
	if((self = [super init]))
	{
		_observerHelpers = [[NSMutableDictionary alloc] init];
		_kvoHelpers=[[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[_observerHelpers release];
	[super dealloc];
}

#pragma mark -



- (id)_dictionaryKeyForObserver:(id)observer object:(id)target keyPath:(NSString *)keyPath selector:(SEL)selector
{
	return [NSString stringWithFormat:@"%p:%p:%@:%p", observer, target, keyPath, selector];
}

- (void)addObserver:(id)observer object:(id)target keyPath:(NSString *)keyPath selector:(SEL)selector userInfo: (id)userInfo options: (NSKeyValueObservingOptions)options
{
	id key = [self _dictionaryKeyForObserver:observer object:target keyPath:keyPath selector:selector];
	// only set observer if not aready set
	if([_observerHelpers objectForKey:key]==nil){
		
		_MAKVONotificationHelper *helper = [[_MAKVONotificationHelper alloc] initWithObserver:observer object:target keyPath:keyPath selector:selector userInfo:userInfo options:options];
		
		@synchronized(self)
		{
			
			[_observerHelpers setObject:helper forKey:key];
			[self addEntryForHelper:helper];
		}
		[helper release];
	}
}

- (void)removeObserver:(id)observer object:(id)target keyPath:(NSString *)keyPath selector:(SEL)selector
{
	
	
	id key = [self _dictionaryKeyForObserver:observer object:target keyPath:keyPath selector:selector];
	_MAKVONotificationHelper *helper = nil;
	@synchronized(self)
	{
		helper = [[_observerHelpers objectForKey:key] retain];
		[_observerHelpers removeObjectForKey:key];
		[self removeEntryForHelper:helper];
	}
	
	[helper release];
}


//
/***********************************************
 * @description			NE: NEW CODE
 ***********************************************/
//


-(void)addEntryForHelper:(_MAKVONotificationHelper*)helper{
	
	NSString *targetkey=[NSString stringWithFormat:@"%p",helper._target];
	NSString *observerkey=[NSString stringWithFormat:@"%p",helper._observer];
	NSString *propertykey=[NSString stringWithFormat:@"%p",helper._keyPath];
	
	NSMutableDictionary *observersdict=[_kvoHelpers objectForKey:targetkey];
	if(observersdict==nil){
		
		NSMutableDictionary *observerdict=[[NSMutableDictionary alloc]initWithObjectsAndKeys:helper,propertykey,nil];
		NSMutableDictionary *newobserversdict=[[NSMutableDictionary alloc]initWithObjectsAndKeys:observerdict,observerkey,nil];
		[observerdict release];
		[_kvoHelpers setObject:newobserversdict forKey:targetkey];
		[newobserversdict release];
		
		
	}else {
		
		NSMutableDictionary *observerdict=[observersdict objectForKey:observerkey];
		if(observerdict==nil){
			NSMutableDictionary *observerdict=[[NSMutableDictionary alloc]initWithObjectsAndKeys:helper,propertykey,nil];
			[observersdict setObject:observerdict forKey:observerkey];
			[observerdict release];
			
		}else {
			NSMutableDictionary *propertydict=[observerdict objectForKey:propertykey];
			if(propertydict==nil){
				[observerdict setObject:helper forKey:propertykey];
			}else {
				BetterLog(@"We're already observing this property!");
			}
		}

	}

}



//
/***********************************************
 * @description			Removes all observers from a target: use when a target is about to be dealloced
 ***********************************************/
//
-(void)removeAllObserversForTarget:(id)target{
	
	NSString	*targetKey=[NSString stringWithFormat:@"%p",target];
	NSString *observers=[_kvoHelpers objectForKey:targetKey];
	
	if(observers!=nil){
		_MAKVONotificationHelper *helper = nil;
		NSMutableDictionary *observersDict=[_kvoHelpers objectForKey:targetKey];
		
		for (NSString *observerKey in observersDict) {
			
			NSMutableDictionary *observerDict=[observersDict objectForKey:observerKey];
			
			for(NSString *property in observerDict){
				
				helper=[observerDict objectForKey:property];
				[helper deregister];
				
			}
		}
		
		[_kvoHelpers removeObjectForKey:targetKey];
		
	}
	
}


//
/***********************************************
 * @description			Remove all targets from an observer> cleans up all keypath observers
 ***********************************************/
//
-(void)removeAllTargetsForObserver:(id)observer{
	NSString	*observerkey=[NSString stringWithFormat:@"%p",observer];
	
	for(NSString *targetKey in _kvoHelpers){
		
		NSMutableDictionary *targetDict=[_kvoHelpers objectForKey:targetKey];
		
		if([targetDict objectForKey:observerkey]!=nil){
			[self removeAllPropertiesForObserver:[targetDict objectForKey:observerkey]];
			[targetDict removeObjectForKey:observerkey];
		}
		
	}
	
}

//
/***********************************************
 * @description			Remove all observers for a property on a target
 ***********************************************/
//
-(void)removeAllObserversOnProperty:(NSString*)keyPath forTarget:(id)target{
	
	NSString	*targetKey=[NSString stringWithFormat:@"%p",target];
	NSMutableDictionary *observers=[_kvoHelpers objectForKey:targetKey];
	
	if(observers!=nil){
		
		for(NSString *observerKey in observers){
			
			NSMutableDictionary *observerDict=[observers objectForKey:observerKey];
			
			[self removePropertyForObserver:observerDict forKeyPath:keyPath];
		}
		
	}
	
}


//
/***********************************************
 * @description			Removes All observed properties from an observer
 ***********************************************/
//
-(void)removeAllPropertiesForObserver:(NSMutableDictionary*)observerdict{
	
	for (NSString *keyPath in observerdict){
		[self removePropertyForObserver:observerdict forKeyPath:keyPath];
	}
	
}
				

//
/***********************************************
 * @description			Removes individual property observing for an observer
 ***********************************************/
//
-(void)removePropertyForObserver:(NSMutableDictionary*)observerDict forKeyPath:(NSString*)keyPath{
	
	if(observerDict!=nil){
		_MAKVONotificationHelper *helper=[observerDict objectForKey:keyPath];
		if(helper!=nil)
			[helper deregister];
	}
	
}
			
//
/***********************************************
 * @description			Find and remove a specific observer of a property for a target
 ***********************************************/
//

-(void)removeEntryForHelper:(_MAKVONotificationHelper*)helper{
	[self removeObserver:helper._observer forTarget:helper._target forProperty:helper._keyPath];
}

-(void)removeObserver:(id)observer forTarget:(id)target forProperty:(NSString*)keyPath{
	
	NSString	*targetKey=[NSString stringWithFormat:@"%p",target];
	NSMutableDictionary *observers=[_kvoHelpers objectForKey:targetKey];
	
	if(observers!=nil){
		_MAKVONotificationHelper *helper = nil;
		
		NSMutableDictionary *observerdict=[observers objectForKey:[NSString stringWithFormat:@"%p",observer]];
		
		if(observerdict!=nil){
			helper=[[observerdict objectForKey:keyPath] objectForKey:@"helper"];
			if(helper!=nil)
				[helper deregister];
		}
		[observerdict removeObjectForKey:keyPath];
	}
}

@end

@implementation NSObject (MAKVONotification)

- (void)addObserver:(id)observer forKeyPath:(NSString *)keyPath selector:(SEL)selector userInfo:(id)userInfo options:(NSKeyValueObservingOptions)options
{
	[[MAKVONotificationCenter defaultCenter] addObserver:observer object:self keyPath:keyPath selector:selector userInfo:userInfo options:options];
}

- (void)removeObserver:(id)observer keyPath:(NSString *)keyPath selector:(SEL)selector
{
	[[MAKVONotificationCenter defaultCenter] removeObserver:observer object:self keyPath:keyPath selector:selector];
}

@end