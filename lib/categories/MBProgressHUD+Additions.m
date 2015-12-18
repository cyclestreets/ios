//
//  MBProgressHUD+Additions.m
//  CycleStreets
//
//  Created by Neil Edwards on 18/12/2015.
//  Copyright © 2015 CycleStreets Ltd. All rights reserved.
//

#import "MBProgressHUD+Additions.h"
#import "MBProgressHUD.h"
#import "GenericConstants.h"
#import <objc/runtime.h>

static char cancelOperationKey;
static const void *cancelOperationBlockKey = &cancelOperationBlockKey;

@implementation MBProgressHUD (Additions)


- (BOOL)cancelOperation {
	NSNumber *cancelOperationWrapper = objc_getAssociatedObject(self, &cancelOperationKey);
	return [cancelOperationWrapper boolValue];
}

- (void)setCancelOperation:(BOOL)cancelOperation {
	NSNumber *cancelOperationWrapper = [NSNumber numberWithBool:cancelOperation];
	objc_setAssociatedObject(self, &cancelOperationKey, cancelOperationWrapper, OBJC_ASSOCIATION_ASSIGN);
}


-(void)setCancelOperationBlock:(GenericCompletionBlock)action{
	
	objc_setAssociatedObject(self, cancelOperationBlockKey, action, OBJC_ASSOCIATION_COPY_NONATOMIC);

}

- (GenericCompletionBlock)cancelOperationBlock{
	GenericCompletionBlock block= objc_getAssociatedObject(self, cancelOperationBlockKey);
	return block;
}




//+ (void)load {
//	static dispatch_once_t once_token;
//	dispatch_once(&once_token,  ^{
//		//SEL hideUsingAnimationSelector = @selector(hideUsingAnimation:);
//		SEL Category_hideUsingAnimationSelector = @selector(category_hideUsingAnimation:);
//		Method originalMethod = class_getInstanceMethod([MBProgressHUD class], @selector(hideUsingAnimation:));
//		Method extendedMethod = class_getInstanceMethod(self, Category_hideUsingAnimationSelector);
//		method_exchangeImplementations(originalMethod, extendedMethod);
//	});
//}
//- (void) category_hideUsingAnimation:(BOOL)animated {
//	
//	[self category_hideUsingAnimation:animated]; // will call orginal method
//	
//	if(self.cancelOperation==YES){
//		if(self.cancelOperationBlock){
//			self.cancelOperationBlock(YES,nil);
//		}
//	}
//	
//}


@end
