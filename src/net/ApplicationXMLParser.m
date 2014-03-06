//
//  TBXMLParser.m
//  CycleStreets
//
//  Created by neil on 04/03/2010.
//  Copyright 2010 CycleStreets.. All rights reserved.
//

#import "ApplicationXMLParser.h"
#import "GlobalUtilities.h"
#import "AppConstants.h"
#import "StringUtilities.h"
#import "TBXML.h"
#import "ValidationVO.h"
#import "NSDate+Helper.h"
#import "LoginVO.h"
#import "POICategoryVO.h"
#import "POILocationVO.h"
#import "NSString+HTML.h"
//
#import "RouteVO.h"
#import "SegmentVO.h"
#import "CSPointVO.h"
#import "PhotoMapVO.h"
#import "PhotoMapListVO.h"
#import "PhotoCategoryVO.h"

#import "TBXML+Additions.h"

#import "BUNetworkOperation.h"

@interface ApplicationXMLParser()


@property(nonatomic,strong)NSMutableDictionary *parsers;
@property(nonatomic,strong)NSDictionary *parserMethods;
@property(nonatomic,strong)NSString *parserError;
@property(nonatomic,strong)BUNetworkOperation *activeOperation;



// user account
-(void)LoginXMLParser:(TBXML*)parser;
-(void)RegisterXMLParser:(TBXML*)parser;
-(void)RetrievePasswordXMLParser:(TBXML*)parser;


// routes
-(void)CalculateRouteXMLParser:(TBXML*)parser;


// photos
-(void)PhotoUploadXMLParser:(TBXML*)parser;
-(void)RetrievePhotosXMLParser:(TBXML*)parser;


// pois
-(void)POIListingXMLParser:(TBXML*)parser;
-(void)POICategoryXMLParser:(TBXML*)parser;


// categories
-(void)PhotoCategoriesXMLParser:(TBXML*)parser;



//utility

-(RouteVO*)newRouteForData:(TBXMLElement*)response;


@end

@implementation ApplicationXMLParser
SYNTHESIZE_SINGLETON_FOR_CLASS(ApplicationXMLParser);




-(id)init{
	if (self = [super init])
	{
		_parserMethods=[[NSDictionary alloc] initWithObjectsAndKeys:
					   [NSValue valueWithPointer:@selector(LoginXMLParser:)],LOGIN,
					   [NSValue valueWithPointer:@selector(RegisterXMLParser:)],REGISTER,
					   [NSValue valueWithPointer:@selector(RetrievePasswordXMLParser:)],PASSWORDRETRIEVAL,
                       [NSValue valueWithPointer:@selector(RetrievePhotosXMLParser:)],RETREIVELOCATIONPHOTOS,
					   [NSValue valueWithPointer:@selector(RetrievePhotosXMLParser:)],RETREIVEROUTEPHOTOS,
                       [NSValue valueWithPointer:@selector(PhotoUploadXMLParser:)],UPLOADUSERPHOTO,
					   [NSValue valueWithPointer:@selector(POIListingXMLParser:)],POILISTING,
					   [NSValue valueWithPointer:@selector(POICategoryXMLParser:)],POICATEGORYLOCATION,
					   [NSValue valueWithPointer:@selector(CalculateRouteXMLParser:)],CALCULATEROUTE,
					   [NSValue valueWithPointer:@selector(CalculateRouteXMLParser:)],RETRIEVEROUTEBYID, // note: uses same response parser
					   [NSValue valueWithPointer:@selector(PhotoCategoriesXMLParser:)],PHOTOCATEGORIES, // note: uses same response parser
					   nil];
		
		_parsers=[[NSMutableDictionary alloc]init];
	}
	return self;
}




