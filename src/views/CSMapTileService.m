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

@implementation CSMapTileService


+(void)updateMapStyleForMap:(MKMapView*)mapView toMapStyle:(CSMapSource*)mapSource withOverlays:(NSArray*)overlays{
	
	
	if(overlays.count==0){
		
		if(![mapSource.uniqueTilecacheKey isEqualToString:MAPPING_BASE_APPLE_VECTOR] && ![mapSource.uniqueTilecacheKey isEqualToString:MAPPING_BASE_APPLE_SATELLITE]){
			
			
			MKTileOverlay *newoverlay = [[MKTileOverlay alloc] initWithURLTemplate:mapSource.tileTemplate];
			newoverlay.canReplaceMapContent = YES;
			newoverlay.maximumZ=mapSource.maxZoom;
			[mapView insertOverlay:newoverlay atIndex:0 level:MKOverlayLevelAboveLabels];
			
			
		}else{
			
			if([mapSource.uniqueTilecacheKey isEqualToString:MAPPING_BASE_APPLE_VECTOR]){
				
				mapView.mapType=MKMapTypeStandard;
				
			}else if([mapSource.uniqueTilecacheKey isEqualToString:MAPPING_BASE_APPLE_SATELLITE]){
				
				mapView.mapType=MKMapTypeHybrid;
				
			}
			
		}
		
	}else{
		
		for(id <MKOverlay> overlay in overlays){
			if([overlay isKindOfClass:[MKTileOverlay class]] ){
				
				
				if([mapSource.uniqueTilecacheKey isEqualToString:MAPPING_BASE_APPLE_VECTOR]){
					
					
					[mapView removeOverlay:overlay];
					
					mapView.mapType=MKMapTypeStandard;
					
					break;
					
				}else if([mapSource.uniqueTilecacheKey isEqualToString:MAPPING_BASE_APPLE_SATELLITE]){
					
					[mapView removeOverlay:overlay];
					
					mapView.mapType=MKMapTypeHybrid;
					
					break;
					
				}else{
					
					MKTileOverlay *newoverlay = [[MKTileOverlay alloc] initWithURLTemplate:mapSource.tileTemplate];
					newoverlay.canReplaceMapContent = YES;
					newoverlay.maximumZ=mapSource.maxZoom;
					[mapView removeOverlay:overlay];
					[mapView insertOverlay:newoverlay atIndex:0 level:MKOverlayLevelAboveLabels]; // always at bottom
					
					
					break;
					
				}
				
				
				break;
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
