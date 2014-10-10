//
//  BUTouchView
//
//  Created by Neil Edwards on 19/02/2013.
//
//

#import <UIKit/UIKit.h>

typedef void (^BUTouchedOutsideBlock)();
typedef void (^BUTouchedInsideBlock)();

@interface BUTouchView : UIControl

@property (nonatomic,assign) BOOL          exclusiveTouch;


@property (nonatomic,copy) BUTouchedOutsideBlock           outSideBlock;
@property (nonatomic,copy) BUTouchedInsideBlock           inSideBlock;


-(void)setTouchedOutsideBlock:(BUTouchedOutsideBlock)outsideBlock;

-(void)setTouchedInsideBlock:(BUTouchedInsideBlock)insideBlock;

-(void)executeOutsideBlock;
-(void)executeInsideBlock;

@end
