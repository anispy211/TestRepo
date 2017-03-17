//
//  Tags+CoreDataProperties.m
//  FencingApp
//
//  Created by Aniruddha Kadam on 18/01/17.
//  Copyright © 2017 kTech. All rights reserved.
//

#import "Tags+CoreDataProperties.h"

@implementation Tags (CoreDataProperties)

+ (NSFetchRequest<Tags *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Tags"];
}

@dynamic caption;
@dynamic copyright;
@dynamic data;
@dynamic dateTaken;
@dynamic latitude;
@dynamic location;
@dynamic longitude;
@dynamic name;
@dynamic thumbData;
@dynamic type;
@dynamic uploadStatus;
@dynamic pointType;
@dynamic points;
@dynamic sabre;
@dynamic foil;

@end
