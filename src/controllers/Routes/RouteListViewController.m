    //
//  RouteListViewController.m
//  CycleStreets
//
//  Created by neil on 12/03/2011.
//  Copyright 2011 CycleStreets Ltd. All rights reserved.
//

#import "RouteListViewController.h"
#import "RouteCellView.h"
#import "SavedRoutesManager.h"
#import "StyleManager.h"
#import "NSDate+Helper.h"
#import "RouteManager.h"
#import "UIView+Additions.h"
#import "GenericConstants.h"
#import "GlobalUtilities.h"

@interface FavouriteMenuItem : UIMenuItem 
@property (nonatomic, strong) NSIndexPath* indexPath;
@end

@implementation FavouriteMenuItem
@synthesize indexPath;
@end


@interface RouteListViewController()

// ib
@property (nonatomic, strong) IBOutlet UITableView						* tableView;

@property (nonatomic, assign) BOOL								isSectioned;
@property (nonatomic, strong) NSMutableArray					* keys;
@property (nonatomic, strong) NSMutableDictionary				* tableDataProvider;
@property (nonatomic, strong) NSMutableArray					* rowHeightsArray;
@property (nonatomic, strong) NSMutableDictionary				* rowHeightDictionary;
@property (nonatomic, strong) NSMutableArray					* tableSectionArray;

@property (nonatomic, assign) BOOL								tableEditMode;
@property (nonatomic, strong) NSMutableDictionary				* selectedCellDictionary;
@property (nonatomic, assign) int								selectedCount;
@property (nonatomic, strong) UIButton							* deleteButton;

@property (nonatomic, strong) NSIndexPath						* tappedIndexPath;
@property (nonatomic, strong) NSIndexPath						* indexPathToDelete;

-(void)setTableEditingState:(BOOL)state;

-(void)createRowHeightsArray;
-(void)createSectionHeadersArray;

- (void)cellMenuPress:(UILongPressGestureRecognizer *)recognizer;
-(void)favouriteRouteMenuSelected:(UIMenuController*)menuController;

@end



@implementation RouteListViewController



//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	BetterLog(@"");
	
	[self initialise];
	
	displaysConnectionErrors=NO;
    
    [notifications addObject:NEWROUTEBYIDRESPONSE]; // user initiated route by id response
    [notifications addObject:SAVEDROUTEUPDATE]; // new route search, recent>fav move etc
	[notifications addObject:CALCULATEROUTERESPONSE];
	[notifications addObject:CSROUTESELECTED];
	
	[notifications addObject:UIMenuControllerDidShowMenuNotification];
	[notifications addObject:UIMenuControllerWillShowMenuNotification];
	[notifications addObject:UIMenuControllerMenuFrameDidChangeNotification];
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	BetterLog(@"notification.name=%@",notification.name);
	
	[super didReceiveNotification:notification];
    
	if([notification.name isEqualToString:NEWROUTEBYIDRESPONSE]){
		[self refreshUIFromDataProvider];
	}
    
    if([notification.name isEqualToString:SAVEDROUTEUPDATE]){
		[self refreshUIFromDataProvider];
	}
	
	if([notification.name isEqualToString:CALCULATEROUTERESPONSE]){
		[self refreshUIFromDataProvider];
	}
	
	if([notification.name isEqualToString:CSROUTESELECTED]){
		[self.tableView reloadData];
	}
	
}


//
/***********************************************
 * @description			DATA UPDATING
 ***********************************************/
//

-(void)refreshUIFromDataProvider{
	
	if(_configDict==nil)
		return;
	
	_isSectioned=[_configDict[@"isSectioned"] boolValue];
	
    self.dataProvider=[[SavedRoutesManager sharedInstance] dataProviderForType:_configDict[ID]];
    
    if([_dataProvider count]>0){
        
        if(_isSectioned==YES){
            self.tableDataProvider=[GlobalUtilities newKeyedDictionaryFromArray:_dataProvider usingKey:@"dateOnlyString" sortedBy:@"dateString"];
            self.keys=[GlobalUtilities newTableIndexArrayFromDictionary:_tableDataProvider withSearch:NO ascending:NO];
        }
		
		//[self createRowHeightsArray];
		
		if([_keys count]>0 && _isSectioned==YES){
			[self createSectionHeadersArray];
		}
		
		[self.tableView reloadData];
		
        [self showViewOverlayForType:kViewOverlayTypeNoResults show:NO withMessage:nil];
    }else{
		if(_isSectioned==YES){
			self.tableDataProvider=[NSMutableDictionary dictionary];
			self.keys=[NSMutableArray array];
		}
		
        [self showViewOverlayForType:kViewOverlayTypeNoResults show:YES withMessage:[NSString stringWithFormat:@"noresults_%@",_configDict[ID]] withIcon:_configDict[ID]];
    }
    
	/*
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
	*/
}


//
/***********************************************
 * @description			UI CREATION
 ***********************************************/
