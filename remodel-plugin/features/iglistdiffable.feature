# Copyright (c) Facebook, Inc. and its affiliates. All Rights Reserved.

Feature: Outputting Value Objects implementing IGListDiffable

  @announce
  Scenario: Generating a value object, which correctly implements IGListDiffable using the specified diffIdentifier
    Given a file named "project/values/IGListDiffableTest.value" with:
      """
      IGListDiffableTest includes(IGListDiffable) {
        CGRect someRect
        %diffIdentifier NSString *stringOne
      }
      """
    When I run `../../bin/generate project`
    Then the file "project/values/IGListDiffableTest.h" should contain:
      """

      #import <Foundation/Foundation.h>
      #import <CoreGraphics/CGGeometry.h>
      #import <IGListKit/IGListDiffable.h>

      @interface IGListDiffableTest : NSObject <IGListDiffable, NSCopying>

      @property (nonatomic, readonly) CGRect someRect;
      @property (nonatomic, readonly, copy) NSString *stringOne;

      + (instancetype)new NS_UNAVAILABLE;

      - (instancetype)init NS_UNAVAILABLE;

      - (instancetype)initWithSomeRect:(CGRect)someRect stringOne:(NSString *)stringOne NS_DESIGNATED_INITIALIZER;

      @end

      """
    And the file "project/values/IGListDiffableTest.m" should contain:
      """
      - (id<NSObject>)diffIdentifier
      {
        return _stringOne;
      }
      """
    And the file "project/values/IGListDiffableTest.m" should contain:
      """
      - (BOOL)isEqualToDiffableObject:(nullable id<IGListDiffable>)object
      {
        return [self isEqual:object];
      }
      """

  Scenario: Generating a value object, which correctly implements IGListDiffable using a CGRect property
    Given a file named "project/values/IGListDiffableTest2.value" with:
      """
      IGListDiffableTest2 includes(IGListDiffable) {
        %diffIdentifier CGRect someRect
      }
      """
    When I run `../../bin/generate project`
    Then the file "project/values/IGListDiffableTest2.h" should contain:
      """

      #import <Foundation/Foundation.h>
      #import <CoreGraphics/CGGeometry.h>
      #import <IGListKit/IGListDiffable.h>

      @interface IGListDiffableTest2 : NSObject <IGListDiffable, NSCopying>

      @property (nonatomic, readonly) CGRect someRect;

      + (instancetype)new NS_UNAVAILABLE;

      - (instancetype)init NS_UNAVAILABLE;

      - (instancetype)initWithSomeRect:(CGRect)someRect NS_DESIGNATED_INITIALIZER;

      @end
      """
    And the file "project/values/IGListDiffableTest2.m" should contain:
      """
      - (id<NSObject>)diffIdentifier
      {
        return [NSValue valueWithCGRect:_someRect];
      }
      """
    And the file "project/values/IGListDiffableTest2.m" should contain:
      """
      - (BOOL)isEqualToDiffableObject:(nullable id<IGListDiffable>)object
      {
        return [self isEqual:object];
      }
      """

  Scenario: Generating a value object, which correctly implements IGListDiffable using an NSInteger property
    Given a file named "project/values/IGListDiffableTest3.value" with:
      """
      IGListDiffableTest3 includes(IGListDiffable) {
        %diffIdentifier NSInteger count
      }
      """
    When I run `../../bin/generate project`
    Then the file "project/values/IGListDiffableTest3.m" should contain:
      """
      - (id<NSObject>)diffIdentifier
      {
        return @(_count);
      }
      """
    And the file "project/values/IGListDiffableTest3.m" should contain:
      """
      - (BOOL)isEqualToDiffableObject:(nullable id<IGListDiffable>)object
      {
        return [self isEqual:object];
      }
      """

  Scenario: Generating a value object, which correctly implements IGListDiffable defaulting to self as diffIdentifier
    Given a file named "project/values/IGListDiffableTest4.value" with:
      """
      IGListDiffableTest4 includes(IGListDiffable) {
        CGRect someRect
      }
      """
    When I run `../../bin/generate project`
    Then the file "project/values/IGListDiffableTest4.h" should contain:
      """
      #import <Foundation/Foundation.h>
      #import <CoreGraphics/CGGeometry.h>
      #import <IGListKit/IGListDiffable.h>

      @interface IGListDiffableTest4 : NSObject <IGListDiffable, NSCopying>

      @property (nonatomic, readonly) CGRect someRect;

      + (instancetype)new NS_UNAVAILABLE;

      - (instancetype)init NS_UNAVAILABLE;

      - (instancetype)initWithSomeRect:(CGRect)someRect NS_DESIGNATED_INITIALIZER;

      @end

      """
   And the file "project/values/IGListDiffableTest4.m" should contain:
      """
      - (id<NSObject>)diffIdentifier
      {
        return self;
      }
      """
   And the file "project/values/IGListDiffableTest4.m" should contain:
      """
      - (BOOL)isEqualToDiffableObject:(nullable id<IGListDiffable>)object
      {
        return [self isEqual:object];
      }
      """
