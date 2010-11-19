
#import "Httpd.h"
#import "PeekLongPollDispatcher.h"


@implementation PeekLongPollDispatcher

-(id)initWithLock:(NSLock*)lock {
	if ( self = [super init] ) {
		_lock = [lock retain];
	}
	return self;
}


-(void)dealloc {
	self.delegate = nil;
	[super dealloc];
}

-(id)dispatchRequest:(NSURLRequest*)request withSocket:(NSFileHandle*)fh {
	BOOL found = NO;
	if ([[request HTTPMethod] caseInsensitiveCompare:@"get"] == NSOrderedSame) {
		[_lock lock];
	}

	
	if ( !found ) {
		const char* res = "HTTP/1.0 404 Not Found\r\n\r\n";
		NSData* response = [NSData dataWithBytes:res length:strlen(res)];
		[fh writeData:response];
		//		[fh synchronizeFile];
		//		[fh closeFile];
	}	
	return nil;
}

@end
