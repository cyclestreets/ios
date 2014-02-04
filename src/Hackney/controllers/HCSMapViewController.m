//
//  HCSMapViewController
//  CycleStreets
//
//  Created by Neil Edwards on 20/01/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.


#import "Coord.h"
#import "LoadingView.h"
#import "HCSMapViewController.h"
#import "Trip.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "RMMapView.h"
#import "RMAnnotation.h"
#import "RMMarker.h"
#import "UserLocationManager.h"
#import "CycleStreets.h"
#import "GlobalUtilities.h"
#import "GenericConstants.h"
#import "LayoutBox.h"
#import "CSPointVO.h"
#import "RouteVO.h"
#import "SegmentVO.h"
#import "ExpandedUILabel.h"
#import "HudManager.h"
#import "TripManager.h"
#import "UIView+Additions.h"

#define kFudgeFactor	1.5
#define kInfoViewAlpha	0.8
#define kMinLatDelta	0.0039
#define kMinLonDelta	0.0034

@interface HCSMapViewController()<RMMapViewDelegate,UIGestureRecognizerDelegate>


@property(nonatomic,weak) IBOutlet UINavigationItem					*myNavigationItem;


@property (nonatomic, strong) UIBarButtonItem						*doneButton;
@property (nonatomic, weak) IBOutlet UIButton						*infoButton;
@property (nonatomic, strong) LayoutBox								*infoView;
@property(nonatomic,weak) IBOutlet UIBarButtonItem					*backButton;
@property(nonatomic,strong) IBOutlet UIBarButtonItem				*uploadButton;

@property (nonatomic,weak) IBOutlet UILabel							*routeInfoLabel;


@property (nonatomic,weak) IBOutlet RMMapView						*mapView;
@property (nonatomic,weak) IBOutlet RouteLineView					*routeLineView;

@property (nonatomic,strong) RouteVO								*currentRoute;


@end


@implementation HCSMapViewController

//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[self initialise];
	
	[notifications addObject:RESPONSE_GPSUPLOAD];
	[notifications addObject:MAPSTYLECHANGED];
	[notifications addObject:MAPUNITCHANGED];
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	[super didReceiveNotification:notification];
	
	NSString *name=notification.name;
	
	if([name isEqualToString:RESPONSE_GPSUPLOAD]){
		[self refreshUIFromDataProvider:notification.object];
	}
	
	if([name isEqualToString:MAPSTYLECHANGED]){
		[self didNotificationMapStyleChanged];
	}
	
	if([name isEqualToString:MAPUNITCHANGED]){
		[self didNotificationMapUnitChanged];
	}
	
}


#pragma mark - Notification methods

- (void) didNotificationMapStyleChanged {
	self.mapView.tileSource = [CycleStreets tileSource];
	//_attributionLabel.text = [MapViewController mapAttribution];
}


- (void) didNotificationMapUnitChanged {
	
	_myNavigationItem.title = [NSString stringWithFormat:@"%@ ~ %@", [_trip lengthString], [_trip speedString] ];
	
}



-(void)refreshUIFromDataProvider:(NSDictionary*)stateDict{
	
	NSString *state=stateDict[STATE];
	
	if([state isEqualToString:SUCCESS]){
		
		_uploadButton.enabled=!_trip.isUploaded;
		
	}
	
	
}


#pragma mark - View


- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[RMMapView class];
	[_mapView setDelegate:self];
	_mapView.tileSource = [CycleStreets tileSource];
	_mapView.enableDragging=YES;
	
	_routeLineView.pointListProvider=self;
	
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	
	
    
	if (_trip )
	{
		// format date as a string
		static NSDateFormatter *dateFormatter = nil;
		if (dateFormatter == nil) {
			dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
			[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		}
		
		
		self.routeInfoLabel.text = [NSString stringWithFormat:@"elapsed: %@ ~ %@",
									_trip.timeString,
									[dateFormatter stringFromDate:[_trip start]]];
        
		_myNavigationItem.title = [NSString stringWithFormat:@"%@ ~ %@", [_trip lengthString], [_trip speedString] ];
		
		
		// only add info view for trips with non-null notes
		if ( ![_trip.notes isEqualToString:EMPTYSTRING] && _trip.notes != nil)
		{
			_doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(infoAction:)];
			_infoButton.visible=YES;
			[self initInfoView];
		}else{
			_infoButton.visible=NO;
		}
		
        
		
		switch (_viewMode) {
			case HCSMapViewModeSave:
			{
				self.myNavigationItem.leftBarButtonItem=[self backButtonWithTitle:@"Done"];
			}
				break;
			case HCSMapViewModeShow:
			{
				self.myNavigationItem.leftBarButtonItem=[self backButtonWithTitle:@"Back"];
			}
				break;
		}
		
		//_uploadButton.enabled=_trip.uploaded==nil;
		
		
		
		// add coords as annotations to map
        NSMutableArray *routeCoords = [[NSMutableArray alloc]init];
		self.currentRoute=[[RouteVO alloc]init];
        
		for ( Coord *coord in _trip.coords ){
			
			// this is a bit convoluted but meets comaptibility for routeline drawing
			SegmentVO *segment=[[SegmentVO alloc]init];
			CSPointVO *point=[[CSPointVO alloc]init];
			point.p=CGPointMake([coord.longitude doubleValue],[coord.latitude doubleValue]);
			segment.pointsArray=@[point];
				
			BetterLog(@"%@",[coord longDescription]);
				
			[routeCoords addObject:segment];
			
		}
		
		_currentRoute.segments=routeCoords;
        
		[_routeLineView setNeedsDisplay];
        
        
		BetterLog(@"added %d GPS coordinates to map", routeCoords.count);
		
		
		// if we had at least 1 coord
		if ( routeCoords.count>0 ){
			
			[_currentRoute calculateNorthSouthValues];
			
			CLLocationCoordinate2D ne=[_currentRoute insetNorthEast];
			CLLocationCoordinate2D sw=[_currentRoute insetSouthWest];
			[_mapView zoomWithLatitudeLongitudeBoundsSouthWest:sw northEast:ne animated:YES];
			
			
			//add start/end pins
			SegmentVO *firstsegment=(SegmentVO*)[routeCoords firstObject];
			RMAnnotation *startPoint = [[RMAnnotation alloc] initWithMapView:_mapView coordinate:firstsegment.segmentStart andTitle:@"Start"];
			startPoint.annotationIcon=[UIImage imageNamed:@"tripStart.png"];
			startPoint.anchorPoint=CGPointMake(0.5,0.5);
			[_mapView addAnnotation:startPoint];
			
			SegmentVO *lastsegment=(SegmentVO*)[routeCoords lastObject];
			RMAnnotation *endPoint = [[RMAnnotation alloc] initWithMapView:_mapView coordinate:lastsegment.segmentStart andTitle:@"End"];
			endPoint.annotationIcon=[UIImage imageNamed:@"tripEnd.png"];
			endPoint.anchorPoint=CGPointMake(0.5,0.5);
			[_mapView addAnnotation:endPoint];
			
			
		}else{
			[_mapView setCenterCoordinate:[UserLocationManager defaultCoordinate]];
		}
        
	}else{
		[_mapView setCenterCoordinate:[UserLocationManager defaultCoordinate]];
	}
    
	if(_viewMode==HCSMapViewModeShow)
		[[HudManager sharedInstance] showHudWithType:HUDWindowTypeSuccess withTitle:@"Route loaded" andMessage:nil andDelay:1 andAllowTouch:NO];
	
	
}




- (IBAction)infoAction:(UIButton*)sender
{
	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:animationIDfinished:finished:context:)];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	
	[UIView setAnimationTransition:([_infoView superview] ?
									UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
						   forView:self.view cache:YES];
	
	if ([_infoView superview])
		[_infoView removeFromSuperview];
	else
		[self.view addSubview:_infoView];
	
	[UIView commitAnimations];
	
	// adjust our done/info buttons accordingly
	if ([_infoView superview] == self.view){
		_myNavigationItem.rightBarButtonItem = _doneButton;
	}else{
		_myNavigationItem.rightBarButtonItem = _uploadButton;
	}
		
}


