//
//  SMAppDelegate.m

//  FencingApp
//
//  Created by Aniruddha Kadam on 11/5/12.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#import "SMAppDelegate.h"
#import "SMTagsListViewController.h"
#import "SMNoteViewController.h"
#import "Utility.h"
#import "SMLocationTracker.h"
#import "TagsDetailViewController.h"



#define kDropbox_AppKey @"urh2qap6u6w2c68" // Provide your key here
#define kDropbox_AppSecret @"v5gksblev1zekjh" // Provide your secret key here



@implementation SMAppDelegate{
    DBSession* session;
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = managedObjectModel_;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize query = _query;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    // app already launched
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.splashVC = [[SMSplashViewController alloc] initWithNibName:@"SMSplashViewController" bundle:[NSBundle mainBundle]];
    [self.window setRootViewController:self.splashVC];
    [self.window makeKeyAndVisible];
    self.hasLaunchedOnce = [[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"];
    

    // crashlytics
    [Crashlytics startWithAPIKey:@"a82015cd63bcb1d0c06be316287b92bc1906f5c5"];
    
    [Fabric with:@[[Crashlytics class]]];
    [[Fabric sharedSDK] setDebug: YES];

    
    self.hasLaunchedOnce = TRUE;
    if (!self.hasLaunchedOnce)
    {
        NSString *uniqueDeviceID = [[NSUUID UUID] UUIDString];
        [[NSUserDefaults standardUserDefaults] setValue:uniqueDeviceID forKey:@"UniqueDeviceID"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isCloudOn"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSString* appKey = kDropbox_AppKey;
    
    //@"ytndl6ka0j069yh"; // Reportable Production App Key
    //@"1tw7mjwyslz3njy";  // ReportableTestApp ID on Dropbox
    NSString* appSecret = kDropbox_AppSecret;
    
    //@"f1mmf44agjndqto"; // Reportable Production App Secret
    //@"ah17cz0o21gw0c5";   //@"y5rqily273x3r4o";
	NSString *root = kDBRootDropbox; // Should be set to either kDBRootAppFolder or kDBRootDropbox
    NSString* errorMsg = nil;
    session = [[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:root];
    
    
	session.delegate = self; // DBSessionDelegate methods allow you to handle re-authenticating
	[DBSession setSharedSession:session];
	[DBRequest setNetworkRequestDelegate:self];
	if (errorMsg != nil)
    {
		[[[UIAlertView alloc] initWithTitle:@"Error Configuring Dropbox Session" message:errorMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	}
    [[SMSharedData sharedManager] setShouldAutorotate:NO];
    
    
    return YES;
}

-(void)networkRequestStarted
{
    
}

-(void)networkRequestStopped
{
    
}

-(void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId
{
    // NSLog{@"AUthorization Failed");
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
  sourceApplication:(NSString *)source annotation:(id)annotation {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            // NSLog{@"App linked to drpbox successfully!");
            [SMDropboxComponent sharedComponent].restClient=[[DBRestClient alloc] initWithSession:session];
            [[NSNotificationCenter defaultCenter] postNotificationName:DROPBOX_LINKING_DONE object:nil];
            // At this point you can start making API calls
        }        
        return YES;
    }
    // Add whatever other url handling code your app requires here
    return NO;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [moc performBlockAndWait:^{
            [moc setPersistentStoreCoordinator: coordinator];
            
            [[NSUserDefaults standardUserDefaults] setValue:[[NSFileManager defaultManager] ubiquityIdentityToken] forKey:@"LastUbiquityToken"];
        }];
        _managedObjectContext = moc;
    }
    return _managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"SMModel" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel_;
}

/*
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SMModel.sqlite"];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
  
    
    NSPersistentStoreCoordinator* psc = _persistentStoreCoordinator;
   
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{      
        // Migrate datamodel
        NSDictionary *options = nil;
        // this needs to match the entitlements and provisioning profile
            options = [NSDictionary dictionaryWithObjectsAndKeys:
                       [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                       [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                       nil];

        NSError *error = nil;
        [psc lock];
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
        {
            [self hideHUD];
            [psc unlock];
            return;
            // NSLog{@"Unresolved error %@, %@", error, [error userInfo]);
        }
        [psc unlock];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideHUD];
            // NSLog{@"asynchronously added persistent store! that is : %@",psc);
            [self removeSplashScreen:nil];
            [self performSelector:@selector(hideHUD) withObject:nil afterDelay:2.0];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_ALL_DATABASE" object:self userInfo:nil];
        });
    });
    
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}
        

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if( [SMSharedData sharedManager].shouldAutorotate==NO)
        return (UIInterfaceOrientationMaskPortrait);
    return (UIInterfaceOrientationMaskAll);
}

#pragma mark -
#pragma mark Private Methods

- (void) removeDefaultScreen:(SMSplashViewController * )splash{
    [self performSelector:@selector(removeSplashScreen:) withObject:self.splashVC afterDelay:1.6f];
}

- (void)removeSplashScreen:(UIImageView *)splashScreen {
    [SMSharedData sharedManager];
    SMTagsListViewController *viewController1 = [[SMTagsListViewController alloc] initWithNibName:@"SMTagsListViewController" bundle:nil isDropboxModeOn:NO];
    viewController1.managedObjectContext = self.managedObjectContext;
    self.window.rootViewController = viewController1;
    if(!self.hasLaunchedOnce)
    {
        SMWelcomeViewController *viewController2 = [[SMWelcomeViewController alloc] initWithNibName:@"SMWelcomeViewController" bundle:nil andIsEnteringFromSettings:NO];
        [viewController1 presentViewController:viewController2 animated:NO completion:nil];
    }
    [SMLocationTracker sharedManager];
}

/**
 *  Shows circular progress view labelled with custom text
 *
 *  @param text progress view label
 */
- (void) showHUDWithText:(NSString *)text
{
    UIView *viewForHUD = [[[[UIApplication sharedApplication] keyWindow] rootViewController] view];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:viewForHUD  animated:YES];
    hud.labelText =text;
}

/**
 *  Hides circular progress view present on root view controller's view
 */
- (void) hideHUD
{
    UIView *viewForHUD = [[[[UIApplication sharedApplication] keyWindow] rootViewController] view];
    [MBProgressHUD hideAllHUDsForView:viewForHUD animated:YES];
}


@end
