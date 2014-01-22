/** Cycle Atlanta, Copyright 2012, 2013 Georgia Institute of Technology
 *                                    Atlanta, GA. USA
 *
 *   @author Christopher Le Dantec <ledantec@gatech.edu>
 *   @author Anhong Guo <guoanhong@gatech.edu>
 *
 *   Updated/Modified for Atlanta's app deployment. Based on the
 *   CycleTracks codebase for SFCTA.
 *
 ** CycleTracks, Copyright 2009,2010 San Francisco County Transportation Authority
 *                                    San Francisco, CA, USA
 *
 *   @author Matt Paul <mattpaul@mopimp.com>
 *
 *   This file is part of CycleTracks.
 *
 *   CycleTracks is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   CycleTracks is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with CycleTracks.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  MapViewController.m
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/28/09.
//	For more information on the project,
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>


#import "Coord.h"
#import "LoadingView.h"
#import "MapCoord.h"
#import "HCSMapViewController.h"
#import "Trip.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "RMMapView.h"
#import "RMAnnotation.h"
#import "RMMarker.h"

#define kFudgeFactor	1.5
#define kInfoViewAlpha	0.8
#define kMinLatDelta	0.0039
#define kMinLonDelta	0.0034

@interface HCSMapViewController()<RMMapViewDelegate>

@end


@implementation HCSMapViewController

@synthesize doneButton, flipButton, infoView, trip, routeLine;
@synthesize delegate;


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

- (id)initWithTrip:(Trip *)_trip
{
    //if (self = [super init]) {
	if (self = [super initWithNibName:@"HCSMapViewController" bundle:nil]) {
		NSLog(@"MapViewController initWithTrip");
		self.trip = _trip;
		mapView.delegate = self;
    }
    return self;
}


/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */


- (void)infoAction:(UIButton*)sender
{
	NSLog(@"infoAction");
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:animationIDfinished:finished:context:)];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	
	[UIView setAnimationTransition:([infoView superview] ?
									UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
						   forView:self.view cache:YES];
	
	if ([infoView superview])
		[infoView removeFromSuperview];
	else
		[self.view addSubview:infoView];
	
	[UIView commitAnimations];
	
	// adjust our done/info buttons accordingly
	if ([infoView superview] == self.view)
		self.navigationItem.rightBarButtonItem = doneButton;
	else
		self.navigationItem.rightBarButtonItem = flipButton;
}