- (void)initInfoView
{
	
	_infoView=[[LayoutBox alloc]initWithFrame:CGRectMake(0,64,320,560)];
	_infoView.fixedWidth=YES;
	_infoView.fixedHeight=YES;
	_infoView.paddingLeft=10;
	_infoView.paddingTop=10;
	_infoView.itemPadding=20;
	_infoView.layoutMode=BUVerticalLayoutMode;
	_infoView.backgroundColor=UIColorFromRGBAndAlpha(0x000000, kInfoViewAlpha);
	
	
	ExpandedUILabel *notesHeader=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 10)];
	notesHeader.fixedWidth=YES;
	notesHeader.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:18];
	notesHeader.textColor=UIColorFromRGB(0xFFFFFF);
	notesHeader.text = @"Trip Notes";
	[_infoView addSubview:notesHeader];
	
	ExpandedUILabel *notesText=[[ExpandedUILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 10)];
	notesText.fixedWidth=YES;
	notesText.font=[UIFont fontWithName:@"HelveticaNeue-Regular" size:16];
	notesText.textColor=UIColorFromRGB(0xFFFFFF);
	notesText.text = _trip.notes;
	[_infoView addSubview:notesText];
	
	[_infoView refresh];
    
}


- (UIBarButtonItem *)backButtonWithTitle:(NSString*)title
{
	UIImage *image = [UIImage imageNamed:@"UINavigationBarBackIndicatorDefault.png"];
	CGRect buttonFrame = CGRectMake(0, 0, 70,30);
	
	
	UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
	button.tintColor=[UIColor whiteColor];
	[button addTarget:self action:@selector(didSelectBackButton) forControlEvents:UIControlEventTouchUpInside];
	[button setTitle:title forState:UIControlStateNormal];
	[button setImage:image forState:UIControlStateNormal];
	[button setImageEdgeInsets:UIEdgeInsetsMake(0, -7, 0, 0)];
	[button setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
	
	UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
	
	return item;
}





#pragma mark - Route line point list provider
// PointListProvider
+ (NSArray *) pointList:(RouteVO *)route withView:(RMMapView *)mapView {
	
	NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:10];
	if (route == nil) {
		return points;
	}
	
	for (int i = 0; i < [route numSegments]; i++) {
			CSPointVO *p = [[CSPointVO alloc] init];
			SegmentVO *segment = [route segmentAtIndex:i];
			CLLocationCoordinate2D coordinate = [segment segmentStart];
			CGPoint pt = [mapView coordinateToPixel:coordinate];
			p.p = pt;
			[points addObject:p];
	}
	
	return points;
}

- (NSArray *) pointList {
	return [HCSMapViewController pointList:_currentRoute withView:_mapView];
}






#pragma mark User events


-(IBAction)didSelectBackButton{
	
	switch (_viewMode) {
		case HCSMapViewModeSave:
		{
			[[TripManager sharedInstance] removeCurrentRecordingTrip];
			[_tripDelegate dismissTripSaveController];
		}
			
		break;
		case HCSMapViewModeShow:
			[self.navigationController popViewControllerAnimated:YES];
		break;
	}
	
	
	
}


-(IBAction)didSelectUploadButton:(id)sender{
	
	[[TripManager sharedInstance] uploadSelectedTrip:_trip];
	
}



#pragma mark RMMapView delegate methods



-(void)doubleTapOnMap:(RMMapView*)map At:(CGPoint)point{
	
}

-(void) beforeMapMove:(RMMapView *)map byUser:(BOOL)wasUserAction{
	//[_routeLineView setNeedsDisplay];
}

- (void) afterMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center {
	[_routeLineView setNeedsDisplay];
}

- (void) afterMapMove:(RMMapView *)map byUser:(BOOL)wasUserAction{
	
	[_routeLineView setNeedsDisplay];
}

-(void)mapViewRegionDidChange:(RMMapView *)mapView{
	[_routeLineView setNeedsDisplay];
}


#pragma mark - Annotation methods

- (RMMapLayer *)mapView:(RMMapView *)aMapView layerForAnnotation:(RMAnnotation *)annotation {
	
	
	RMMapLayer *annotationView = [[RMMarker alloc] initWithUIImage:annotation.annotationIcon anchorPoint:annotation.anchorPoint];
		
	return annotationView;
   
}


- (void)tapOnAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
	
	
	
	
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
