/** Cycle Atlanta, Copyright 2012, 2013 Georgia Institute of Technology
 *                                    Atlanta, GA. USA
 *
 *   @author Christopher Le Dantec <ledantec@gatech.edu>
 *   @author Anhong Guo <guoanhong@gatech.edu>
 *
 *   Cycle Atlanta is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   Cycle Atlanta is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with Cycle Atlanta.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "TripDetailViewController.h"
#import "GlobalUtilities.h"
#import "TripManager.h"
#import "HCSMapViewController.h"

@interface TripDetailViewController ()


@property (nonatomic, strong) IBOutlet UITextView *detailTextView;



@end

@implementation TripDetailViewController
@synthesize delegate;
@synthesize detailTextView;



- (void)viewDidLoad
{
    [self.detailTextView becomeFirstResponder];
    [super viewDidLoad];
	
	
}

-(IBAction)didSelectCancel:(id)sender{
   
	BetterLog(@"");
	
    [delegate didCancelSaveJourneyController];
    
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(IBAction)saveDetail:(id)sender{
    
	BetterLog(@"");
	
    [detailTextView resignFirstResponder];
    
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[TripManager sharedInstance] saveNotes:detailTextView.text];
    [[TripManager sharedInstance] saveTrip];
	
	HCSMapViewController *controller = [[HCSMapViewController alloc] initWithNibName:[HCSMapViewController nibName] bundle:nil];
	controller.trip=[TripManager sharedInstance].currentRecordingTrip;
	controller.tripDelegate=delegate;
	controller.viewMode=HCSMapViewModeSave;
    [self.navigationController pushViewController:controller animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end
