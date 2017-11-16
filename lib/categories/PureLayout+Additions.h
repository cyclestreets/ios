//
//  PureLayout+Additions.h
//
//  Created by Neil Edwards on 30/07/2015.
//

// Adds some missing PureLayout helper methods

@import PureLayout;

@interface ALView (Additions)


- (NSLayoutConstraint *)autoAlignAxisToSuperviewAxis:(ALAxis)axis withOffset:(CGFloat)offset;

- (NSArray *)autoPinEdgesToSuperviewEdges;


@end
