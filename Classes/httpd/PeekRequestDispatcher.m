
#import "Httpd.h"
#import "PeekRequestDispatcher.h"


@implementation PeekRequestDispatcher

@synthesize delegate = _delegate;

-(void)dealloc {
	self.delegate = nil;
	[super dealloc];
}

-(id)dispatchRequest:(NSURLRequest*)request withSocket:(NSFileHandle*)fh {
	BOOL found = NO;
	if ([[request HTTPMethod] caseInsensitiveCompare:@"get"] == NSOrderedSame) {
		NSString *path = [request.URL path];
		if ([path isEqualToString:@"/"]) {
			found = [self sendContentOfFile:@"console.html" toSocket:fh];
		} else {
			NSArray *components = [path componentsSeparatedByString:@"/"];
//			NSString *path = [[NSBundle mainBundle] bundlePath];
///			NSString * filename =[NSString stringWithFormat:@"%@/%@", path,
	//							  [components lastObject]];
			found = [self sendContentOfFile:[components lastObject] toSocket:fh];
//			NSString *content = [[NSString alloc] initWithContentsOfFile:filename];
		}
	} else if ([[request HTTPMethod] caseInsensitiveCompare:@"post"] == NSOrderedSame) {
		NSString *jscode = [[NSString alloc] initWithData:[request HTTPBody] 
													  encoding:NSASCIIStringEncoding];
			
			NSString *result = nil;
			if ([_delegate respondsToSelector:@selector(evaluateJavascript:)]) {
				result = [_delegate evaluateJavascript:jscode];
			}
			if (result) {
				const char* header = "HTTP/1.0 200 OK\r\nAccess-Control-Allow-Origin: *\r\n\r\n";
				NSMutableData* d = [NSMutableData dataWithBytes:header length:strlen(header)];
				const char* response = [result cStringUsingEncoding:NSUTF8StringEncoding];
				[d appendBytes:response length:strlen(response)];
				[fh writeData:d];
			} else {
				const char* header = "HTTP/1.0 200 OK\r\nContent-Type: application/json\r\nAccess-Control-Allow-Origin: *\r\n\r\n";
				NSMutableData* d = [NSMutableData dataWithBytes:header length:strlen(header)];
				[fh writeData:d];
			}			
			found = YES;
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
