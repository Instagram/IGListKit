#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "OCMock.h"
#import "OCMockObject.h"
#import "OCMArg.h"
#import "OCMConstraint.h"
#import "OCMLocation.h"
#import "OCMMacroState.h"
#import "OCMRecorder.h"
#import "OCMStubRecorder.h"
#import "NSNotificationCenter+OCMAdditions.h"
#import "OCMFunctions.h"

FOUNDATION_EXPORT double OCMockVersionNumber;
FOUNDATION_EXPORT const unsigned char OCMockVersionString[];

