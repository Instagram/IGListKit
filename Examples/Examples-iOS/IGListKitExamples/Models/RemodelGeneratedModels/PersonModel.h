/**
 * This file is generated using the remodel generation script.
 * The name of the input file is PersonModel.value
 */

#import <Foundation/Foundation.h>
#import <IGListKit/IGListDiffable.h>

@interface PersonModel : NSObject <IGListDiffable, NSCopying>

@property (nonatomic, readonly, copy) NSString *firstName;
@property (nonatomic, readonly, copy) NSString *lastName;
@property (nonatomic, readonly, copy) NSString *uniqueId;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithFirstName:(NSString *)firstName lastName:(NSString *)lastName uniqueId:(NSString *)uniqueId NS_DESIGNATED_INITIALIZER;

@end