- (void)initInfoView
{
	infoView					= [[UIView alloc] initWithFrame:CGRectMake(0,0,320,560)];
	infoView.alpha				= kInfoViewAlpha;
	infoView.backgroundColor	= [UIColor blackColor];
	
	UILabel *notesHeader		= [[UILabel alloc] initWithFrame:CGRectMake(9,85,160,25)];
	notesHeader.backgroundColor = [UIColor clearColor];
	notesHeader.font			= [UIFont boldSystemFontOfSize:18.0];
	notesHeader.opaque			= NO;
	notesHeader.text			= @"Trip Notes";
	notesHeader.textColor		= [UIColor whiteColor];
	[infoView addSubview:notesHeader];
	
	UITextView *notesText		= [[UITextView alloc] initWithFrame:CGRectMake(0,110,320,200)];
	notesText.backgroundColor	= [UIColor clearColor];
	notesText.editable			= NO;
	notesText.font				= [UIFont systemFontOfSize:16.0];
	notesText.text				= trip.notes;
	notesText.textColor			= [UIColor whiteColor];
	[infoView addSubview:notesText];
    
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBarHidden = NO;
    
	if ( trip )
	{
		// format date as a string
		static NSDateFormatter *dateFormatter = nil;
		if (dateFormatter == nil) {
			dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
			[dateFormatter setDateStyle:NSDateFormatterLongStyle];
		}
		
		// display duration, distance as navbar prompt
		static NSDateFormatter *inputFormatter = nil;
		if ( inputFormatter == nil )
			inputFormatter = [[NSDateFormatter alloc] init];
		
		[inputFormatter setDateFormat:@"HH:mm:ss"];
		NSDate *fauxDate = [inputFormatter dateFromString:@"00:00:00"];
		[inputFormatter setDateFormat:@"HH:mm:ss"];
		NSDate *outputDate = [[NSDate alloc] initWithTimeInterval:(NSTimeInterval)[trip.duration doubleValue] sinceDate:fauxDate];
        
		double mph = ( [trip.distance doubleValue] / 1609.344 ) / ( [trip.duration doubleValue] / 3600. );
		
		self.navigationItem.prompt = [NSString stringWithFormat:@"elapsed: %@ ~ %@",
 									  [inputFormatter stringFromDate:outputDate],
									  [dateFormatter stringFromDate:[trip start]]];
        
		self.title = [NSString stringWithFormat:@"%.1f mi ~ %.1f mph",
					  [trip.distance doubleValue] / 1609.344,
					  mph ];
		
		//self.title = trip.purpose;
		
		// only add info view for trips with non-null notes
		if ( ![trip.notes isEqualToString: @""] && trip.notes != NULL)
		{
			doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(infoAction:)];
			
			UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
			infoButton.showsTouchWhenHighlighted = YES;
			[infoButton addTarget:self action:@selector(infoAction:) forControlEvents:UIControlEventTouchUpInside];
			flipButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
			self.navigationItem.rightBarButtonItem = flipButton;
			
			[self initInfoView];
		}
        
		// sort coords by recorded date
		/*
         NSSortDescriptor *dateDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"recorded"
         ascending:YES] autorelease];
         NSArray *sortDescriptors = [NSArray arrayWithObjects:dateDescriptor, nil];
         NSArray *sortedCoords = [[trip.coords allObjects] sortedArrayUsingDescriptors:sortDescriptors];
         */
		
		// filter coords by hAccuracy
		NSPredicate *filterByAccuracy	= [NSPredicate predicateWithFormat:@"hAccuracy < 100.0"];
		NSArray		*filteredCoords		= [[trip.coords allObjects] filteredArrayUsingPredicate:filterByAccuracy];
		NSLog(@"count of filtered coords = %d", [filteredCoords count]);
		
		// sort filtered coords by recorded date
		NSSortDescriptor *sortByDate	= [[NSSortDescriptor alloc] initWithKey:@"recorded" ascending:YES];
		NSArray		*sortDescriptors	= [NSArray arrayWithObjects:sortByDate, nil];
		NSArray		*sortedCoords		= [filteredCoords sortedArrayUsingDescriptors:sortDescriptors];
		
		// add coords as annotations to map
		BOOL first = YES;
		Coord *last = nil;
		MapCoord *pin = nil;
		int count = 0;
		
		// calculate min/max values for lat, lon
		NSNumber *minLat = [NSNumber numberWithDouble:0.0];
		NSNumber *maxLat = [NSNumber numberWithDouble:0.0];
		NSNumber *minLon = [NSNumber numberWithDouble:0.0];
		NSNumber *maxLon = [NSNumber numberWithDouble:0.0];
        
        NSMutableArray *routeCoords = [[NSMutableArray alloc]init];
        
		for ( Coord *coord in sortedCoords )
		{
			// only plot unique coordinates to our map for performance reasons
			if ( !last ||
				(![coord.latitude  isEqualToNumber:last.latitude] &&
				 ![coord.longitude isEqualToNumber:last.longitude] ) )
			{
                CLLocationCoordinate2D coordinate;
				coordinate.latitude  = [coord.latitude doubleValue];
				coordinate.longitude = [coord.longitude doubleValue];
                
                CLLocation *routePoint = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
				[routeCoords addObject:routePoint];
                
				//pin = [[MapCoord alloc] init];
				//pin.coordinate = coordinate;
				
				if ( first )
				{
					// add start point as a pin annotation
					first = NO;
					//pin.first = YES;
					//pin.title = @"Start";
					//pin.subtitle = [dateFormatter stringFromDate:coord.recorded];
					
					// initialize min/max values to the first coord
					minLat = coord.latitude;
					maxLat = coord.latitude;
					minLon = coord.longitude;
					maxLon = coord.longitude;
				}
				else
				{
					// update min/max values
					if ( [minLat compare:coord.latitude] == NSOrderedDescending )
						minLat = coord.latitude;
					
					if ( [maxLat compare:coord.latitude] == NSOrderedAscending )
						maxLat = coord.latitude;
					
					if ( [minLon compare:coord.longitude] == NSOrderedDescending )
						minLon = coord.longitude;
					
					if ( [maxLon compare:coord.longitude] == NSOrderedAscending )
						maxLon = coord.longitude;
				}
				
				//[mapView addAnnotation:pin];
				count++;
			}
			
			// update last coord pointer so we can cull redundant coords above
			last = coord;
		}
        NSLog(@"routeCoords array is this long: %d@", [routeCoords count]);
        
        NSUInteger numPoints = [routeCoords count];
        CLLocationCoordinate2D *routePath = malloc(numPoints * sizeof(CLLocationCoordinate2D));
        for (NSUInteger index=0; index < numPoints; index ++){
            routePath[index] = [[routeCoords objectAtIndex:index] coordinate];
        }
        
		//TODO: re configure so works like CS map view route drawing?
        //self.routeLine = [MKPolyline polylineWithCoordinates:routePath count:count];
        //[mapView addOverlay:self.routeLine];
        //[mapView setNeedsDisplay];
        
        //add start/end pins
        RMAnnotation *startPoint = [[RMAnnotation alloc] init];
        startPoint.coordinate = routePath[0];
        startPoint.title = @"Start";
		startPoint.annotationIcon=[UIImage imageNamed:@"tripStart.png"];
        [mapView addAnnotation:startPoint];
        RMAnnotation *endPoint = [[RMAnnotation alloc] init];
        endPoint.coordinate = routePath[numPoints-1];
        endPoint.title = @"End";
		endPoint.annotationIcon=[UIImage imageNamed:@"tripEnd.png"];
        [mapView addAnnotation:endPoint];
        
        
        //free(routePath);
		
		NSLog(@"added %d unique GPS coordinates of %d to map", count, [sortedCoords count]);
		
		// add end point as a pin annotation
		if ( last == [sortedCoords lastObject] )
		{
			pin.last = YES;
			pin.title = @"End";
			pin.subtitle = [dateFormatter stringFromDate:last.recorded];
		}
		
		// if we had at least 1 coord
		if ( count )
		{
			// calculate region from coords min/max lat/lon
			/*
             NSLog(@"minLat = %f", [minLat doubleValue]);
             NSLog(@"maxLat = %f", [maxLat doubleValue]);
             NSLog(@"minLon = %f", [minLon doubleValue]);
             NSLog(@"maxLon = %f", [maxLon doubleValue]);
             */
			
			// add a small fudge factor to ensure
			// North-most pins are visible
			double latDelta = kFudgeFactor * ( [maxLat doubleValue] - [minLat doubleValue] );
			if ( latDelta < kMinLatDelta )
				latDelta = kMinLatDelta;
			
			double lonDelta = [maxLon doubleValue] - [minLon doubleValue];
			if ( lonDelta < kMinLonDelta )
				lonDelta = kMinLonDelta;
			
            //			MKCoordinateRegion region = { { [minLat doubleValue] + latDelta / 2,
            //											[minLon doubleValue] + lonDelta / 2 },
            //										  { latDelta,
            //											lonDelta } };
            MKCoordinateRegion region = { { (routePath[0].latitude + routePath[numPoints-1].latitude) / 2,
                (routePath[0].longitude + routePath[numPoints-1].longitude) / 2 },
                { latDelta,
                    lonDelta } };
			//TODO: should be center coord and zoom combo;
			//[mapView setRegion:region animated:NO];
		}
		else
		{
			// init map region to Atlanta
			//TODO: should be center coord and zoom combo;
			MKCoordinateRegion region = { { 33.749038, -84.388068 }, { 0.10825, 0.10825 } };
			//[mapView setRegion:region animated:NO];
		}
        free(routePath);
	}
	else
	{
		// error: init map region to Atlanta
		//TODO: should be center coord and zoom combo;
		MKCoordinateRegion region = { { 33.749038, -84.388068 }, { 0.10825, 0.10825 } };
		//[mapView setRegion:region animated:NO];
	}
    
    LoadingView *loading = (LoadingView*)[self.parentViewController.view viewWithTag:909];
	//NSLog(@"loading: %@", loading);
	[loading performSelector:@selector(removeView) withObject:nil afterDelay:0.5];
}

