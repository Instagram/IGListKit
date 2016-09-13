/*
 *  Copyright (c) 2009-2016 Erik Doernenburg and contributors
 *
 *  Licensed under the Apache License, Version 2.0 (the "License"); you may
 *  not use these files except in compliance with the License. You may obtain
 *  a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 *  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 *  License for the specific language governing permissions and limitations
 *  under the License.
 */

#import <objc/runtime.h>
#import "OCMockObject.h"
#import "OCPartialMockObject.h"
#import "NSMethodSignature+OCMAdditions.h"
#import "NSObject+OCMAdditions.h"
#import "OCMFunctionsPrivate.h"
#import "OCMInvocationStub.h"


@implementation OCPartialMockObject

#pragma mark  Initialisers, description, accessors, etc.

- (id)initWithObject:(NSObject *)anObject
{
    NSParameterAssert(anObject != nil);
    [self assertClassIsSupported:[anObject class]];
	[super initWithClass:[anObject class]];
	realObject = [anObject retain];
    [self prepareObjectForInstanceMethodMocking];
	return self;
}

- (void)dealloc
{
	[self stopMocking];
	[realObject release];
	[super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"OCPartialMockObject(%@)", NSStringFromClass(mockedClass)];
}

- (NSObject *)realObject
{
	return realObject;
}

#pragma mark  Helper methods

- (void)assertClassIsSupported:(Class)class
{
    NSString *classname = NSStringFromClass(class);
    NSString *reason = nil;
    if([classname hasPrefix:@"__NSTagged"] || [classname hasPrefix:@"NSTagged"])
        reason = [NSString stringWithFormat:@"OCMock does not support partially mocking tagged classes; got %@", classname];
    else if([classname hasPrefix:@"__NSCF"])
        reason = [NSString stringWithFormat:@"OCMock does not support partially mocking toll-free bridged classes; got %@", classname];

    if(reason != nil)
        [[NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil] raise];
}


#pragma mark  Extending/overriding superclass behaviour

- (void)stopMocking
{
    if(realObject != nil)
    {
        Class partialMockClass = object_getClass(realObject);
        OCMSetAssociatedMockForObject(nil, realObject);
        object_setClass(realObject, [self mockedClass]);
        [realObject release];
        realObject = nil;
        objc_disposeClassPair(partialMockClass);
    }
    [super stopMocking];
}

- (void)addStub:(OCMInvocationStub *)aStub
{
    [super addStub:aStub];
    if(![aStub recordedAsClassMethod])
        [self setupForwarderForSelector:[[aStub recordedInvocation] selector]];
}

- (void)handleUnRecordedInvocation:(NSInvocation *)anInvocation
{
	[anInvocation invokeWithTarget:realObject];
}


#pragma mark  Subclass management

