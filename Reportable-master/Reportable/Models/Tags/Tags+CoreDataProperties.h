//
//  Tags+CoreDataProperties.h
//  FencingApp
//
//  Created by Aniruddha Kadam on 18/01/17.
//  Copyright © 2017 kTech. All rights reserved.
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
@property (nullable, nonatomic, copy) NSNumber *uploadStatus;
@property (nullable, nonatomic, copy) NSNumber *pointType;
@property (nullable, nonatomic, retain) NSSet<Points *> *points;
@property (nullable, nonatomic, retain) NSSet<Sabre *> *sabre;
@property (nullable, nonatomic, retain) NSSet<Foil *> *foil;

@end

@interface Tags (CoreDataGeneratedAccessors)

- (void)addPointsObject:(Points *)value;
- (void)removePointsObject:(Points *)value;
- (void)addPoints:(NSSet<Points *> *)values;
- (void)removePoints:(NSSet<Points *> *)values;

- (void)addSabreObject:(Sabre *)value;
- (void)removeSabreObject:(Sabre *)value;
- (void)addSabre:(NSSet<Sabre *> *)values;
- (void)removeSabre:(NSSet<Sabre *> *)values;

- (void)addFoilObject:(Foil *)value;
- (void)removeFoilObject:(Foil *)value;
- (void)addFoil:(NSSet<Foil *> *)values;
- (void)removeFoil:(NSSet<Foil *> *)values;

@end

NS_ASSUME_NONNULL_END
