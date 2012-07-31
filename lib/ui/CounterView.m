#import "CounterView.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat kDigitWidth		= 25.0f; // real width is 32.f;
static const CGFloat kDigitHeight		= 30.0f;
static const unichar kCharacterOffset	= 48;

@implementation CounterView
@synthesize numberString_;
@synthesize number_;
@synthesize digitLayers_;
@synthesize usesPadding;

/***********************************************************/
// dealloc
/***********************************************************/


- (CounterView *)initWithDefault{
	if (self = [super initWithFrame:CGRectMake(0.f, 0.f, kDigitWidth, kDigitHeight)]) {
		digitLayers_ = [[NSMutableArray alloc] init];
		usesPadding=NO;
		[self setDefaultItem];
	}
	return self;
}


- (CounterView *)initWithNumber:(double)num {
  if (self = [super initWithFrame:CGRectMake(0.f, 0.f, kDigitWidth, kDigitHeight)]) {
    digitLayers_ = [[NSMutableArray alloc] init];
	usesPadding=YES;
    [self setNumber:num];
  }
  return self;
}


- (CounterView *)initWithNumber:(double)num usePadding:(BOOL)pad{
	if (self = [super initWithFrame:CGRectMake(0.f, 0.f, kDigitWidth, kDigitHeight)]) {
		usesPadding=pad;
		digitLayers_ = [[NSMutableArray alloc] init];
		[self setNumber:num];
	}
	return self;
}


- (double)number {
    return number_;
}

- (void)setNumber:(double)num {
  if (num <0) {
	  num = (num * -1);
  }
  number_ = num;
  [digitLayers_ makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
  numberString_ = nil;
	
	if(usesPadding==YES){
		numberString_ = [NSString stringWithFormat:@"%02.0F", num];
	}else {
		numberString_=[NSString stringWithFormat:@"%01.0f", num];
	}

	
  //NSLog(@"num = %f   number_ = %f  numberString = %@",num,number_,numberString_);
  
  NSUInteger count = [numberString_ length];
  [self setBounds:CGRectMake(0.f, 0.f, (CGFloat)count * kDigitWidth, kDigitHeight)];
  
  for(NSUInteger i = 0; i < count; i++) {
    CALayer *theLayer = [self layerForDigitAtIndex:i];
    int theNumber = (int)([numberString_ characterAtIndex:i] - kCharacterOffset);
    if(theNumber < 0) {
      theNumber = 10;
    }
	CGFloat height = 1.f/11.f;
	//    CGFloat width = kDigitWidth / 20.f;
    CGFloat width = 1.f;
    CGRect contentsRect = CGRectMake(0.f, (theNumber) * height, width, height);
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    theLayer.frame = CGRectMake(kDigitWidth * i, 0.f, kDigitWidth, kDigitHeight);
    [CATransaction begin];
    [CATransaction setDisableActions:(theNumber == 10)];
    theLayer.contentsRect = contentsRect;
    [CATransaction commit];
    [CATransaction commit];
    
    [self.layer addSublayer:theLayer];
  }
}


-(void)setDefaultItem{
	
	CALayer *theLayer = [self layerForDigitAtIndex:0];
	CGFloat height = 1.f/11.f;
    CGFloat width = 1.f;
    CGRect contentsRect = CGRectMake(0.f, 10*height, width, height);
    
    [CATransaction begin];
    theLayer.frame = CGRectMake(0.f, 0.f, kDigitWidth, kDigitHeight);
    [CATransaction begin];
    theLayer.contentsRect = contentsRect;
    [CATransaction commit];
    [CATransaction commit];
    
    [self.layer addSublayer:theLayer];
}



- (CALayer *)layerForDigitAtIndex:(NSUInteger)index {
  CALayer *theLayer;
  if(index >= [digitLayers_ count] || (theLayer = [digitLayers_ objectAtIndex:index]) == nil){
    theLayer = [CALayer layer];
    theLayer.anchorPoint = CGPointZero;
    theLayer.masksToBounds = YES;
    theLayer.frame = CGRectMake(0.f, 0.f, kDigitWidth, kDigitHeight);
    theLayer.contentsGravity = kCAGravityResize;
    theLayer.contents = (id)[[UIImage imageNamed:@"com_CountDownNumbers.png"] CGImage];
    
    CGFloat height = 1.f/11.f;
    //CGFloat width = kDigitWidth;
    CGFloat width = 1.f;
    theLayer.contentsRect = CGRectMake(0.f, height, width, height);
    
    [digitLayers_ insertObject:theLayer atIndex:index];
  }
  return theLayer;
}


@end