- (void)prepareObjectForInstanceMethodMocking
{
    OCMSetAssociatedMockForObject(self, realObject);

    /* dynamically create a subclass and set it as the class of the object */
    Class subclass = OCMCreateSubclass(mockedClass, realObject);
	object_setClass(realObject, subclass);

    /* point forwardInvocation: of the object to the implementation in the mock */
	Method myForwardMethod = class_getInstanceMethod([self mockObjectClass], @selector(forwardInvocationForRealObject:));
	IMP myForwardIMP = method_getImplementation(myForwardMethod);
    class_addMethod(subclass, @selector(forwardInvocation:), myForwardIMP, method_getTypeEncoding(myForwardMethod));

    /* do the same for forwardingTargetForSelector, remember existing imp with alias selector */
    Method myForwardingTargetMethod = class_getInstanceMethod([self mockObjectClass], @selector(forwardingTargetForSelectorForRealObject:));
    IMP myForwardingTargetIMP = method_getImplementation(myForwardingTargetMethod);
    IMP originalForwardingTargetIMP = [mockedClass instanceMethodForSelector:@selector(forwardingTargetForSelector:)];
    class_addMethod(subclass, @selector(forwardingTargetForSelector:), myForwardingTargetIMP, method_getTypeEncoding(myForwardingTargetMethod));
    class_addMethod(subclass, @selector(ocmock_replaced_forwardingTargetForSelector:), originalForwardingTargetIMP, method_getTypeEncoding(myForwardingTargetMethod));

    /* We also override the -class method to return the original class */
    Method myObjectClassMethod = class_getInstanceMethod([self mockObjectClass], @selector(classForRealObject));
    const char *objectClassTypes = method_getTypeEncoding(myObjectClassMethod);
    IMP myObjectClassImp = method_getImplementation(myObjectClassMethod);
    class_addMethod(subclass, @selector(class), myObjectClassImp, objectClassTypes);

    /* Adding forwarder for most instance methods to allow for verify after run */
    NSArray *methodBlackList = @[@"class", @"forwardingTargetForSelector:", @"methodSignatureForSelector:", @"forwardInvocation:",
            @"allowsWeakReference", @"retainWeakReference", @"isBlock", @"retainCount", @"retain", @"release", @"autorelease"];
    [NSObject enumerateMethodsInClass:mockedClass usingBlock:^(Class cls, SEL sel) {
        if((cls == [NSObject class]) || (cls == [NSProxy class]))
            return;
        NSString *className = NSStringFromClass(cls);
        NSString *selName = NSStringFromSelector(sel);
        if(([className hasPrefix:@"NS"] || [className hasPrefix:@"UI"]) &&
           ([selName hasPrefix:@"_"] || [selName hasSuffix:@"_"]))
            return;
        if([methodBlackList containsObject:selName])
            return;
        @try
        {
            [self setupForwarderForSelector:sel];
        }
        @catch(NSException *e)
        {
            // ignore for now
        }
    }];
}

- (void)setupForwarderForSelector:(SEL)sel
{
    SEL aliasSelector = OCMAliasForOriginalSelector(sel);
    if(class_getInstanceMethod(object_getClass(realObject), aliasSelector) != NULL)
        return;

    Method originalMethod = class_getInstanceMethod(mockedClass, sel);
	IMP originalIMP = method_getImplementation(originalMethod);
    const char *types = method_getTypeEncoding(originalMethod);
    /* Might be NULL if the selector is forwarded to another class */
    // TODO: check the fallback implementation is actually sufficient
    if(types == NULL)
        types = ([[mockedClass instanceMethodSignatureForSelector:sel] fullObjCTypes]);

    Class subclass = object_getClass([self realObject]);
    IMP forwarderIMP = [mockedClass instanceMethodForwarderForSelector:sel];
    class_replaceMethod(subclass, sel, forwarderIMP, types);
	class_addMethod(subclass, aliasSelector, originalIMP, types);
}


// Implementation of the -class method; return the Class that was reported with [realObject class] prior to mocking
- (Class)classForRealObject
{
    // in here "self" is a reference to the real object, not the mock
    OCPartialMockObject *mock = OCMGetAssociatedMockForObject(self);
    if(mock == nil)
        [NSException raise:NSInternalInconsistencyException format:@"No partial mock for object %p", self];
    return [mock mockedClass];
}


- (id)forwardingTargetForSelectorForRealObject:(SEL)sel
{
	// in here "self" is a reference to the real object, not the mock
    OCPartialMockObject *mock = OCMGetAssociatedMockForObject(self);
    if(mock == nil)
        [NSException raise:NSInternalInconsistencyException format:@"No partial mock for object %p", self];
    if([mock handleSelector:sel])
        return self;

    return [self ocmock_replaced_forwardingTargetForSelector:sel];
}

//  Make the compiler happy in -forwardingTargetForSelectorForRealObject: because it can't find the message…
- (id)ocmock_replaced_forwardingTargetForSelector:(SEL)sel
{
    return nil;
}


- (void)forwardInvocationForRealObject:(NSInvocation *)anInvocation
{
	// in here "self" is a reference to the real object, not the mock
    OCPartialMockObject *mock = OCMGetAssociatedMockForObject(self);
    if(mock == nil)
        [NSException raise:NSInternalInconsistencyException format:@"No partial mock for object %p", self];

	if([mock handleInvocation:anInvocation] == NO)
    {
        [anInvocation setSelector:OCMAliasForOriginalSelector([anInvocation selector])];
        [anInvocation invoke];
    }
}


@end
