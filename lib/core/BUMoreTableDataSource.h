//
//  MoreTableDataSource.h
//
//
//  Created by Neil Edwards on 23/03/2010.
//  Copyright 2010 Chroma. All rights reserved.
//  Enables us to customise the more controller table cells

#import <Foundation/Foundation.h>

@interface BUMoreTableDataSource : NSObject <UITableViewDataSource>
{
    id<UITableViewDataSource> originalDataSource;
}

@property (retain) id<UITableViewDataSource> originalDataSource;

-(BUMoreTableDataSource *) initWithDataSource:(id<UITableViewDataSource>) dataSource;


@end
