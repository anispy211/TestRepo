//
//  Sabre+CoreDataProperties.m
//  FencingApp
//
//  Created by Aniruddha Kadam on 18/01/17.
//  Copyright © 2017 kTech. All rights reserved.
//

#import "Sabre+CoreDataProperties.h"

@implementation Sabre (CoreDataProperties)

+ (NSFetchRequest<Sabre *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Sabre"];
}

@dynamic que1;
@dynamic que2;
@dynamic que3;
@dynamic que4;
@dynamic que5;
@dynamic que6;
@dynamic que7;
@dynamic tag;

@end
