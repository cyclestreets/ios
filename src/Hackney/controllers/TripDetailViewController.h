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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TripPurposeDelegate.h"

@interface TripDetailViewController : UIViewController<UINavigationControllerDelegate, UITextViewDelegate>
{
    id <TripPurposeDelegate> delegate;
    UITextView *detailTextView;
    NSInteger pickerCategory;
    NSString *details;
}

@property (nonatomic, retain) id <TripPurposeDelegate> delegate;

@property (nonatomic, retain) IBOutlet UITextView *detailTextView;


-(IBAction)skip:(id)sender;
-(IBAction)saveDetail:(id)sender;

@end
