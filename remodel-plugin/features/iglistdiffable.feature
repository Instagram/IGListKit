Feature: Outputting Value Objects implementing IGListDiffable

  @announce
  Scenario: Generating a value object, which correctly implements IGListDiffable using the specified diffIdentifier
    Given a file named "project/values/Test.value" with:
      """
      Test includes(IGListDiffable) {
        CGRect someRect
        %diffIdentifier
        NSString *stringOne
      }
      """
    When I run `../../bin/generate project`
    Then the file "project/values/Test.h" should contain:
      """
      #import <Foundation/Foundation.h>
      #import <CoreGraphics/CGGeometry.h>
      #import <IGListKit/IGListDiffable.h>

      @interface Test : NSObject <IGListDiffable, NSCopying>

      @property (nonatomic, readonly) CGRect someRect;
      @property (nonatomic, readonly, copy) NSString *stringOne;

      + (instancetype)new NS_UNAVAILABLE;

      - (instancetype)init NS_UNAVAILABLE;

      - (instancetype)initWithSomeRect:(CGRect)someRect stringOne:(NSString *)stringOne NS_DESIGNATED_INITIALIZER;

      @end

      """
   And the file "project/values/Test.m" should contain:
      """
      @implementation Test

      - (instancetype)initWithSomeRect:(CGRect)someRect stringOne:(NSString *)stringOne
      {
        if ((self = [super init])) {
          _someRect = someRect;
          _stringOne = [stringOne copy];
        }

        return self;
      }

      - (id)copyWithZone:(nullable NSZone *)zone
      {
        return self;
      }

      - (NSString *)description
      {
        return [NSString stringWithFormat:@"%@ - \n\t someRect: %@; \n\t stringOne: %@; \n", [super description], NSStringFromCGRect(_someRect), _stringOne];
      }

      - (id<NSObject>)diffIdentifier
      {
        return _stringOne;
      }

      - (NSUInteger)hash
      {
        NSUInteger subhashes[] = {HashCGFloat(_someRect.origin.x), HashCGFloat(_someRect.origin.y), HashCGFloat(_someRect.size.width), HashCGFloat(_someRect.size.height), [_stringOne hash]};
        NSUInteger result = subhashes[0];
        for (int ii = 1; ii < 5; ++ii) {
          unsigned long long base = (((unsigned long long)result) << 32 | subhashes[ii]);
          base = (~base) + (base << 18);
          base ^= (base >> 31);
          base *=  21;
          base ^= (base >> 11);
          base += (base << 6);
          base ^= (base >> 22);
          result = base;
        }
        return result;
      }

      - (BOOL)isEqual:(Test *)object
      {
        if (self == object) {
          return YES;
        } else if (self == nil || object == nil || ![object isKindOfClass:[self class]]) {
          return NO;
        }
        return
          CGRectEqualToRect(_someRect, object->_someRect) &&
          (_stringOne == object->_stringOne ? YES : [_stringOne isEqual:object->_stringOne]);
      }

      - (BOOL)isEqualToDiffableObject:(nullable id)object
      {
        return [self isEqual:object];
      }

      @end

      """

  Scenario: Generating a value object, which correctly implements IGListDiffable using a CGRect property
    Given a file named "project/values/Test.value" with:
      """
      Test includes(IGListDiffable) {
        %diffIdentifier
        CGRect someRect
      }
      """
    When I run `../../bin/generate project`
    Then the file "project/values/Test.h" should contain:
      """
      #import <Foundation/Foundation.h>
      #import <CoreGraphics/CGGeometry.h>
      #import <IGListKit/IGListDiffable.h>

      @interface Test : NSObject <IGListDiffable, NSCopying>

      @property (nonatomic, readonly) CGRect someRect;

      + (instancetype)new NS_UNAVAILABLE;

      - (instancetype)init NS_UNAVAILABLE;

      - (instancetype)initWithSomeRect:(CGRect)someRect NS_DESIGNATED_INITIALIZER;

      @end

      """
   And the file "project/values/Test.m" should contain:
      """
      @implementation Test

      - (instancetype)initWithSomeRect:(CGRect)someRect
      {
        if ((self = [super init])) {
          _someRect = someRect;
        }

        return self;
      }

      - (id)copyWithZone:(nullable NSZone *)zone
      {
        return self;
      }

      - (NSString *)description
      {
        return [NSString stringWithFormat:@"%@ - \n\t someRect: %@; \n", [super description], NSStringFromCGRect(_someRect)];
      }

      - (id<NSObject>)diffIdentifier
      {
        return NSStringFromCGRect(_someRect);
      }

      - (NSUInteger)hash
      {
        NSUInteger subhashes[] = {HashCGFloat(_someRect.origin.x), HashCGFloat(_someRect.origin.y), HashCGFloat(_someRect.size.width), HashCGFloat(_someRect.size.height)};
        NSUInteger result = subhashes[0];
        for (int ii = 1; ii < 4; ++ii) {
          unsigned long long base = (((unsigned long long)result) << 32 | subhashes[ii]);
          base = (~base) + (base << 18);
          base ^= (base >> 31);
          base *=  21;
          base ^= (base >> 11);
          base += (base << 6);
          base ^= (base >> 22);
          result = base;
        }
        return result;
      }

      - (BOOL)isEqual:(Test *)object
      {
        if (self == object) {
          return YES;
        } else if (self == nil || object == nil || ![object isKindOfClass:[self class]]) {
          return NO;
        }
        return
          CGRectEqualToRect(_someRect, object->_someRect);
      }

      - (BOOL)isEqualToDiffableObject:(nullable id)object
      {
        return [self isEqual:object];
      }

      @end

      """

  Scenario: Generating a value object, which correctly implements IGListDiffable defaulting to self as diffIdentifier
    Given a file named "project/values/Test.value" with:
      """
      Test includes(IGListDiffable) {
        CGRect someRect
      }
      """
    When I run `../../bin/generate project`
    Then the file "project/values/Test.h" should contain:
      """
      #import <Foundation/Foundation.h>
      #import <CoreGraphics/CGGeometry.h>
      #import <IGListKit/IGListDiffable.h>

      @interface Test : NSObject <IGListDiffable, NSCopying>

      @property (nonatomic, readonly) CGRect someRect;

      + (instancetype)new NS_UNAVAILABLE;

      - (instancetype)init NS_UNAVAILABLE;

      - (instancetype)initWithSomeRect:(CGRect)someRect NS_DESIGNATED_INITIALIZER;

      @end

      """
   And the file "project/values/Test.m" should contain:
      """
      @implementation Test

      - (instancetype)initWithSomeRect:(CGRect)someRect
      {
        if ((self = [super init])) {
          _someRect = someRect;
        }

        return self;
      }

      - (id)copyWithZone:(nullable NSZone *)zone
      {
        return self;
      }

      - (NSString *)description
      {
        return [NSString stringWithFormat:@"%@ - \n\t someRect: %@; \n", [super description], NSStringFromCGRect(_someRect)];
      }

      - (id<NSObject>)diffIdentifier
      {
        return self;
      }

      - (NSUInteger)hash
      {
        NSUInteger subhashes[] = {HashCGFloat(_someRect.origin.x), HashCGFloat(_someRect.origin.y), HashCGFloat(_someRect.size.width), HashCGFloat(_someRect.size.height)};
        NSUInteger result = subhashes[0];
        for (int ii = 1; ii < 4; ++ii) {
          unsigned long long base = (((unsigned long long)result) << 32 | subhashes[ii]);
          base = (~base) + (base << 18);
          base ^= (base >> 31);
          base *=  21;
          base ^= (base >> 11);
          base += (base << 6);
          base ^= (base >> 22);
          result = base;
        }
        return result;
      }

      - (BOOL)isEqual:(Test *)object
      {
        if (self == object) {
          return YES;
        } else if (self == nil || object == nil || ![object isKindOfClass:[self class]]) {
          return NO;
        }
        return
          CGRectEqualToRect(_someRect, object->_someRect);
      }

      - (BOOL)isEqualToDiffableObject:(nullable id)object
      {
        return [self isEqual:object];
      }

      @end

      """
