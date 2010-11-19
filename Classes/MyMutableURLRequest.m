#import "MyMutableURLRequest.h"
#import "MethodSwizzling.h"

@implementation NSMutableURLRequest (MyMutableURLRequest)

- (void)newSetValue:(NSString *)value forHTTPHeaderField:(NSString *)field;
{
	if ([field isEqualToString:@"User-Agent"]) {

		value = 
		@"Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_2 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8C134 Safari/6533.18.5";
	}
	[self newSetValue:value forHTTPHeaderField:field];
}

+ (void)setupUserAgentOverwrite
{
	[self swizzleMethod:@selector(setValue:forHTTPHeaderField:)
		withMethod:@selector(newSetValue:forHTTPHeaderField:)];
}

@end