- (void)viewWillDisappear:(BOOL)animated{
    UIImage *thumbnailOriginal;
    thumbnailOriginal = [self screenshot];
    
    CGRect clippedRect  = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+160, self.view.frame.size.width, self.view.frame.size.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([thumbnailOriginal CGImage], clippedRect);
    UIImage *newImage   = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    CGSize size;
    size.height = 72;
    size.width = 72;
    
    UIImage *thumbnail;
    thumbnail = shrinkImage(newImage, size);
    
    NSData *thumbnailData = [[NSData alloc] initWithData:UIImageJPEGRepresentation(thumbnail, 0)];
    NSLog(@"Size of Thumbnail Image(bytes):%d",[thumbnailData length]);
    NSLog(@"Size: %f, %f", thumbnail.size.height, thumbnail.size.width);
    
    [delegate getTripThumbnail:thumbnailData];
}


UIImage *shrinkImage(UIImage *original, CGSize size) {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(NULL, size.width * scale,
                                                 size.height * scale, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context,
                       CGRectMake(0, 0, size.width * scale, size.height * scale),
                       original.CGImage);
    CGImageRef shrunken = CGBitmapContextCreateImage(context);
    UIImage *final = [UIImage imageWithCGImage:shrunken];
    
    CGContextRelease(context);
    CGImageRelease(shrunken);
    CGColorSpaceRelease(colorSpace);
    return final;
}


