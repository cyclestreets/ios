//
//  PureLayout+Additions.m
//
//  Created by Neil Edwards on 30/07/2015.
//

#import "PureLayout+Additions.h"

@implementation ALView (Additions)



- (NSLayoutConstraint *)autoAlignAxisToSuperviewAxis:(ALAxis)axis withOffset:(CGFloat)offset
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    ALView *superview = self.superview;
    NSAssert(superview, @"View's superview must not be nil.\nView: %@", self);
    return [self autoConstrainAttribute:(ALAttribute)axis toAttribute:(ALAttribute)axis ofView:superview withOffset:offset];
}



- (NSArray *)autoPinEdgesToSuperviewEdges
{
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObject:[self autoPinEdgeToSuperviewEdge:ALEdgeTop]];
    [constraints addObject:[self autoPinEdgeToSuperviewEdge:ALEdgeLeft]];
    [constraints addObject:[self autoPinEdgeToSuperviewEdge:ALEdgeBottom]];
    [constraints addObject:[self autoPinEdgeToSuperviewEdge:ALEdgeRight]];
    return constraints;
}


//- (NSLayoutConstraint *)autoConstrainAttribute:(ALAttribute)attribute toAttribute:(ALAttribute)toAttribute ofView:(ALView *)otherView withOffset:(CGFloat)offset
//{
//    NSAssert(otherView, @"View's superview must not be nil.\nView: %@", otherView);
//    return [self autoConstrainAttribute:attribute toAttribute:toAttribute ofView:otherView withOffset:offset];
//}

@end
