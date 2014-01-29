/*
 
 Copyright (C) 2010  CycleStreets Ltd
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 
 */

//
//  main.m
//  CycleStreets
//
//

#import <UIKit/UIKit.h>
#import <Pixate/Pixate.h>

#import "AppDelegate.h"


int main(int argc, char *argv[])
{
    @autoreleasepool {
        
        [Pixate licenseKey:@"3S66R-9MDKI-RUKOO-IKNQF-9FGEM-G8PH2-EGSEI-F0Q6P-OTAF0-U9ENU-GRNUU-U28DT-GHTRL-JKE2M-F90U6-04" forUser:@"neil.edwards@buffer.uk.com"];
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
