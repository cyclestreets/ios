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

@interface TripDetailViewController ()

@end

@implementation TripDetailViewController
@synthesize delegate;
@synthesize detailTextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [self.detailTextView becomeFirstResponder];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    detailTextView.layer.borderWidth = 1.0;
    detailTextView.layer.borderColor = [[UIColor blackColor] CGColor];
}

-(IBAction)skip:(id)sender{
    NSLog(@"Skip");
    [delegate didCancelNote];
    
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    details = @"";
    
    [delegate didEnterTripDetails:details];
    [delegate saveTrip];
}

-(IBAction)saveDetail:(id)sender{
    NSLog(@"Save Detail");
    [detailTextView resignFirstResponder];
    [delegate didCancelNote];
    
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    details = detailTextView.text;
    
    [delegate didEnterTripDetails:details];
    [delegate saveTrip];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.delegate = nil;
    self.detailTextView = nil;
    
}

@end
