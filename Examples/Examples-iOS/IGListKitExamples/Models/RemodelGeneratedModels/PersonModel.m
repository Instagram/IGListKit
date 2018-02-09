/**
 * This file is generated using the remodel generation script.
 * The name of the input file is PersonModel.value
 */

#if  ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "PersonModel.h"

@implementation PersonModel

- (instancetype)initWithFirstName:(NSString *)firstName lastName:(NSString *)lastName uniqueId:(NSString *)uniqueId
{
  if ((self = [super init])) {
    _firstName = [firstName copy];
    _lastName = [lastName copy];
    _uniqueId = [uniqueId copy];
  }

  return self;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ - \n\t firstName: %@; \n\t lastName: %@; \n\t uniqueId: %@; \n", [super description], _firstName, _lastName, _uniqueId];
}

- (id<NSObject>)diffIdentifier
{
  return _uniqueId;
}

- (NSUInteger)hash
{
  NSUInteger subhashes[] = {[_firstName hash], [_lastName hash], [_uniqueId hash]};
  NSUInteger result = subhashes[0];
  for (int ii = 1; ii < 3; ++ii) {
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

- (BOOL)isEqual:(PersonModel *)object
{
  if (self == object) {
    return YES;
  } else if (self == nil || object == nil || ![object isKindOfClass:[self class]]) {
    return NO;
  }
  return
    (_firstName == object->_firstName ? YES : [_firstName isEqual:object->_firstName]) &&
    (_lastName == object->_lastName ? YES : [_lastName isEqual:object->_lastName]) &&
    (_uniqueId == object->_uniqueId ? YES : [_uniqueId isEqual:object->_uniqueId]);
}

- (BOOL)isEqualToDiffableObject:(nullable id)object
{
  return [self isEqual:object];
}

@end