- (UIImage*)screenshot
{
    NSLog(@"Screen Shoot");
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y+50);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return screenImage;
}



/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


#pragma mark MKMapViewDelegate methods


- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
	//NSLog(@"mapViewWillStartLoadingMap");
}


- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
	NSLog(@"mapViewDidFailLoadingMap:withError: %@", [error localizedDescription]);
}


- (void)mapViewDidFinishLoadingMap:(MKMapView *)_mapView{
	
	//NSLog(@"mapViewDidFinishLoadingMap");
	LoadingView *loading = (LoadingView*)[self.parentViewController.view viewWithTag:909];
	//NSLog(@"loading: %@", loading);
	[loading removeView];
}


- (RMMapLayer *)mapView:(RMMapView *)aMapView layerForAnnotation:(RMAnnotation *)annotation {
	//NSLog(@"viewForAnnotation");
	
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
	
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MapCoord class]]){
		
		RMMapLayer* annotationView = nil;
		
		if ( [(MapCoord*)annotation first] ){
		
			RMMapLayer *pinView = [[RMMarker alloc] initWithUIImage:annotation.annotationIcon anchorPoint:annotation.anchorPoint];
						
			annotationView = pinView;
			
		} else if ( [(MapCoord*)annotation last] ){
			
			RMMapLayer *pinView = [[RMMarker alloc] initWithUIImage:annotation.annotationIcon anchorPoint:annotation.anchorPoint];
			
			annotationView = pinView;
		}else{
			
			RMMapLayer *pinView = [[RMMarker alloc] initWithUIImage:annotation.annotationIcon anchorPoint:annotation.anchorPoint];
			
			annotationView = pinView;
			
		}
		
        return annotationView;
    } else {
        //handle 'normal' pins
        
        if([annotation.title isEqual:@"Start"]){
            MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"tripPin"];
            annView.image = [UIImage imageNamed:@"tripStart.png"];
            annView.centerOffset = CGPointMake(-(annView.image.size.width/4),(annView.image.size.height/3));
            return annView;
        }else if ([annotation.title isEqual:@"End"]){
            MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"tripPin"];
            annView.image = [UIImage imageNamed:@"tripEnd.png"];
            annView.centerOffset = CGPointMake(-(annView.image.size.width/4),(annView.image.size.height/3));
            return annView;
        }
    }
	
    return nil;
}

- (MKOverlayView*)mapView:(MKMapView*)theMapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView* lineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
    lineView.strokeColor = [UIColor blueColor];
    lineView.lineWidth = 5;
    return lineView;
}

- (void)dealloc {
    self.trip = nil;
    self.doneButton = nil;
    self.flipButton = nil;
    self.infoView = nil;
    self.routeLine = nil;
    self.delegate = nil;
    
}


@end
