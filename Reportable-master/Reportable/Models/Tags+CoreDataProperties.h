//
//  Tags+CoreDataProperties.h
//  Reportable
//
//  Created by Aniruddha Kadam on 18/11/16.
//  Copyright © 2016 kTech. All rights reserved.
//

#import "Tags+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Tags (CoreDataProperties)

+ (NSFetchRequest<Tags *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *caption;
@property (nullable, nonatomic, copy) NSString *copyright;
@property (nullable, nonatomic, retain) NSData *data;
@property (nullable, nonatomic, copy) NSDate *dateTaken;
@property (nullable, nonatomic, copy) NSNumber *latitude;
@property (nullable, nonatomic, copy) NSString *location;
@property (nullable, nonatomic, copy) NSNumber *longitude;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) NSData *thumbData;
@property (nullable, nonatomic, copy) NSNumber *type;
@property (nullable, nonatomic, copy) NSNumber *pointType;
@property (nullable, nonatomic, copy) NSNumber *uploadStatus;
@property (nullable, nonatomic, retain) NSSet<Points *> *points;

@end

@interface Tags (CoreDataGeneratedAccessors)

- (void)addPointsObject:(Points *)value;
- (void)removePointsObject:(Points *)value;
- (void)addPoints:(NSSet<Points *> *)values;
- (void)removePoints:(NSSet<Points *> *)values;

@end

NS_ASSUME_NONNULL_END