-(void)parseDataForOperation:(BUNetworkOperation* )networkOperation success:(ParserCompletionBlock)success failure:(ParserErrorBlock)failure{
	
	BetterLog(@"");
	
	SEL parserMethod=[[_parserMethods objectForKey:networkOperation.dataid] pointerValue];
	
	if(parserMethod!=nil){
        
        self.activeOperation=networkOperation;
		
		NSError *error;
        TBXML	*parser=[TBXML tbxmlWithXMLData:_activeOperation.responseData error:&error ];
		[self performSelector:parserMethod withObject:parser];
		
		if(_activeOperation.operationState==NetResponseStateComplete){
			
			BetterLog(@"[DEBUG] Success activeResponse.dataid=%@ activeResponse.requestid=%@",_activeOperation.dataid,_activeOperation.requestid);
			
			success(_activeOperation);
			
		}else {
			
			BetterLog(@"[ERROR] ApplicationXMLParser:XMLParserDidFail for DataId=%@",_activeOperation.dataid);
			
			failure(_activeOperation,error);
		}
		
		
	}else {
		
		BetterLog(@"[ERROR] ApplicationXMLParser:parseXMLForType: parser for type %@ not found!",_activeOperation.dataid);
		
	}
	
	
}




#pragma mark Section XML Parsering methods



-(BOOL)validateXML:(TBXMLElement*)root{
	
	BetterLog(@"");
	
	BOOL result=YES;
	
	if(root==nil){
			_activeOperation.operationError=NetResponseErrorInvalidResponse;
			_activeOperation.operationState=NetResponseStateError;
			return NO;
		}
		
		BOOL hasChildren=[TBXML hasChildrenForParentElement:root];
		
		// capture responses with no response data
		// this is a valid fault
		if(hasChildren==NO){
			_activeOperation.operationError=NetResponseErrorInvalidResponse;
			_activeOperation.operationState=NetResponseStateError;
			return NO;
		}
		
		// capture valid requests with with 0 response entries
		// this is not inherently a fault but is treated as such
		// to trigger the no results logic
		if ([TBXML childElementNamed:@"NoResults" parentElement:root]!=nil) {
			_activeOperation.operationError=NetResponseErrorNoResults;
			_activeOperation.operationState=NetResponseStateError;
			return NO;
		}
		
			
	
	return result;
	
}




-(id)parseXML:(NSData*)data forType:(NSString*)datatype{
	
	
	if([datatype isEqualToString:CALCULATEROUTE]){
		
		TBXML	*parser=[[TBXML alloc]initWithXMLData:data]; 
		RouteVO *route=[self newRouteForData:parser.rootXMLElement];
		return route;
		
	}else{
		return nil;
	}
	
	
	
}



//
/***********************************************
 * @description			USER ACCOUNT METHODS
 ***********************************************/
//

-(void)LoginXMLParser:(TBXML*)parser{
	
	TBXMLElement *response = parser.rootXMLElement;
	
	[self validateXML:response];
	if(_activeOperation.operationState>NetResponseStateComplete){
		return;
	}
	
	LoginVO		*loginResponse=[[LoginVO alloc]init];
	loginResponse.requestname=[TBXML textForElement:[TBXML childElementNamed:@"request" parentElement:response]];
	
	TBXMLElement *resultelement=[TBXML childElementNamed:@"result" parentElement:response];
	
	if([TBXML hasChildrenForParentElement:resultelement]==YES){
		
		_activeOperation.validationStatus=ValidationLoginSuccess;
		_activeOperation.operationState=NetResponseStateComplete;
		
		loginResponse.username=[TBXML textForElement:[TBXML childElementNamed:@"username" parentElement:resultelement]];
		loginResponse.userid=[[TBXML textForElement:[TBXML childElementNamed:@"id" parentElement:resultelement]] intValue];
		loginResponse.email=[TBXML textForElement:[TBXML childElementNamed:@"email" parentElement:resultelement]];
		loginResponse.name=[TBXML textForElement:[TBXML childElementNamed:@"name" parentElement:resultelement]];
		loginResponse.validatedDate=[TBXML textForElement:[TBXML childElementNamed:@"validated" parentElement:resultelement]];
		loginResponse.userIP=[TBXML textForElement:[TBXML childElementNamed:@"ip" parentElement:resultelement]];
		
		loginResponse.validatekey=[[TBXML textForElement:[TBXML childElementNamed:@"validatekey" parentElement:resultelement]] boolValue];
		loginResponse.deleted=[[TBXML textForElement:[TBXML childElementNamed:@"deleted" parentElement:resultelement]] boolValue];
		loginResponse.lastsignin=[[TBXML textForElement:[TBXML childElementNamed:@"lastsignin" parentElement:resultelement]] intValue];
		
		
		
	}else {
		_activeOperation.validationStatus=ValidationLoginFailed;
		
	}

	_activeOperation.dataProvider=loginResponse;
	
}



