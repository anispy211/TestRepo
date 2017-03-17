//
//  Foil+CoreDataProperties.h
//  FencingApp
//
//  Created by Aniruddha Kadam on 18/01/17.
//  Copyright © 2017 kTech. All rights reserved.
//

#import "Foil+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Foil (CoreDataProperties)

+ (NSFetchRequest<Foil *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *que1;
@property (nullable, nonatomic, copy) NSString *que2;
@property (nullable, nonatomic, copy) NSString *que3;
@property (nullable, nonatomic, copy) NSString *que4;
@property (nullable, nonatomic, copy) NSString *que5;
@property (nullable, nonatomic, copy) NSString *que6;
@property (nullable, nonatomic, copy) NSString *que7;
@property (nullable, nonatomic, retain) Tags *tag;

@end

NS_ASSUME_NONNULL_END
