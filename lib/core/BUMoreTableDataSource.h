//
//  MoreTableDataSource.h
//
//
//  Created by Neil Edwards on 23/03/2010.
//  Copyright 2010 Buffer. All rights reserved.
//  Enables us to customise the more controller table cells

#import <Foundation/Foundation.h>

@interface BUMoreTableDataSource : NSObject <UITableViewDataSource>
{
    id<UITableViewDataSource> originalDataSource;
}

@property (strong) id<UITableViewDataSource> originalDataSource;

-(BUMoreTableDataSource *) initWithDataSource:(id<UITableViewDataSource>) dataSource;


@end
