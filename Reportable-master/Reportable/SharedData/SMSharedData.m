




//
//  SMSharedData.m

//  FencingApp
//
//  Created by Aniruddha Kadam on 05/11/12.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#import "SMSharedData.h"
#import "Utility.h"
#import "SMTag.h"
#import "SMLocationTracker.h"

static SMSharedData *sharedManager = nil;

@implementation SMSharedData
@synthesize tags;
@synthesize deviceLocation;
@synthesize currentTagsFrame;
@synthesize dateFormat;
@synthesize isFileBeingOpened;
@synthesize shouldAutorotate;
@synthesize mainWindow;

NSString * fName;

+ (SMSharedData*)sharedManager
{
    if (sharedManager == nil)
    {
        sharedManager = [[super alloc] init];
    }
    return sharedManager;
}

- (id)init
{
    if( self = [super init] )
    {
        tags = [[NSMutableArray alloc] init];
        [self setupApplicationDataFile];
    }
    
    return self;
}

- (void)setupApplicationDataFile
{
    // Fetch iCloud synced data
 //   [APP_DELEGATE showHUD];
    NSError *error;
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Tags" inManagedObjectContext:context];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    [fetchRequest setRelationshipKeyPathsForPrefetching:@[ @"points",@"sabre",@"foil" ]];


    [fetchRequest setEntity:entity];

    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    [tags removeAllObjects];
    
    // Point Fetch Request

    
    for (NSManagedObject *info in fetchedObjects)
    {
        SMTag *tag = [[SMTag alloc] init];
        tag.name = [info valueForKey:@"name"];
        tag.type = [[info valueForKey:@"type"] doubleValue];
        tag.pointType = [[info valueForKey:@"pointType"] doubleValue];
        CLLocationDegrees latitude = [[info valueForKey:@"latitude"] doubleValue];
        CLLocationDegrees longitude = [[info valueForKey:@"longitude"] doubleValue];
        tag.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        tag.uploadStatus = [[info valueForKey:@"uploadStatus"] boolValue];
        tag.dateTaken = [info valueForKey:@"dateTaken"];
        tag.address = [info valueForKey:@"location"];
        tag.caption = [info valueForKey:@"caption"];
        tag.copyright = [info valueForKey:@"copyright"];
        if(!tag.name)
            continue;
        
        if (tag.pointType == POINT_EPEE || tag.pointType == POINT_SABRE || tag.pointType == POINT_FOIL)
        {
            NSSet * tempArr = (NSSet *)[info valueForKey:@"points"];
            
            if (tempArr.count > 0)
            {
                tag.points = [[NSMutableArray alloc] init];
                
                for (NSDictionary *product2 in tempArr)
                {
                    
                    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                    
                    [dict setValue:[product2 valueForKey:@"que1"] forKey:@"que1"];
                    [dict setValue:[product2 valueForKey:@"que2"] forKey:@"que2"];
                    [dict setValue:[product2 valueForKey:@"que3"] forKey:@"que3"];
                    [dict setValue:[product2 valueForKey:@"que4"] forKey:@"que4"];
                    [dict setValue:[product2 valueForKey:@"que5"] forKey:@"que5"];
                    [dict setValue:[product2 valueForKey:@"que6"] forKey:@"que6"];
                    [dict setValue:[product2 valueForKey:@"que7"] forKey:@"que7"];
                    [dict setValue:[product2 valueForKey:@"que8"] forKey:@"que8"];
                    [dict setValue:[product2 valueForKey:@"que9"] forKey:@"que9"];
                    [dict setValue:[product2 valueForKey:@"que10"] forKey:@"que10"];
                    [dict setValue:[product2 valueForKey:@"que11"] forKey:@"que11"];
                    [dict setValue:[product2 valueForKey:@"que12"] forKey:@"que12"];
                    [dict setValue:[product2 valueForKey:@"que13"] forKey:@"que13"];
                    [dict setValue:[product2 valueForKey:@"que14"] forKey:@"que14"];
                    [dict setValue:[product2 valueForKey:@"que15"] forKey:@"que15"];
                    [dict setValue:[product2 valueForKey:@"que16"] forKey:@"que16"];
                    
                    [tag.points addObject:dict];
                    
                }
            }
            
            if (tag.points.count > 0)
            {
                NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"que1" ascending:YES];
                
                NSArray * arr =   [tag.points sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameDescriptor]];
                
                tag.points = [[NSMutableArray alloc] initWithArray:arr];
                
            }
            
        }
