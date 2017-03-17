//
//  Tags+CoreDataProperties.m
//  Reportable
//
//  Created by Aniruddha Kadam on 18/11/16.
//  Copyright © 2016 kTech. All rights reserved.
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
@dynamic pointType;
@dynamic uploadStatus;
@dynamic points;

@end