-(void)RegisterXMLParser:(TBXML*)parser{
	
	TBXMLElement *response = parser.rootXMLElement;
	
	[self validateXML:response];
	if(_activeOperation.operationState>NetResponseStateComplete){
		return;
	}
	
	
	TBXMLElement *resultelement=[TBXML childElementNamed:@"result" parentElement:response];
	
	if([TBXML hasChildrenForParentElement:resultelement]==YES){
		
		int code=[[TBXML textForElement:[TBXML childElementNamed:@"code" parentElement:resultelement]]intValue];
		if(code==1){
			_activeOperation.validationStatus=ValidationRegisterSuccess;
		}else {
			_activeOperation.validationStatus=ValidationRegisterFailed;
		}

		_activeOperation.validationMessage=[TBXML textForElement:[TBXML childElementNamed:@"message" parentElement:resultelement]];
		_activeOperation.operationState=NetResponseStateComplete;
		
	}else {
		
		_activeOperation.validationStatus=ValidationRegisterFailed;
		
	}

	
}

-(void)RetrievePasswordXMLParser:(TBXML*)parser{
	
	TBXMLElement *response = parser.rootXMLElement;
	
	[self validateXML:response];
	if(_activeOperation.operationState>NetResponseStateComplete){
		return;
	}

	
	_activeOperation.validationStatus=[[TBXML textForElement:[TBXML childElementNamed:@"ReturnCode" parentElement:response]]intValue];
	_activeOperation.validationMessage=[TBXML textForElement:[TBXML childElementNamed:@"ReturnMsg" parentElement:response]];
		
}



#pragma mark Routes
//
/***********************************************
 * @description			ROUTING
 ***********************************************/
//

// used by RETRIEVEROUTEBYID also
-(void)CalculateRouteXMLParser:(TBXML*)parser{
	
	BetterLog(@"");
	
	TBXMLElement *response = parser.rootXMLElement;
	
	[self validateXML:response];
	if(_activeOperation.operationState>NetResponseStateComplete){
		return;
	}
	
	
	RouteVO *route=[self newRouteForData:response];
	
	if(route!=nil){
		
		if([route numSegments]==0){
			
			_activeOperation.validationStatus=ValidationCalculateRouteFailed;
			
		}else{
			
			_activeOperation.dataProvider=route;
			
			_activeOperation.operationState=NetResponseStateComplete;
			_activeOperation.validationStatus=ValidationCalculateRouteSuccess;
			
		}
		
		
	}else{
		
		_activeOperation.validationStatus=ValidationCalculateRouteFailed;
		
		
		TBXMLElement *root=[TBXML childElementNamed:@"gml:featureMember" parentElement:response];
		TBXMLElement *issuenode=[TBXML childElementNamed:@"cs:notedIssue" parentElement:root];
		
		if(issuenode!=nil){
			
			int code=[[TBXML textOfChild:@"cs:code" parentElement:issuenode]intValue];
			if(code==ValidationCalculateRouteFailedOffNetwork){
				_activeOperation.validationStatus=ValidationCalculateRouteFailedOffNetwork;
			}
			
			_activeOperation.validationMessage=[TBXML textOfChild:@"cs:text" parentElement:issuenode];
			
		}
		
		
		
	}
	
	
}



