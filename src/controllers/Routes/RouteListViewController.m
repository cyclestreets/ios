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


@interface FavouriteMenuItem : UIMenuItem 
@property (nonatomic, strong) NSIndexPath* indexPath;
@end

@implementation FavouriteMenuItem
@synthesize indexPath;
@end


@interface RouteListViewController(Private) 

-(void)createRowHeightsArray;
-(void)createSectionHeadersArray;

- (NSIndexPath *)modelIndexPathforIndexPath:(NSIndexPath *)indexPath;

- (void)cellMenuPress:(UILongPressGestureRecognizer *)recognizer;
-(void)favouriteRouteMenuSelected:(UIMenuController*)menuController;

@end



@implementation RouteListViewController
@synthesize isSectioned;
@synthesize keys;
@synthesize dataProvider;
@synthesize tableDataProvider;
@synthesize rowHeightsArray;
@synthesize rowHeightDictionary;
@synthesize tableSectionArray;
@synthesize dataType;
@synthesize tableEditMode;
@synthesize selectedCellDictionary;
@synthesize selectedCount;
@synthesize deleteButton;
@synthesize tableView;
@synthesize toolView;
@synthesize tappedIndexPath;
@synthesize indexPathToDelete;



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
	
    self.dataProvider=[[SavedRoutesManager sharedInstance] dataProviderForType:dataType];
    
    if([dataProvider count]>0){
        
        if(isSectioned==YES){
            self.tableDataProvider=[GlobalUtilities newKeyedDictionaryFromArray:dataProvider usingKey:@"dateOnlyString" sortedBy:@"dateString"];
            self.keys=[GlobalUtilities newTableIndexArrayFromDictionary:tableDataProvider withSearch:NO ascending:NO];
			
			
        }
		
		[self createRowHeightsArray];
		
		if([keys count]>0 && isSectioned==YES)
			[self createSectionHeadersArray];
		
		[self.tableView reloadData];
		[self showViewOverlayForType:kViewOverlayTypeNoResults show:NO withMessage:nil];
        
    }else{
		if(isSectioned==YES){
			self.tableDataProvider=[NSMutableDictionary dictionary];
			self.keys=[NSMutableArray array];
		}
		
        [self showViewOverlayForType:kViewOverlayTypeNoResults show:YES withMessage:[NSString stringWithFormat:@"noresults_%@",dataType] withIcon:dataType];
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
	
	UIType=UITYPE_CONTROLUI;
	
    if([dataType isEqualToString:SAVEDROUTE_RECENTS]){
        isSectioned=YES;
    }
	
}


-(void)createPersistentUI{
	
	self.toolView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
	toolView.backgroundColor=[UIColor redColor];
	
}


-(void)viewWillAppear:(BOOL)animated{
	
	[self createNonPersistentUI];
	
	[super viewWillAppear:animated];
}

-(void)createNonPersistentUI{
	
	if(dataProvider==nil){
		[self refreshUIFromDataProvider];
	}
	
	[self deSelectRowForTableView:tableView];
}


//
/***********************************************
 * @description		TABLEVIEW DELEGATE METHODS
 ***********************************************/
//

#pragma mark UITableView delegate methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if(isSectioned==YES){
		return [keys count];
	}else {
		return 1;
	}

}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	if(isSectioned==YES){
		NSString *key=[keys objectAtIndex:section];
		NSMutableArray *sectionDataProvider=[tableDataProvider objectForKey:key];
		return [sectionDataProvider count];
	}else {
		return [dataProvider count];
	}

}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{  
	
	if (isSectioned==YES) {
		return [tableSectionArray objectAtIndex:section];
	}
	return nil;
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	if(isSectioned==NO){
		return 0.0f;
	}
	return 24.0f;
}


- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
    RouteCellView *cell = (RouteCellView *)[RouteCellView cellForTableView:table fromNib:[RouteCellView nib]];
	
	if(isSectioned==YES){
		
		if(keys.count==0)
			return cell;
	
		NSString *key=[keys objectAtIndex:[indexPath section]];
		NSMutableArray *sectionDataProvider=[tableDataProvider objectForKey:key];
		
		RouteVO *route=[sectionDataProvider objectAtIndex:[indexPath row]];
		cell.dataProvider=route;
		cell.isSelectedRoute=[[RouteManager sharedInstance] routeIsSelectedRoute:route];
			
		[cell populate];
		
		
	}else {
		
		RouteVO *route=[dataProvider objectAtIndex:[indexPath row]];
		
		cell.dataProvider=route;
		cell.isSelectedRoute=[[RouteManager sharedInstance] routeIsSelectedRoute:route];
		
		[cell populate];
	}
	
	if([dataType isEqualToString:SAVEDROUTE_RECENTS]){
		
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
	
	
	
	if(tableView.isEditing==NO){
	
		if (recognizer.state == UIGestureRecognizerStateBegan) {
			
			NSIndexPath *pressedIndexPath = [self.tableView indexPathForRowAtPoint:[recognizer locationInView:self.tableView]];
			
			
			if([dataType isEqualToString:SAVEDROUTE_RECENTS]){
				
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
				
				[tableView setEditing:YES animated:YES];
				
			}
			
			
		}
	}else{
		BetterLog(@"");
	}
	
}




-(void)favouriteRouteMenuSelected:(UIMenuController*)menuController {
	
	
	FavouriteMenuItem *menuItem = [[[UIMenuController sharedMenuController] menuItems] objectAtIndex:0];
	
    if (menuItem.indexPath) {
		
        [self resignFirstResponder];
		
		NSString *key=[keys objectAtIndex:[menuItem.indexPath section]];
		NSMutableArray *sectionDataProvider=[tableDataProvider objectForKey:key];
		RouteVO *route=[sectionDataProvider objectAtIndex:[menuItem.indexPath row]];
		
		[[SavedRoutesManager sharedInstance] moveRoute:route toDataProvider:SAVEDROUTE_FAVS];
		
    }
	
	
}



