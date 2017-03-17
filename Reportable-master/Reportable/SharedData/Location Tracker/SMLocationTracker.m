//
//  LocationTracker.m
//  HelpBridge
//
//  Created by Aniruddha Kadam on 31/07/12.
//  Copyright (c) 2016 Icertis. All rights reserved.
//

#import "SMLocationTracker.h"

static SMLocationTracker *sharedManager = nil;

@interface SMLocationTracker()
{
    CLLocationManager *locationManager;
    BOOL isPermissionDenied;
}
@end

@implementation SMLocationTracker
@synthesize currentLocation = _currentLocation;
@synthesize address = _address;

+ (SMLocationTracker*)sharedManager
{
    if (sharedManager == nil)
    {
        sharedManager = [[super alloc] init];
    }
    return sharedManager;
}

- (id)init
{
    if( self = [super init] ){

    }
    return self;
}

- (void)dealloc
{
    [self stopUpdatingLocation];
    LOGLINE(@"LocationTracker manager deallocated.");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation 
{
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
        
    _currentLocation = newLocation;
    _address = nil;
    
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark * placemark in placemarks) {
            _address = [[NSString alloc] init];
            
            if( [placemark country] )
                _address = [_address stringByAppendingFormat:@"%@", [placemark country]];

            if( [placemark administrativeArea] )
                _address = [_address stringByAppendingFormat:@", %@", [placemark administrativeArea]];

            if( [placemark locality] )
                _address = [_address stringByAppendingFormat:@", %@", [placemark locality]];

            
            
            
            if( [placemark name] )
                _address = [_address stringByAppendingFormat:@", %@", [placemark name]];
        }
        
     LOG(@"Address : %@", _address);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
            [[SMLocationTracker sharedManager] stopUpdatingLocation];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOCATION_UPDATED object:self.currentLocation];
    }];

    
    [self stopUpdatingLocation];
  //  [self performSelector:@selector(startUpdatingLocation) withObject:nil afterDelay:30];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self stopUpdatingLocation];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOCATION_FAILED object:self.currentLocation];
    // The location "unknown" error simply means the manager is currently unable to get the location.
    // We can ignore this error for the scenario of getting a single location fix, because we already have a 
    // timeout that will stop the location manager to save power.
    if ([[error domain] isEqualToString: kCLErrorDomain] && [error code] == kCLErrorDenied) 
    {
        isPermissionDenied = YES;
    }
    else
        [self performSelector:@selector(startUpdatingLocation) withObject:nil afterDelay:2];
}



- (void)startUpdatingLocation
{
    if( locationManager == nil )
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        // This is the most important property to set for the manager. It ultimately determines how the manager will
        // attempt to acquire location and thus, the amount of power that will be consumed.
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        locationManager.distanceFilter = 100;
        // Once configured, the location manager must be "started".
        [locationManager startUpdatingLocation];
    }
}

- (void)stopUpdatingLocation 
{
    [locationManager stopUpdatingLocation];
    locationManager.delegate = nil;
    locationManager = nil;
}


@end
