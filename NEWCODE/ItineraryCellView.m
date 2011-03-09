//
//  ItineraryCellView.m
//  CycleStreets
//
//  Created by Neil Edwards on 09/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "ItineraryCellView.h"
#import "AppConstants.h"

@implementation ItineraryCellView
@synthesize dataProvider;
@synthesize roadLabel;
@synthesize timeLabel;
@synthesize distanceLabel;
@synthesize totalLabel;
@synthesize imageView;

/***********************************************************/
// dealloc
/***********************************************************/
- (void)dealloc
{
    [dataProvider release], dataProvider = nil;
    [roadLabel release], roadLabel = nil;
    [timeLabel release], timeLabel = nil;
    [distanceLabel release], distanceLabel = nil;
    [totalLabel release], totalLabel = nil;
    [imageView release], imageView = nil;
	
    [super dealloc];
}




-(void)initialise{




}

-(void)populate{
	
	roadLabel.text=[dataProvider roadName];
	timeLabel.text=[NSString stringWithFormat:@"%02d:%02d", dataProvider.startTime/60, dataProvider.startTime%60];
	distanceLabel.text=[NSString stringWithFormat:@"%4dm", [dataProvider segmentDistance]];
	
	float totalMiles = ((float)([dataProvider startDistance]+[dataProvider segmentDistance]))/1600;
	totalLabel.text=[NSString stringWithFormat:@"(%3.1f miles)", totalMiles];
	
	NSString *imageName = [Segment provisionIcon:[dataProvider provisionName]];
	imageView.image=[UIImage imageNamed:imageName];
	

}



+(int)rowHeight{
	return STANDARDCELLHEIGHT;
}

+(NSString*)cellIdentifier{
	return @"ItineraryCellViewIdentifer";
}

@end
