//
//  User.m
//  Cycle Atlanta
//
//  Created by Guo Anhong on 13-2-26.
//
//

#import "User.h"
#import "Note.h"
#import "Trip.h"


@implementation User

@dynamic age;
@dynamic cyclingFreq;
@dynamic rider_history;
@dynamic rider_type;
@dynamic income;
@dynamic ethnicity;
@dynamic homeZIP;
@dynamic schoolZIP;
@dynamic workZIP;
@dynamic gender;
@dynamic email;
@dynamic notes;
@dynamic trips;



-(BOOL)userInfoSaved{
	
	if(self.age		!= nil ||
		 self.gender	!= nil ||
		 self.email		!= nil ||
		 self.homeZIP	!= nil ||
		 self.workZIP	!= nil ||
		 self.schoolZIP	!= nil ||
	   ([self.cyclingFreq intValue] < 4 )){
		return NO;
	}
	
	return YES;

	
}

@end
