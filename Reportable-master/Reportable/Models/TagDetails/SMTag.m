//
//  SMTag.m

//  FencingApp
//
//  Created by Aniruddha Kadam on 11/5/12.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#import "SMTag.h"

@implementation SMTag
@synthesize type = _type;
@synthesize name = _name;
@synthesize coordinate = _coordinate;
@synthesize dateTaken = _dateTaken;
@synthesize uploadStatus = _uploadStatus;
@synthesize address = _address;
@synthesize caption = _caption;
@synthesize copyright = _copyright;

- (NSString *) description
{
    return [NSString stringWithFormat:@"Name : %@, Type: %f Lat: %f long: %f Date Taken : %@ Upload Status = %d Address = %@ Caption = %@ Copyright = %@ Points=%@", self.name, self.type, self.coordinate.latitude, self.coordinate.longitude, self.dateTaken, self.uploadStatus, self.address,self.caption,self.copyright,self.points];
}

@end