//        else if (tag.pointType == POINT_SABRE)
//        {
//            NSSet * tempArr = (NSSet *)[info valueForKey:@"sabre"];
//            
//            
//            if (tempArr.count > 0)
//            {
//                tag.sabrepoints = [[NSMutableArray alloc] init];
//                
//                for (NSDictionary *product2 in tempArr)
//                {
//                    
//                    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
//                    
//                    [dict setValue:[product2 valueForKey:@"que1"] forKey:@"que1"];
//                    [dict setValue:[product2 valueForKey:@"que2"] forKey:@"que2"];
//                    [dict setValue:[product2 valueForKey:@"que3"] forKey:@"que3"];
//                    [dict setValue:[product2 valueForKey:@"que4"] forKey:@"que4"];
//                    [dict setValue:[product2 valueForKey:@"que5"] forKey:@"que5"];
//                    [dict setValue:[product2 valueForKey:@"que6"] forKey:@"que6"];
//                    [dict setValue:[product2 valueForKey:@"que7"] forKey:@"que7"];
//                    
//                    [tag.sabrepoints addObject:dict];
//                    
//                }
//            }
//            
//            if (tag.sabrepoints.count > 0)
//            {
//                NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"que1" ascending:YES];
//                
//                NSArray * arr =   [tag.sabrepoints sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameDescriptor]];
//                
//                tag.sabrepoints = [[NSMutableArray alloc] initWithArray:arr];
//                
//            }
//        }
//        else if (tag.pointType == POINT_FOIL)
//        {
//            NSSet * tempArr = (NSSet *)[info valueForKey:@"foil"];
//            
//            
//            if (tempArr.count > 0)
//            {
//                tag.foilpoints = [[NSMutableArray alloc] init];
//                
//                for (NSDictionary *product2 in tempArr)
//                {
//                    
//                    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
//                    
//                    [dict setValue:[product2 valueForKey:@"que1"] forKey:@"que1"];
//                    [dict setValue:[product2 valueForKey:@"que2"] forKey:@"que2"];
//                    [dict setValue:[product2 valueForKey:@"que3"] forKey:@"que3"];
//                    [dict setValue:[product2 valueForKey:@"que4"] forKey:@"que4"];
//                    [dict setValue:[product2 valueForKey:@"que5"] forKey:@"que5"];
//                    [dict setValue:[product2 valueForKey:@"que6"] forKey:@"que6"];
//                    [dict setValue:[product2 valueForKey:@"que7"] forKey:@"que7"];
//                    
//                    [tag.foilpoints addObject:dict];
//                    
//                }
//            }
//            
//            if (tag.foilpoints.count > 0)
//            {
//                NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"que1" ascending:YES];
//                
//                NSArray * arr =   [tag.foilpoints sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameDescriptor]];
//                
//                tag.foilpoints = [[NSMutableArray alloc] initWithArray:arr];
//                
//            }
//        }
        

        
        
        
        //        // Save changes in core data
        //        NSFetchRequest * newfetchRequest = [[NSFetchRequest alloc] init];
        //
        //        NSEntityDescription *pointentity = [NSEntityDescription entityForName:@"Points" inManagedObjectContext:info.managedObjectContext];
        //        [newfetchRequest setReturnsObjectsAsFaults:NO];
        //        [newfetchRequest setEntity:pointentity];
        //
        //        NSError *newfetchError;
        //        NSArray *newfetchedProducts=[context executeFetchRequest:newfetchRequest error:&newfetchError];
        //
        //
        //        if (newfetchedProducts.count > 0)
        //        {
        //            tag.points = [[NSMutableArray alloc] init];
        //
        //            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        //
        //            for (NSManagedObject *product2 in newfetchedProducts)
        //            {
        //                [dict setValue:[product2 valueForKey:@"que1"] forKey:@"que1"];
        //                [dict setValue:[product2 valueForKey:@"que2"] forKey:@"que2"];
        //                [dict setValue:[product2 valueForKey:@"que3"] forKey:@"que3"];
        //                [dict setValue:[product2 valueForKey:@"que4"] forKey:@"que4"];
        //                [dict setValue:[product2 valueForKey:@"que5"] forKey:@"que5"];
        //                [dict setValue:[product2 valueForKey:@"que6"] forKey:@"que6"];
        //                [dict setValue:[product2 valueForKey:@"que7"] forKey:@"que7"];
        //
        //                [tag.points addObject:dict];
        //            }
        //        }
        //
        
        
        
        switch((int)tag.type)
        {
            case 1:
            {
                NSData *tagData = [info valueForKey:@"data"];
                NSURL *audioURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf", tag.name]];
                [tagData writeToFile:audioURL.path atomically:YES];
                break;
            }
            case 2:
            {
                NSData *thumbVideoData =[info valueForKey:@"thumbData"];
                NSURL *videoThumbnailURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.jpeg",  tag.name, THUMBNAIL_VIDEO]];
                [thumbVideoData writeToFile:videoThumbnailURL.path atomically:YES];
                NSData *tagData = [info valueForKey:@"data"];
                NSURL *imageURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", tag.name]];
                [tagData writeToFile:imageURL.path atomically:YES];
                break;
            }
                
            case 3:
            {
                NSData *thumbImageData =[info valueForKey:@"thumbData"];
                NSURL *imageThumbnailURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.jpeg",  tag.name,   THUMBNAIL_IMAGE]];
                [thumbImageData writeToFile:imageThumbnailURL.path atomically:YES];
                NSData *tagData = [info valueForKey:@"data"];
                NSURL *imageURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg", tag.name]];
                [tagData writeToFile:imageURL.path atomically:YES];
                break;
            }
            case 4:
            {
                NSData *tagData = [info valueForKey:@"data"];
                NSURL *noteURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", tag.name]];
                [tagData writeToFile:noteURL.path atomically:YES];
                break;
            }
            case 5:
            {
                NSData *tagData = [info valueForKey:@"data"];
                NSURL *noteURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", tag.name]];
                [tagData writeToFile:noteURL.path atomically:YES];
                break;
            }
            default:
                break;
                
        }
        [tags insertObject:tag atIndex:0];
        //      [tags addObject:tag];
    }
    