- (void)tableView:(UITableView *)tbv didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

	
	if([delegate respondsToSelector:@selector(doNavigationPush: withDataProvider: andIndex:)]){
		
		RouteVO *route=nil;
		
		if(isSectioned==YES){
			NSString *key=[keys objectAtIndex:[indexPath section]];
			NSMutableArray *sectionDataProvider=[tableDataProvider objectForKey:key];
			route=[sectionDataProvider objectAtIndex:[indexPath row]];
			
			[delegate doNavigationPush:@"RouteSummary" withDataProvider:route andIndex:SavedRoutesDataTypeRecent];
			
		}else{
			route=[dataProvider objectAtIndex:[indexPath row]];
			
			[delegate doNavigationPush:@"RouteSummary" withDataProvider:route andIndex:SavedRoutesDataTypeFavourite];
		}
		
		
	}
	
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	if(isSectioned==NO){
		return [[rowHeightsArray objectAtIndex:[indexPath row]] floatValue];
	}else{
		NSString *key=[keys objectAtIndex:[indexPath section]];
		NSMutableArray *arr=[rowHeightDictionary objectForKey:key];
		
		int rowIndex=[indexPath row];
		if(rowIndex<[arr count]){
			CGFloat cellheight=[[arr objectAtIndex:rowIndex] floatValue];
			return cellheight;
		}else{
			return 0;
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
	
	if([dataType isEqualToString:SAVEDROUTE_FAVS]){
		return YES;
	}
	
	return NO;
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
	
	
}


//
/***********************************************
 * @description			Table view utitlity
 ***********************************************/
//

       
-(void)createRowHeightsArray{
    
    if(isSectioned==NO){
   
       if(rowHeightsArray==nil){
           self.rowHeightsArray=[[NSMutableArray alloc]init];
       }else{
           [rowHeightsArray	removeAllObjects];
       }
       
       for (int i=0; i<[dataProvider count]; i++) {
           
           RouteVO *route = [dataProvider objectAtIndex:i];
           [rowHeightsArray addObject:[RouteCellView heightForCellWithDataProvider:route]];
           
       }
        
    }else{
        
        if(rowHeightDictionary==nil){
            self.rowHeightDictionary=[[NSMutableDictionary alloc]init];
        }else{
            [rowHeightDictionary removeAllObjects];
        }
        
        for( NSString *key in keys){
            
            NSMutableArray *sectionDataProvider=[tableDataProvider objectForKey:key];
			NSMutableArray *sectionrowheightarray=[[NSMutableArray alloc]init];
        
            for (int i=0; i<[sectionDataProvider count]; i++) {
                
                RouteVO *route = [sectionDataProvider objectAtIndex:i];
                [sectionrowheightarray addObject:[RouteCellView heightForCellWithDataProvider:route]];
                
            }
			[rowHeightDictionary setObject:sectionrowheightarray forKey:key];
            
        }
        
    }
   
   
}

-(void)createSectionHeadersArray{
	
	if(isSectioned==YES){
		
		if(tableSectionArray==nil){
            self.tableSectionArray=[[NSMutableArray alloc]init];
        }else{
            [tableSectionArray removeAllObjects];
        }
		
		for (int i=0;i<[keys count];i++){
			
			UIView *headerView=[[UIView	alloc]initWithFrame:CGRectMake(0, 0, 320, 24)];
			headerView.backgroundColor=[[StyleManager sharedInstance] colorForType:@"darkgreen"];
			
			UILabel *sectionLabel=[[UILabel alloc]initWithFrame:CGRectMake(10.0, 0, 280, 24)];
			sectionLabel.backgroundColor=[UIColor clearColor];
			sectionLabel.textColor=UIColorFromRGB(0xFFFFFF);
			sectionLabel.font=[UIFont boldSystemFontOfSize:11.5];
			
			// create ui string
			NSString *key=[keys objectAtIndex:i];
			NSDate *sectionDate=[NSDate dateFromString:key];
			NSDateFormatter *displayFormatter = [[NSDateFormatter alloc] init];
			[displayFormatter setDateFormat:@"EEEE d MMM YYYY"];
			NSString *timeString = [displayFormatter stringFromDate:sectionDate];
			sectionLabel.text=timeString;
			
			
			[headerView addSubview:sectionLabel];
			
			[tableSectionArray addObject:headerView];
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
	
	BOOL newstate = !tableEditMode;
	[self setTableEditingState:newstate];
}


-(void)setTableEditingState:(BOOL)state{
	
	tableEditMode=state;
	
	[tableView reloadData];
	
}




- (void)deleteRow:(NSIndexPath*)indexPath{
    
    RouteVO *route=nil;
    
    if(isSectioned==YES){
        NSString *key=[keys objectAtIndex:[indexPath section]];
        NSMutableArray *sectionDataProvider=[tableDataProvider objectForKey:key];
        route=[sectionDataProvider objectAtIndex:[indexPath row]];
    }else{
        route=[dataProvider objectAtIndex:[indexPath row]];
    }
	
	[[SavedRoutesManager sharedInstance] removeRoute:route fromDataProvider:dataType];
	
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	[self deleteRow:indexPath];
	[self refreshUIFromDataProvider];
    
}


- (void)updateDeleteButtonState{
	deleteButton.enabled=selectedCount>0;
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
