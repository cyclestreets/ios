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


@interface RouteListViewController(Private) 

-(void)createRowHeightsArray;

@end



@implementation RouteListViewController
@synthesize isSectioned;
@synthesize keys;
@synthesize dataProvider;
@synthesize tableDataProvider;
@synthesize rowHeightsArray;
@synthesize rowHeightDictionary;
@synthesize dataType;
@synthesize tableEditMode;
@synthesize selectedCellDictionary;
@synthesize selectedCount;
@synthesize deleteButton;
@synthesize tableView;

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [keys release], keys = nil;
    [dataProvider release], dataProvider = nil;
    [tableDataProvider release], tableDataProvider = nil;
    [rowHeightsArray release], rowHeightsArray = nil;
    [rowHeightDictionary release], rowHeightDictionary = nil;
    [dataType release], dataType = nil;
    [selectedCellDictionary release], selectedCellDictionary = nil;
    [deleteButton release], deleteButton = nil;
    [tableView release], tableView = nil;
    
    [super dealloc];
}



//
/***********************************************
 * @description		NOTIFICATIONS
 ***********************************************/
//

-(void)listNotificationInterests{
	
	[self initialise];
    
    [notifications addObject:NEWROUTEBYIDRESPONSE]; // user initiated route by id response
    [notifications addObject:SAVEDROUTEUPDATE]; // new route search, recent>fav move etc
	
	[super listNotificationInterests];
	
}

-(void)didReceiveNotification:(NSNotification*)notification{
	
	[super didReceiveNotification:notification];
    
	if([notification.name isEqualToString:NEWROUTEBYIDRESPONSE]){
		[self refreshUIFromDataProvider];
	}
    
    if([notification.name isEqualToString:SAVEDROUTEUPDATE]){
		[self refreshUIFromDataProvider];
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
            self.tableDataProvider=[GlobalUtilities newKeyedDictionaryFromArray:dataProvider usingKey:@"date"];
            self.keys=[GlobalUtilities newTableViewIndexFromArray:dataProvider usingKey:@"date"];
        }
        [self createRowHeightsArray];
        [self.tableView reloadData];
        
    }else{
        // show no data overlay
    }
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
	
}


//
/***********************************************
 * @description			UI CREATION
 ***********************************************/
//

- (void)viewDidLoad {
	
    if([dataType isEqualToString:@"Recent"]{
        isSectioned=YES;
    }
	
}


-(void)createPersistentUI{
	
	
}


-(void)viewWillAppear:(BOOL)animated{
	
	[super viewWillAppear:animated];
	
	[self createNonPersistentUI];
	
}

-(void)createNonPersistentUI{
	
	
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


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	if(isSectioned==YES){
		NSString *key=[keys objectAtIndex:section];
		NSMutableArray *sectionDataProvider=[tableDataProvider objectForKey:key];
		return [sectionDataProvider count];
	}else {
		return [dataProvider count];
	}

}



- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
    RouteCellView *cell = (RouteCellView *)[RouteCellView cellForTableView:table fromNib:[RouteCellView nib]];
	
	if(isSectioned==YES){
	
		NSString *key=[keys objectAtIndex:[indexPath section]];
		NSMutableArray *sectionDataProvider=[tableDataProvider objectForKey:key];
	
		cell.dataProvider=[sectionDataProvider objectAtIndex:[indexPath row]];
		
	}else {
		cell.dataProvider=[dataProvider objectAtIndex:[indexPath row]];
	}

	[cell populate];
	
    return cell;
}



- (void)tableView:(UITableView *)tbv didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	if (tableEditMode==YES){
		return;
	}else {
        
        if([delegate respondsToSelector:@selector(doNavigationPush: withDataProvider: andIndex:)]){
            
            RouteVO *route;
            
            if(isSectioned==YES){
                NSString *key=[keys objectAtIndex:[indexPath section]];
                NSMutableArray *sectionDataProvider=[tableDataProvider objectForKey:key];
                route=[sectionDataProvider objectAtIndex:[indexPath row]];
            }else{
                route=[dataProvider objectAtIndex:[indexPath row]];
            }
			
			[delegate doNavigationPush:@"RouteSummary" withDataProvider:route andIndex:-1];
		}
		
	}

}

       
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
        
        for( NSString *key in tableDataProvider){
            
            NSMutableArray *sectionDataProvider=[tableDataProvider objectForKey:key];
        
            for (int i=0; i<[sectionDataProvider count]; i++) {
                
                RouteVO *route = [sectionDataProvider objectAtIndex:i];
                [rowHeightsArray addObject:[RouteCellView heightForCellWithDataProvider:route]];
                
            }
            
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


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
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
	[tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    [self refreshUIFromDataProvider];
}

/* this needs further work
-(void)tableView:(UITableView*)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender{
   
   BetterLog(@"");
   
}
-(BOOL)tableView:(UITableView*)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender{
   return YES;
   
}
-(BOOL)tableView:(UITableView*)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath*)indexPath{
   
   UIMenuItem* miCustom1 = [[[UIMenuItem alloc] initWithTitle: @"Custom 1" action:@selector( onCustom1: )] autorelease];
   UIMenuItem* miCustom2 = [[[UIMenuItem alloc] initWithTitle: @"Custom 2" action:@selector( onCustom2: )] autorelease];
   UIMenuController* mc = [UIMenuController sharedMenuController];
   mc.menuItems = [NSArray arrayWithObjects: miCustom1, miCustom2, nil];
   
   return YES;
}
 */


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