-(RouteVO*)newRouteForData:(TBXMLElement*)response{
	
	
	TBXMLElement *root=[TBXML childElementNamed:@"gml:featureMember" parentElement:response];
	TBXMLElement *routenode=[TBXML childElementNamed:@"cs:route" parentElement:root];
	
	RouteVO *route;
	
	if(routenode!=nil){
	
		route=[[RouteVO alloc]init];
		
		route.routeid=[TBXML textForElement:[TBXML childElementNamed:@"cs:itinerary" parentElement:routenode]];
		route.length=[NSNumber numberWithInt:[[TBXML textForElement:[TBXML childElementNamed:@"cs:length" parentElement:routenode]]intValue]];
		route.plan=[TBXML textForElement:[TBXML childElementNamed:@"cs:plan" parentElement:routenode]];
		route.name=[TBXML textForElement:[TBXML childElementNamed:@"cs:name" parentElement:routenode]];
		route.date=[TBXML textForElement:[TBXML childElementNamed:@"cs:whence" parentElement:routenode]]; // ie date-time
		route.speed=[[TBXML textForElement:[TBXML childElementNamed:@"cs:speed" parentElement:routenode]]intValue];
		route.time=[[TBXML textForElement:[TBXML childElementNamed:@"cs:time" parentElement:routenode]]intValue];
		route.calorie=[TBXML textForElement:[TBXML childElementNamed:@"cs:calories" parentElement:routenode]];
		route.cosaved=[TBXML textForElement:[TBXML childElementNamed:@"cs:grammesCO2saved" parentElement:routenode]];
		
		CLLocationCoordinate2D nelocation;
		nelocation.latitude=[[TBXML textForElement:[TBXML childElementNamed:@"cs:north" parentElement:routenode]] floatValue];
		nelocation.longitude=[[TBXML textForElement:[TBXML childElementNamed:@"cs:east" parentElement:routenode]] floatValue];
		CLLocation *ne=[[CLLocation alloc] initWithLatitude:nelocation.latitude longitude:nelocation.longitude];
		route.northEast=ne;
		
		CLLocationCoordinate2D swlocation;
		swlocation.latitude=[[TBXML textForElement:[TBXML childElementNamed:@"cs:south" parentElement:routenode]] floatValue];
		swlocation.longitude=[[TBXML textForElement:[TBXML childElementNamed:@"cs:west" parentElement:routenode]] floatValue];
		CLLocation *sw=[[CLLocation alloc] initWithLatitude:swlocation.latitude longitude:swlocation.longitude];
		route.southWest=sw;
		
		
		
		NSMutableArray	*segments=[[NSMutableArray alloc]init];
		NSMutableArray	*waypoints=[[NSMutableArray alloc]init];
		root=root->nextSibling;
		
		NSInteger time = 0;
		NSInteger distance = 0;
		
		while (root!=nil) {
			
			TBXMLElement *segmentnode=[TBXML childElementNamed:@"cs:segment" parentElement:root];
			
			if(segmentnode!=nil){
				
				SegmentVO *segment=[[SegmentVO alloc]init];
				
				segment.provisionName=[TBXML textForElement:[TBXML childElementNamed:@"cs:provisionName" parentElement:segmentnode]];
				
				segment.roadName=[TBXML textForElement:[TBXML childElementNamed:@"cs:name" parentElement:segmentnode]];
				segment.segmentTime=[[TBXML textForElement:[TBXML childElementNamed:@"cs:time" parentElement:segmentnode]]intValue];
				segment.segmentDistance=[[TBXML textForElement:[TBXML childElementNamed:@"cs:distance" parentElement:segmentnode]]intValue];
				segment.walkValue=[[TBXML textForElement:[TBXML childElementNamed:@"cs:walk" parentElement:segmentnode]]intValue];
				segment.startBearing=[[TBXML textForElement:[TBXML childElementNamed:@"cs:startBearing" parentElement:segmentnode]]intValue];
				segment.segmentBusynance=[[TBXML textForElement:[TBXML childElementNamed:@"cs:busynance" parentElement:segmentnode]]intValue];
				
				segment.turnType=[TBXML textForElement:[TBXML childElementNamed:@"cs:turn" parentElement:segmentnode]];	
				segment.startTime=time;
				segment.startDistance=distance;
				
				// groups pints into lat/long array
				NSString *points=[TBXML textForElement:[TBXML childElementNamed:@"cs:points" parentElement:segmentnode]];
				
				NSCharacterSet *whiteComma = [NSCharacterSet characterSetWithCharactersInString:@", "];
				NSArray *XYs = [points componentsSeparatedByCharactersInSet:whiteComma];
				NSMutableArray *result = [[NSMutableArray alloc] init];
				for (int X = 0; X < [XYs count]; X += 2) {
					CSPointVO *p = [[CSPointVO alloc] init];
					CGPoint point;
					point.x = [[XYs objectAtIndex:X] doubleValue];
					point.y = [[XYs objectAtIndex:X+1] doubleValue];
					p.point = point;
					p.isWalking=segment.isWalkingSection;
					[result addObject:p];
				}
				segment.pointsArray=result;
				
				time += [segment segmentTime];
				distance += [segment segmentDistance];
				
				[segments addObject:segment];
			
			}
			
			
			TBXMLElement *waypointnode=[TBXML childElementNamed:@"cs:waypoint" parentElement:root];
			
			if(waypointnode!=nil){
				
				CSPointVO *waypoint=[[CSPointVO alloc]init];
				CGPoint point;
				point.x=[[TBXML textOfChild:@"cs:longitude" parentElement:waypointnode] doubleValue];
				point.y=[[TBXML textOfChild:@"cs:latitude" parentElement:waypointnode] doubleValue];
				waypoint.point=point;
				
				[waypoints addObject:waypoint];
				
			}
			
			
			root=root->nextSibling;
			
		}
		
		route.segments=segments;
		route.waypoints=waypoints;
	
	
	}
	
	return route;
	
}