//      fetch non-synced tags
    
    
/*   com:to be removed
 NSURL *url = [[Utility dataStoragePath] URLByAppendingPathComponent:@"LocalTags.plist"];
    
    if( [[NSFileManager defaultManager] fileExistsAtPath:url.path] )
    {
        NSArray *arrTags = [NSArray arrayWithContentsOfFile:url.path];
        for( int i = (int)arrTags.count-1; i>=0; i-- )
        {
            NSDictionary *dict = [arrTags objectAtIndex:i];
            SMTag *tag = [[SMTag alloc] init];
            tag.name = [dict objectForKey:@"name"];
            tag.type = [[dict objectForKey:@"type"] intValue];
            CLLocationDegrees latitude = [[dict objectForKey:@"latitude"] doubleValue];
            CLLocationDegrees longitude = [[dict objectForKey:@"longitude"] doubleValue];
            tag.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
            tag.uploadStatus = [[dict objectForKey:@"uploadStatus"] boolValue];
            tag.dateTaken = [dict objectForKey:@"dateTaken"];
            tag.address = [dict objectForKey:@"location"];
            tag.caption = [dict objectForKey:@"caption"];
            tag.copyright = [dict objectForKey:@"copyright"];
            
            if(!tag.name)
                continue;
            
            switch((int)tag.type)
            {
                case 1:
                {
                    NSData *tagData = [dict valueForKey:@"data"];
                    NSURL *audioURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf", tag.name]];
                    [tagData writeToFile:audioURL.path atomically:YES];
                    break;
                }
                    
                case 2:
                {
                    NSData *thumbVideoData =[dict valueForKey:@"thumbData"];
                    NSURL *videoThumbnailURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.jpeg",  tag.name, THUMBNAIL_VIDEO]];
                    [thumbVideoData writeToFile:videoThumbnailURL.path atomically:YES];
                    NSData *tagData = [dict valueForKey:@"data"];
                    NSURL *imageURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", tag.name]];
                    [tagData writeToFile:imageURL.path atomically:YES];
                    break;
                }
                    
                case 3:
                {
                    NSData *thumbImageData =[dict valueForKey:@"thumbData"];
                    NSURL *imageThumbnailURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.jpeg",  tag.name,   THUMBNAIL_IMAGE]];
                    [thumbImageData writeToFile:imageThumbnailURL.path atomically:YES];
                    NSData *tagData = [dict valueForKey:@"data"];
                    NSURL *imageURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg", tag.name]];
                    [tagData writeToFile:imageURL.path atomically:YES];
                    break;
                }
                case 4:
                {
                    NSData *tagData = [dict valueForKey:@"data"];
                    NSURL *noteURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", tag.name]];
                    [tagData writeToFile:noteURL.path atomically:YES];
                    break;
                }
            }
                    [tags insertObject:tag atIndex:0];
//            [tags addObject:tag];
        }
    }
    else
    {
        NSError *error;
        NSString *bundleFile = [[NSBundle mainBundle] pathForResource:@"LocalTags" ofType:@"plist"];
        [[NSFileManager defaultManager] copyItemAtPath:bundleFile toPath:url.path error:&error];
        // NSLog{@"%@", error.description);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_LIST object:nil];
    NSURL *reportPdfUrl = [[Utility dataStoragePath] URLByAppendingPathComponent:@"Reports.plist"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:reportPdfUrl.path] )
    {
        NSError *error;
        NSString *bundleFile = [[NSBundle mainBundle] pathForResource:@"Reports" ofType:@"plist"];
        [[NSFileManager defaultManager] copyItemAtPath:bundleFile toPath:reportPdfUrl.path error:&error];
    }
    */
}
        

