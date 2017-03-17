//
//  Points+CoreDataProperties.h
//  FencingApp
//
//  Created by Aniruddha Kadam on 18/11/16.
//  Copyright © 2016 kTech. All rights reserved.
//

#import "Points+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Points (CoreDataProperties)

+ (NSFetchRequest<Points *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *que1;
@property (nullable, nonatomic, copy) NSString *que2;
@property (nullable, nonatomic, copy) NSString *que3;
@property (nullable, nonatomic, copy) NSString *que4;
@property (nullable, nonatomic, copy) NSString *que5;
@property (nullable, nonatomic, copy) NSString *que6;
@property (nullable, nonatomic, copy) NSString *que7;
@property (nullable, nonatomic, copy) NSString *que8;
@property (nullable, nonatomic, copy) NSString *que9;
@property (nullable, nonatomic, copy) NSString *que10;
@property (nullable, nonatomic, copy) NSString *que11;
@property (nullable, nonatomic, copy) NSString *que12;
@property (nullable, nonatomic, copy) NSString *que13;
@property (nullable, nonatomic, copy) NSString *que14;
@property (nullable, nonatomic, copy) NSString *que15;
@property (nullable, nonatomic, copy) NSString *que16;
@property (nullable, nonatomic, retain) Tags *tag;

@end

NS_ASSUME_NONNULL_END