//

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	[_tableView registerNib:[RouteCellView nib] forCellReuseIdentifier:[RouteCellView cellIdentifier]];
	_tableView.rowHeight=UITableViewAutomaticDimension;
	_tableView.estimatedRowHeight=44;
	
	UIType=UITYPE_CONTROLUI;
	
}


-(void)createPersistentUI{
	
	
}


-(void)viewWillAppear:(BOOL)animated{
	
	[self createNonPersistentUI];
	
	[super viewWillAppear:animated];
}

-(void)createNonPersistentUI{
	
	
	[self deSelectRowForTableView:_tableView];
}


//
/***********************************************
 * @description		TABLEVIEW DELEGATE METHODS
 ***********************************************/
//

#pragma mark UITableView delegate methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if(_isSectioned==YES){
		return [_keys count];
	}else {
		return 1;
	}

}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	if(_isSectioned==YES){
		NSString *key=[_keys objectAtIndex:section];
		NSMutableArray *sectionDataProvider=[_tableDataProvider objectForKey:key];
		return [sectionDataProvider count];
	}else {
		return [_dataProvider count];
	}

}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{  
	
	if (_isSectioned==YES) {
		return [_tableSectionArray objectAtIndex:section];
	}
	return nil;
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	if(_isSectioned==NO){
		return 0.0f;
	}
	return 24.0f;
}


- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	RouteCellView *cell = [table dequeueReusableCellWithIdentifier:[RouteCellView cellIdentifier]];
	
	if(_isSectioned==YES){
		
		if(_keys.count==0 || _keys==nil)
			return cell;
	
		NSString *key=[_keys objectAtIndex:[indexPath section]];
		NSMutableArray *sectionDataProvider=[_tableDataProvider objectForKey:key];
		
		RouteVO *route=[sectionDataProvider objectAtIndex:[indexPath row]];
		cell.dataProvider=route;
		cell.isSelectedRoute=[[RouteManager sharedInstance] routeIsSelectedRoute:route];
			
		[cell populate];
		
		
	}else {
		
		RouteVO *route=[_dataProvider objectAtIndex:[indexPath row]];
		
		cell.dataProvider=route;
		cell.isSelectedRoute=[[RouteManager sharedInstance] routeIsSelectedRoute:route];
		
		[cell populate];
	}
	
	if([_configDict[ID] isEqualToString:SAVEDROUTE_RECENTS]){
		
		UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellMenuPress:)];
		[cell addGestureRecognizer:recognizer];
	}
	
    return cell;
}



//
/***********************************************
 * @description			Cell Press menu support
 ***********************************************/
//

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (void)cellMenuPress:(UILongPressGestureRecognizer *)recognizer {
	
	
	
	if(_tableView.isEditing==NO){
	
		if (recognizer.state == UIGestureRecognizerStateBegan) {
			
			NSIndexPath *pressedIndexPath = [self.tableView indexPathForRowAtPoint:[recognizer locationInView:self.tableView]];
			
			
			if([_configDict[ID] isEqualToString:SAVEDROUTE_RECENTS]){
				
				// sue index path to get dp fav state
				// if no fav, if yes do not show menu
				
				if (pressedIndexPath && (pressedIndexPath.row != NSNotFound) && (pressedIndexPath.section != NSNotFound)) {
					
					[self becomeFirstResponder];
					
					UIMenuController *menuController = [UIMenuController sharedMenuController];
					FavouriteMenuItem *menuItem = [[FavouriteMenuItem alloc] initWithTitle:@"Favourite" action:@selector(favouriteRouteMenuSelected:)];
					menuItem.indexPath = pressedIndexPath;
					menuController.menuItems = [NSArray arrayWithObject:menuItem];
					
					[menuController setTargetRect:[self.tableView rectForRowAtIndexPath:pressedIndexPath] inView:self.tableView];
					[menuController setMenuVisible:YES animated:NO];
					
				}
				
				
			}else{
				
				[_tableView setEditing:YES animated:YES];
				
			}
			
			
		}
	}else{
		BetterLog(@"");
	}
	
}




-(void)favouriteRouteMenuSelected:(UIMenuController*)menuController {
	
	
	FavouriteMenuItem *menuItem = (FavouriteMenuItem*)[[[UIMenuController sharedMenuController] menuItems] objectAtIndex:0];
	
    if (menuItem.indexPath) {
		
        [self resignFirstResponder];
		
		NSString *key=[_keys objectAtIndex:[menuItem.indexPath section]];
		NSMutableArray *sectionDataProvider=[_tableDataProvider objectForKey:key];
		RouteVO *route=[sectionDataProvider objectAtIndex:[menuItem.indexPath row]];
		
		[[SavedRoutesManager sharedInstance] moveRoute:route toDataProvider:SAVEDROUTE_FAVS];
		
    }
	
	
}