#pragma mark -  Image Meta Data



- (NSURL *)getPhotoUrlWithMetadata:(UIImage *)img withMetaData:(SMTag *)photoTag withName:(NSString *)fileName
{
    [APP_DELEGATE showHUDWithText:@"Saving"];
    
    NSData *jpgData = UIImageJPEGRepresentation(img, 1);
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef) jpgData, NULL);
    NSDictionary *metadata = (__bridge NSDictionary *) CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
    NSMutableDictionary *mutableMetadata = [metadata mutableCopy];
    NSMutableDictionary * tiffDict = [[mutableMetadata objectForKey:(NSString *)kCGImagePropertyTIFFDictionary] mutableCopy];
    
    
    if (tiffDict) {
        // NSLog{@"found jpg tiffDict dictionary");
    } else {
        // NSLog{@"creating jpg tiffDict dictionary");
    }
    
    
    // set values on the exif dictionary
    
    NSString * captionStr= nil;
    
    NSString * copyightTxt = photoTag.copyright;
    
    if ([copyightTxt isEqualToString:@""]) {
         captionStr = [NSString stringWithFormat:@""];

    }
    else{
        
        NSString * address = photoTag.address;
        if (address == nil) {
            captionStr = [NSString stringWithFormat:@"%@",photoTag.caption];

            
        }
        else{
            captionStr = [NSString stringWithFormat:@"%@ Location:%@",photoTag.caption,photoTag.address];
        }

    }
    
    [tiffDict setValue:captionStr forKey:(NSString *)kCGImagePropertyTIFFImageDescription];
    NSString * copyrightStr = [NSString stringWithFormat:@"%@",photoTag.copyright];

    [tiffDict setValue:copyrightStr forKey:(NSString *)kCGImagePropertyTIFFCopyright];
    
    
    // Format the current date and time
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
    NSString *now = [formatter stringFromDate:photoTag.dateTaken];
    [tiffDict setValue:now forKey:(NSString *)kCGImagePropertyTIFFDateTime];
    
    
  [tiffDict setValue:photoTag.name forKey:(NSString *)kCGImagePropertyTIFFDocumentName];
    
    
    
    fName = fileName;
    
    [mutableMetadata setObject:tiffDict forKey:(NSString *)kCGImagePropertyTIFFDictionary];
    
    __block NSURL * imageURL;
    
    // NSLog{@"Mutable data : %@",mutableMetadata);
    
    orientationOrignal = img.imageOrientation;

    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
    
    
      
    [library writeImageToSavedPhotosAlbum:[img CGImage] metadata:mutableMetadata completionBlock:^(NSURL *assetURL, NSError *error) {
        NSURL * url= [assetURL copy];
        
        [library assetForURL:url
                 resultBlock:resultblock
                failureBlock:failureblock];
        
    }];
    
    return imageURL;
}

 UIImageOrientation orientationOrignal; // New!




ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
{
    ALAssetRepresentation *rep = [myasset defaultRepresentation];
    CGImageRef iref = [rep fullResolutionImage];
    if (iref) {
        NSURL *imageURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg", fName]];
        NSString * path = [imageURL path];
        
        BOOL res;
        
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        Byte *buffer = (Byte*)malloc(rep.size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0 length:rep.size error:nil];
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];//this is NSData may be what you want
        res  =   [data writeToFile:path atomically:YES];//you
        
        // BOOL res  = [UIImageJPEGRepresentation(img, 1) writeToURL:imageURL atomically:YES];
        if (res == YES)
        {
            
            [APP_DELEGATE hideHUD];
            
//            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Sucessfull" message:@"WRITING META DATA" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            [alert show];
            
            
        }
        else
        {
            [APP_DELEGATE hideHUD];
            
//            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"WRITING META DATA" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            [alert show];
            
        }
        
    }
    else{
        [APP_DELEGATE hideHUD];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Image Not Available" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
};

ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
{
    [APP_DELEGATE hideHUD];
    
//    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[myerror localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alert show];
}
        ;