#pragma mark Photos



-(void)PhotoUploadXMLParser:(TBXML*)parser{
	
	BetterLog(@"");
    
    TBXMLElement *response = parser.rootXMLElement;
	
	[self validateXML:response];
	if(_activeOperation.operationState>NetResponseStateComplete){
		return;
	}
    
	
	_activeOperation.validationStatus=ValidationUserPhotoUploadFailed;
	
	//Hmm, responses return unrequired nodes
	
	TBXMLElement *errornode=[TBXML childElementNamed:@"error" parentElement:response];
	TBXMLElement *codenode=[TBXML childElementNamed:@"code" parentElement:errornode];
	
	if(codenode==nil){
		
		TBXMLElement *resultnode=[TBXML childElementNamed:@"result" parentElement:response];
		
		if(resultnode!=nil){
			NSMutableDictionary *responseDict=[TBXML newDictonaryFromXMLElement:resultnode];
			_activeOperation.dataProvider=responseDict;
			_activeOperation.validationStatus=ValidationUserPhotoUploadSuccess;
			_activeOperation.operationState=NetResponseStateComplete;
		}
		
		
	}else {
		
		_activeOperation.validationMessage=[TBXML textForElement:codenode];
		
	}
    
    
}





-(void)RetrievePhotosXMLParser:(TBXML*)parser{
	
	BetterLog(@"");
    
    TBXMLElement *response = parser.rootXMLElement;
	
	[self validateXML:response];
	if(_activeOperation.operationState>NetResponseStateComplete){
		_activeOperation.validationStatus=ValidationRetrievePhotosFailed;
		_activeOperation.operationState=NetResponseStateComplete; //TODO: Why??
		return;
	}
    
    
    
    TBXMLElement *root=[TBXML childElementNamed:@"gml:featureMember" parentElement:response];
	
	
	if(root!=nil){
	
		PhotoMapListVO *photolist=[[PhotoMapListVO alloc]init];
		NSMutableArray	*arr=[[NSMutableArray alloc]init];
		
		while (root!=nil) {
			
			TBXMLElement *photonode=[TBXML childElementNamed:@"cs:photo" parentElement:root];
			
			PhotoMapVO *photo=[[PhotoMapVO alloc]init];
			
			CLLocationCoordinate2D location;
			location.longitude=[[TBXML textForElement:[TBXML childElementNamed:@"cs:longitude" parentElement:photonode]] floatValue];
			location.latitude=[[TBXML textForElement:[TBXML childElementNamed:@"cs:latitude" parentElement:photonode]] floatValue];
			photo.locationCoords=location;
			
			photo.csid=[TBXML textForElement:[TBXML childElementNamed:@"cs:id" parentElement:photonode]];
			photo.caption=[TBXML textForElement:[TBXML childElementNamed:@"cs:caption" parentElement:photonode]];
			photo.bigImageURL=[TBXML textForElement:[TBXML childElementNamed:@"cs:thumbnailUrl" parentElement:photonode]];
			[photo generateSmallImageURL:[TBXML textForElement:[TBXML childElementNamed:@"cs:thumbnailSizes" parentElement:photonode]]];
			
			[arr addObject:photo];
			
			root=root->nextSibling;
			
		}
		
		photolist.photos=arr;
		
		_activeOperation.dataProvider=photolist;
		
		_activeOperation.validationStatus=ValidationRetrievePhotosSuccess;
		_activeOperation.operationState=NetResponseStateComplete;
		
	}else{
		
		_activeOperation.validationStatus=ValidationRetrievePhotosFailed;
		
	}
	
    
    
}