- (void)tableView:(UITableView *)tbv didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

	
	if([delegate respondsToSelector:@selector(doNavigationPush: withDataProvider: andIndex:)]){
		
		RouteVO *route=nil;
		
		if(_isSectioned==YES){
			NSString *key=[_keys objectAtIndex:[indexPath section]];
			NSMutableArray *sectionDataProvider=[_tableDataProvider objectForKey:key];
			route=[sectionDataProvider objectAtIndex:[indexPath row]];
			
			[delegate doNavigationPush:@"RouteSummary" withDataProvider:route andIndex:SavedRoutesDataTypeRecent];
			
		}else{
			route=[_dataProvider objectAtIndex:[indexPath row]];
			
			[delegate doNavigationPush:@"RouteSummary" withDataProvider:route andIndex:SavedRoutesDataTypeFavourite];
		}
		
		
	}
	
}





//
/***********************************************
 * @description			TableView move support
 ***********************************************/
//
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	return UITableViewCellEditingStyleDelete;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
	
	if([_configDict[ID] isEqualToString:SAVEDROUTE_FAVS]){
		return YES;
	}
	
	return NO;
}





//
/***********************************************
 * @description			Table view utitlity
 ***********************************************/
//

       
-(void)createRowHeightsArray{
    
    if(_isSectioned==NO){
   
       if(_rowHeightsArray==nil){
           self.rowHeightsArray=[[NSMutableArray alloc]init];
       }else{
           [_rowHeightsArray	removeAllObjects];
       }
       
       for (int i=0; i<[_dataProvider count]; i++) {
           
           RouteVO *route = [_dataProvider objectAtIndex:i];
           [_rowHeightsArray addObject:[RouteCellView heightForCellWithDataProvider:route]];
           
       }
        
    }else{
        
        if(_rowHeightDictionary==nil){
            self.rowHeightDictionary=[[NSMutableDictionary alloc]init];
        }else{
            [_rowHeightDictionary removeAllObjects];
        }
        
        for( NSString *key in _keys){
            
            NSMutableArray *sectionDataProvider=[_tableDataProvider objectForKey:key];
			NSMutableArray *sectionrowheightarray=[[NSMutableArray alloc]init];
        
            for (int i=0; i<[sectionDataProvider count]; i++) {
                
                RouteVO *route = [sectionDataProvider objectAtIndex:i];
                [sectionrowheightarray addObject:[RouteCellView heightForCellWithDataProvider:route]];
                
            }
			[_rowHeightDictionary setObject:sectionrowheightarray forKey:key];
            
        }
        
    }
   
   
}

-(void)createSectionHeadersArray{
	
	if(_isSectioned==YES){
		
		if(_tableSectionArray==nil){
            self.tableSectionArray=[[NSMutableArray alloc]init];
        }else{
            [_tableSectionArray removeAllObjects];
        }
		
		for (int i=0;i<[_keys count];i++){
			
			UIView *headerView=[[UIView	alloc]initWithFrame:CGRectMake(0, 0, 320, 24)];
			headerView.backgroundColor=UIColorFromRGB(0x509720);
			
			UILabel *sectionLabel=[[UILabel alloc]initWithFrame:CGRectMake(10.0, 0, 280, 24)];
			sectionLabel.backgroundColor=[UIColor clearColor];
			sectionLabel.textColor=UIColorFromRGB(0xFFFFFF);
			sectionLabel.font=[UIFont boldSystemFontOfSize:11.5];
			
			// create ui string
			NSString *key=[_keys objectAtIndex:i];
			NSDate *sectionDate=[NSDate dateFromString:key];
			NSDateFormatter *displayFormatter = [[NSDateFormatter alloc] init];
			[displayFormatter setDateFormat:@"EEEE d MMM YYYY"];
			NSString *timeString = [displayFormatter stringFromDate:sectionDate];
			sectionLabel.text=timeString;
			
			
			[headerView addSubview:sectionLabel];
			
			[_tableSectionArray addObject:headerView];
		}
		
	}
	
	
}


//
/***********************************************
 * @description		UI EVENTS
 ***********************************************/
//
//
/***********************************************
 * @description			Multi edit Cell support
 ***********************************************/
//


-(void)toggleTableEditing{
	
	BOOL newstate = !_tableEditMode;
	[self setTableEditingState:newstate];
}


-(void)setTableEditingState:(BOOL)state{
	
	_tableEditMode=state;
	
	[_tableView reloadData];
	
}




- (void)deleteRow:(NSIndexPath*)indexPath{
    
    RouteVO *route=nil;
    
    if(_isSectioned==YES){
        NSString *key=[_keys objectAtIndex:[indexPath section]];
        NSMutableArray *sectionDataProvider=[_tableDataProvider objectForKey:key];
        route=[sectionDataProvider objectAtIndex:[indexPath row]];
    }else{
        route=[_dataProvider objectAtIndex:[indexPath row]];
    }
	
	[[SavedRoutesManager sharedInstance] removeRoute:route fromDataProvider:_configDict[ID]];
	
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	[self deleteRow:indexPath];
	[self refreshUIFromDataProvider];
    
}


- (void)updateDeleteButtonState{
	_deleteButton.enabled=_selectedCount>0;
}


//
/***********************************************
 * @description			GENERIC METHODS
 ***********************************************/
//

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


@end