- (void) addDefaultStampsToTag : (SMTag *)tag{
    if( !tag )
        return;
    [tag setDateTaken:[NSDate date]];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isAutoFillOn"]) {
        NSString * copyrightText = [[NSUserDefaults standardUserDefaults] stringForKey:@"CopyrightName"];
        if(![copyrightText isEqualToString:@"(null)"] && (!tag.copyright || [tag.copyright isEqualToString:@""]))
            tag.copyright = copyrightText;
    }

    
    [tag setCoordinate:[SMLocationTracker sharedManager].currentLocation.coordinate];
    //    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
    //        [tag setAddress:[SMLocationTracker sharedManager].address];
    // NSLog{@"address : %@",[SMLocationTracker sharedManager].address);
}

- (void)addNewTag:(SMTag *)tag
{
    if([tag.name isEqualToString:@""])
        return;
    if(tags)
                [tags insertObject:tag atIndex:0];
//        [tags addObject:tag];

    
    
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    NSManagedObject *smManagedObject = [NSEntityDescription
                                        insertNewObjectForEntityForName:@"Tags"
                                        inManagedObjectContext:context];
    NSData *tagData,*thumbData;
    switch ((int)tag.type) {
        case 1:
        {
            NSURL *audioURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf", tag.name]];
            tagData = [NSData dataWithContentsOfURL:audioURL];
            thumbData = nil;
            break;
        }
        case 2:
        {
            NSURL *videoURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", tag.name]];
            tagData = [NSData dataWithContentsOfURL:videoURL];
            
            NSURL *thumbURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.jpeg", tag.name,THUMBNAIL_VIDEO]];
            
            if([[NSFileManager defaultManager] fileExistsAtPath:thumbURL.path] == NO)
            {
                UIImage *videothumbnailImage = [Utility imageWithImage:[Utility thumbnailFromVideo:videoURL atTime:0.2] scaledToSizeWithSameAspectRatio:CGSizeMake(90  , 90)];
                
                NSData *pngData = UIImageJPEGRepresentation(videothumbnailImage, 1.0);

                [pngData writeToFile:thumbURL.path atomically:YES];
            }
            
            
            thumbData = [NSData dataWithContentsOfURL:thumbURL];
            break;
        }
        case 3:
        {
            NSURL *imageURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg", tag.name]];
            if(![[NSFileManager defaultManager] fileExistsAtPath:imageURL.path])
               imageURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", tag.name]];
            tagData = [NSData dataWithContentsOfFile:imageURL.path];
            NSURL *thumbURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.jpeg", tag.name,THUMBNAIL_IMAGE]];
            if([[NSFileManager defaultManager] fileExistsAtPath:thumbURL.path] == NO)
            {
                NSURL *thumbnailURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.jpeg", tag.name, THUMBNAIL_IMAGE]];
                
                UIImage *selectedImage = [UIImage imageWithContentsOfFile:imageURL.path];
                UIImage *image = [Utility imageWithImage:selectedImage scaledToSizeWithSameAspectRatio:CGSizeMake(100, 100)];
                NSData *pngData = UIImageJPEGRepresentation(image, 1.0);
                [pngData writeToFile:thumbnailURL.path atomically:YES];
            }
            thumbData = [NSData dataWithContentsOfURL:thumbURL];
            break;
        }
        case 4:
        {
            NSURL *noteURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", tag.name]];
            NSString *contents = [NSString stringWithContentsOfURL:noteURL encoding:NSUTF8StringEncoding error:nil];
            tagData = [contents dataUsingEncoding:NSUTF8StringEncoding];
            thumbData= nil;
            break;
        }
        case 5:
        {
            NSURL *pdfURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", tag.name]];
            tagData = [NSData dataWithContentsOfURL:pdfURL];
            thumbData = nil;
            break;
        }
        default:
            break;
    }
    
//    if(APP_DELEGATE.isCloudOn){
        [smManagedObject setValue:[NSNumber numberWithDouble:tag.type] forKey:@"type"];
    [smManagedObject setValue:[NSNumber numberWithDouble:tag.pointType] forKey:@"pointType"];

    double latitude = tag.coordinate.latitude;
        double longitude = tag.coordinate.longitude;
        tag.uploadStatus = 1;
        [smManagedObject setValue:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
        [smManagedObject setValue:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
        [smManagedObject setValue:[NSNumber numberWithBool:tag.uploadStatus] forKey:@"uploadStatus"];
        [smManagedObject setValue:tag.dateTaken forKey:@"dateTaken"];
        [smManagedObject setValue:tag.name forKey:@"name"];
        [smManagedObject setValue:tag.address forKey:@"location"];
        [smManagedObject setValue:tag.caption forKey:@"caption"];
        [smManagedObject setValue:tag.copyright forKey:@"copyright"];
        [smManagedObject setValue:tagData forKey:@"data"];
        [smManagedObject setValue:thumbData forKey:@"thumbData"];
            [smManagedObject setValue:[NSNumber numberWithDouble:tag.pointType] forKey:@"pointType"];

        NSError *error;
        if (![context save:&error]) {
             NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
//  }
//    else
//    {
//        tag.uploadStatus = 0;
//        NSURL *url = [[Utility dataStoragePath] URLByAppendingPathComponent:@"LocalTags.plist"];
//        NSMutableArray *arrTags = [NSMutableArray arrayWithContentsOfFile:url.path];
//        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:tag.name, @"name", [NSNumber numberWithUnsignedInt:tag.type], @"type", [NSNumber numberWithDouble:tag.coordinate.latitude], @"latitude", [NSNumber numberWithDouble:tag.coordinate.longitude], @"longitude", [NSNumber numberWithBool:tag.uploadStatus], @"uploadStatus", tag.dateTaken, @"dateTaken", tag.caption, @"caption", tag.copyright, @"copyright", nil];
//    
//        [dict setValue:[NSNumber numberWithDouble:tag.pointType] forKey:@"pointType"];
//    
//        [arrTags insertObject:dict atIndex:0];
////        [arrTags addObject:dict];
//        [arrTags writeToFile:url.path atomically:YES];
//    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_LIST object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:ADDED_NEW_TAG object:nil];
}
        
- (void)savePDFPath:(NSString *)path withName:(NSString *)name
{
    NSURL *url = [[Utility dataStoragePath] URLByAppendingPathComponent:@"Reports.plist"];
    NSMutableArray *arrTags = [NSMutableArray arrayWithContentsOfFile:url.path];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:name, @"Name", path, @"Path", nil];
    
            [tags insertObject:dict atIndex:0];
//    [arrTags addObject:dict];
    [arrTags writeToFile:url.path atomically:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_REPORT_LIST object:nil];
}

- (NSInteger)checkIfTagExistsWithName:(NSString *)name
{
    if( !name )
        return -1;
    
    NSInteger iRet = -1;
    
    for( SMTag *tag in tags )
    {
        if( [tag.name isEqualToString:name] )
        {
            iRet = [tags indexOfObject:tag];
            break;
        }
    }
    
    return iRet;
}

- (void)removeTags:(NSSet *)objects
{
    if( !objects )
        return;
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    for(SMTag *tag in objects)
    {
        for (int i=(int)tags.count-1;i>=0 ; i--) {
            SMTag *j =(SMTag *)[tags objectAtIndex:i];
            if ([j.name isEqualToString:tag.name]) {
                [tags removeObject:j];
            }
        }
        
//        if(tag.uploadStatus==1)
//        {
            NSString *soughtPid=[NSString stringWithString:tag.name];
            NSEntityDescription *productEntity=[NSEntityDescription entityForName:@"Tags" inManagedObjectContext:context];
            NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
            [fetch setEntity:productEntity];
            NSPredicate *p=[NSPredicate predicateWithFormat:@"name == %@", soughtPid];
            [fetch setPredicate:p];
            //... add sorts if you want them
            NSError *fetchError,*error;
            NSArray *fetchedProducts=[context executeFetchRequest:fetch error:&fetchError];
            // handle error
            
            for (NSManagedObject *product in fetchedProducts) {
                [context deleteObject:product];
            }
            if (![context save:&error]) {
                 NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
//        } com:to be removed
//        else{
//            NSURL *url = [[Utility dataStoragePath] URLByAppendingPathComponent:@"LocalTags.plist"];
//            if( [[NSFileManager defaultManager] fileExistsAtPath:url.path] )
//            {
//                NSInteger iRet = -1;
//                NSMutableArray *arrTags = [NSMutableArray arrayWithContentsOfFile:url.path];
//                for( int i = 0; i < [arrTags count]; i++ )
//                {
//                    NSDictionary *dict = [arrTags objectAtIndex:i];
//                    NSString *strName = [dict objectForKey:@"name"];
//                    
//                    if( strName && [strName isEqualToString:tag.name] )
//                    {
//                        iRet = i;
//                        break;
//                    }
//                }
//                [arrTags removeObjectAtIndex:iRet];
//                [arrTags writeToFile:url.path atomically:YES];
//            }
//        }
    }
    NSError *error;

    
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_LIST object:nil];
    
    NSURL *imageURL = nil;
    NSURL *thumbURL = nil;
    for(SMTag *tag in objects)
    {
        switch ((int)tag.type) {
            case 3:
                imageURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg", tag.name]];
                thumbURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.jpeg", tag.name, THUMBNAIL_IMAGE]];
                break;
            case 1:
                imageURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf", tag.name]];
                break;
            case 2:
                imageURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", tag.name]];
                thumbURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.jpeg", tag.name, THUMBNAIL_VIDEO]];
                break;
            case 4:
                imageURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", tag.name]];
                break;
            case 5:
                imageURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", tag.name]];
                break;
            default:
                break;
        }
        if( imageURL && [[NSFileManager defaultManager] fileExistsAtPath:imageURL.path] )
            [[NSFileManager defaultManager] removeItemAtPath:imageURL.path error:&error];
        if( thumbURL && [[NSFileManager defaultManager] fileExistsAtPath:thumbURL.path] )
            [[NSFileManager defaultManager] removeItemAtPath:thumbURL.path error:&error];
    }
}

- (NSArray*)photoTags
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type=%d", 3];
    NSArray *filtered = [self.tags filteredArrayUsingPredicate:predicate];
    return filtered;
}

- (NSArray*)audioTags
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type=%d", 1];
    NSArray *filtered = [self.tags filteredArrayUsingPredicate:predicate];
    return filtered;
}

- (NSArray*)videoTags
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type=%d", 2];
    NSArray *filtered = [self.tags filteredArrayUsingPredicate:predicate];
    return filtered;
}

- (NSArray*)noteTags
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type=%d", 4];
    NSArray *filtered = [self.tags filteredArrayUsingPredicate:predicate];
    return filtered;
}

- (NSArray*)reportTags
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type=%d", 5];
    NSArray *filtered = [self.tags filteredArrayUsingPredicate:predicate];
    return filtered;
}

@end