#pragma mark POIs

// pois
-(void)POIListingXMLParser:(TBXML*)parser{
	
	BetterLog(@"");
	
	TBXMLElement *response = parser.rootXMLElement;
	
	[self validateXML:response];
	if(_activeOperation.operationState>NetResponseStateComplete){
		return;
	}
    
	
	TBXMLElement *poitypes=[TBXML childElementNamed:@"poitypes" parentElement:response];
	TBXMLElement *poitype=[TBXML childElementNamed:@"poitype" parentElement:poitypes];

	if(poitype!=nil){
		
		NSMutableArray *dataProvider=[[NSMutableArray alloc]init];
		
		while (poitype!=nil) {
			
			POICategoryVO *poicategory=[[POICategoryVO alloc]init];
			poicategory.name= [[TBXML textForElement:[TBXML childElementNamed:@"name" parentElement:poitype]] stringByDecodingHTMLEntities];
			poicategory.key=[TBXML textForElement:[TBXML childElementNamed:@"key" parentElement:poitype]];
			poicategory.shortname=[TBXML textForElement:[TBXML childElementNamed:@"shortname" parentElement:poitype]];
			poicategory.total=[[TBXML textForElement:[TBXML childElementNamed:@"total" parentElement:poitype]] intValue];
			poicategory.icon=[StringUtilities imageFromString:[TBXML textForElement:[TBXML childElementNamed:@"icon" parentElement:poitype]]];
			
			[dataProvider addObject:poicategory];
			
			poitype=poitype->nextSibling;
			
		}
		
		_activeOperation.dataProvider=dataProvider;
		
		_activeOperation.validationStatus=ValidationPOIListingSuccess;
		
	}else{
		_activeOperation.validationStatus=ValidationPOIListingFailure;
	}
	
	
}



