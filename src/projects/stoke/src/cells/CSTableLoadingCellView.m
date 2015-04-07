//
//  CSTableLoadingCellView.m
//  CycleStreets
//
//  Created by Neil Edwards on 07/04/2015.
//  Copyright (c) 2015 CycleStreets Ltd. All rights reserved.
//

#import "CSTableLoadingCellView.h"

@interface CSTableLoadingCellView()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView		*activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel						*indicatorLabel;


@end

@implementation CSTableLoadingCellView


-(void)populate{}


-(void)updateLoadingText:(NSString*)str{
	
	_indicatorLabel.text=str;
	
}

-(void)updateLoading:(BOOL)loading{
	
	loading==YES ? [_activityIndicator startAnimating] : [_activityIndicator stopAnimating];
	
}


@end
