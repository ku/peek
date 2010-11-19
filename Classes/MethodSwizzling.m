#import "MethodSwizzling.h"
#import </usr/include/objc/objc-class.h>
@implementation NSObject (Swizzle)

+ (BOOL)swizzleMethod:(SEL)origSelector withMethod:(SEL)newSelector
{
	Method origMethod = class_getInstanceMethod(self, origSelector);
	Method newMethod = class_getInstanceMethod(self, newSelector);
	
	if (origMethod && newMethod) {
		if (class_addMethod(self, origSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
			class_replaceMethod(self, newSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
		} else {
			method_exchangeImplementations(origMethod, newMethod);
		}
		return YES;
	}
	return NO;
}

@end
