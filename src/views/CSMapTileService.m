//
//  CSMapTileService.m
//  CycleStreets
//
//  Created by Neil Edwards on 10/10/2014.
//  Copyright (c) 2014 CycleStreets Ltd. All rights reserved.
//

#import "CSMapTileService.h"

#import "MKMapView+Additions.h"
#import "CSMapSource.h"
#import "MKMapView+LegalLabel.h"
#import "ExpandedUILabel.h"
#import "UIView+Additions.h"
#import "ViewUtilities.h"
#import "GlobalUtilities.h"

@implementation CSMapTileService


+(void)updateMapStyleForMap:(MKMapView*)mapView toMapStyle:(CSMapSource*)mapSource withOverlays:(NSArray*)overlays{
	
	
	if(overlays.count==0){
		
		// if current map source is one of Apple's
		if(![mapSource.uniqueTilecacheKey isEqualToString:MAPPING_BASE_APPLE_VECTOR] && ![mapSource.uniqueTilecacheKey isEqualToString:MAPPING_BASE_APPLE_SATELLITE]){
			
			//TODO: will be YES once Bing tiles are available.
			mapSource.canReplaceMapContent = YES;
			mapSource.maximumZ=mapSource.maxZoom;
			[mapView addOverlay:mapSource level:MKOverlayLevelAboveLabels];
			
			
		}else{
			
			if([mapSource.uniqueTilecacheKey isEqualToString:MAPPING_BASE_APPLE_VECTOR]){
				
				mapView.mapType=MKMapTypeStandard;
				
			}else if([mapSource.uniqueTilecacheKey isEqualToString:MAPPING_BASE_APPLE_SATELLITE]){
				
				mapView.mapType=MKMapTypeHybrid;
				
			}
			
		}
		
	}else{
		
		// if current map source is a custom tile server
		for(id <MKOverlay> overlay in overlays){
			if([overlay isKindOfClass:[MKTileOverlay class]] ){
				
				
				if([mapSource.uniqueTilecacheKey isEqualToString:MAPPING_BASE_APPLE_VECTOR]){
					
					[mapView removeOverlay:overlay];
					
					mapView.mapType=MKMapTypeStandard;
					
				}else if([mapSource.uniqueTilecacheKey isEqualToString:MAPPING_BASE_APPLE_SATELLITE]){
					
					[mapView removeOverlay:overlay];
					
					mapView.mapType=MKMapTypeHybrid;
					
					
				}else{
					
					mapSource.canReplaceMapContent = YES;
					mapSource.maximumZ=mapSource.maxZoom;
					[mapView removeOverlay:overlay];
					[mapView insertOverlay:mapSource atIndex:0 level:MKOverlayLevelAboveLabels]; // always at bottom
					
					
				}
				
			}
		}
		
	}
	
}



+(void)updateMapAttributonLabel:(ExpandedUILabel*)label forMap:(MKMapView*)mapView forMapStyle:(CSMapSource*)mapSource inView:(UIView *)view{
	
	
	if([mapSource.uniqueTilecacheKey isEqualToString:MAPPING_BASE_APPLE_VECTOR] || [mapSource.uniqueTilecacheKey isEqualToString:MAPPING_BASE_APPLE_SATELLITE]){
		
		label.visible=NO;
		mapView.legalLabel.visible=YES;
		
	}else{
		label.visible=YES;
		mapView.legalLabel.visible=NO;
		label.text = mapSource.shortAttribution;
		[ViewUtilities alignView:label withView:view :BURightAlignMode :BUBottomAlignMode :7];
		
	}
	
}

@end