-(void)POICategoryXMLParser:(TBXML*)parser{
	
	BetterLog(@"");
	
	TBXMLElement *response = parser.rootXMLElement;
	
	[self validateXML:response];
	if(_activeOperation.operationState>NetResponseStateComplete){
		return;
	}
    
	TBXMLElement *pois=[TBXML childElementNamed:@"pois" parentElement:response];
	TBXMLElement *poi=[TBXML childElementNamed:@"poi" parentElement:pois];
	
	if(poi!=nil){
		
		NSMutableArray *dataProvider=[[NSMutableArray alloc]init];
		
		while (poi!=nil) {
			
			POILocationVO *poilocation=[[POILocationVO alloc]init];
			poilocation.name= [[TBXML textForElement:[TBXML childElementNamed:@"name" parentElement:poi]] stringByDecodingHTMLEntities];
			
			CLLocationCoordinate2D coords;
			coords.longitude=[[TBXML textForElement:[TBXML childElementNamed:@"longitude" parentElement:poi]] floatValue];
			coords.latitude=[[TBXML textForElement:[TBXML childElementNamed:@"latitude" parentElement:poi]] floatValue];
			CLLocation *location=[[CLLocation alloc]initWithLatitude:coords.latitude longitude:coords.longitude];
			poilocation.location=location;
			
			poilocation.website=[TBXML textForElement:[TBXML childElementNamed:@"website" parentElement:poi]];
			poilocation.notes=[TBXML textForElement:[TBXML childElementNamed:@"notes" parentElement:poi]];
						
			[dataProvider addObject:poilocation];
			
			poi=poi->nextSibling;
			
		}
		
		_activeOperation.dataProvider=dataProvider;
		
		_activeOperation.validationStatus=ValidationPOICategorySuccess;
		
	}else{
		_activeOperation.validationStatus=ValidationPOICategoryFailure;
	}
	
	
}


//
/***********************************************
 * @description			XML parser for Photo Wizard category selector
 ***********************************************/
//

-(void)PhotoCategoriesXMLParser:(TBXML*)parser{
	
	
	BetterLog(@"");
	
	TBXMLElement *response = parser.rootXMLElement;
	
	[self validateXML:response];
	if(_activeOperation.operationState>NetResponseStateComplete){
		return;
	}
    
	
	_activeOperation.validationStatus=ValidationCategoriesSuccess;
	
	NSMutableDictionary *dataProvider=[NSMutableDictionary dictionary];
	
	NSString *time=[TBXML textOfChild:@"validuntil" parentElement:response];
	[dataProvider setObject:time forKey:@"validUntilTimeStamp"];
	
	
	TBXMLElement *categoriesnode=[TBXML childElementNamed:@"categories" parentElement:response];
	TBXMLElement *categorynode=[TBXML childElementNamed:@"category" parentElement:categoriesnode];
	
	if(categorynode!=nil){
		
		NSMutableArray *carr=[NSMutableArray array];
		
		while (categorynode!=nil) {
			
			PhotoCategoryVO *category=[[PhotoCategoryVO alloc]init];
			category.categoryType=PhotoCategoryTypeFeature;
			category.name=[TBXML textOfChild:@"name" parentElement:categorynode];
			category.tag=[TBXML textOfChild:@"tag" parentElement:categorynode];
			
			[carr addObject:category];
			
			categorynode=categorynode->nextSibling;
			
		}
		
		[dataProvider setObject:carr forKey:@"feature"];
		
	}else {
		_activeOperation.validationStatus=ValidationCategoriesFailed;
	}
	
	TBXMLElement *metacategoriesnode=[TBXML childElementNamed:@"metacategories" parentElement:response];
	TBXMLElement *metacategorynode=[TBXML childElementNamed:@"metacategory" parentElement:metacategoriesnode];
	
	if(metacategorynode!=nil){
		
		NSMutableArray *mcarr=[NSMutableArray array];
		
		while (metacategorynode!=nil) {
			
			PhotoCategoryVO *category=[[PhotoCategoryVO alloc]init];
			category.categoryType=PhotoCategoryTypeCategory;
			category.name=[TBXML textOfChild:@"name" parentElement:metacategorynode];
			category.tag=[TBXML textOfChild:@"tag" parentElement:metacategorynode];
			
			[mcarr addObject:category];
			
			metacategorynode=metacategorynode->nextSibling;
			
		}
		
		[dataProvider setObject:mcarr forKey:@"category"];
		
	}else {
		_activeOperation.validationStatus=ValidationCategoriesFailed;
	}
	
	_activeOperation.dataProvider=dataProvider;
	
}


									
	
//
/***********************************************
 * @description			Class methods
 ***********************************************/
//


//
/***********************************************
 * @description			Utility
 ***********************************************/
//



@end
