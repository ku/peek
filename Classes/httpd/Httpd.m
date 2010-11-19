
#import "Httpd.h"
//#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#import "HttpdRequestParser.h"

@interface Httpd (private)
-(int)_initSocketWithAddress:(uint32_t)address port:(int)n ;
-(void)observe:(NSNotification*)notification ;
@end

@implementation Httpd

@synthesize delegate = _delegate;

-(id)initWithAddress:(uint32_t)address port:(int)n {
	if (self = [super init]) {
		if([self _initSocketWithAddress:address port:n]) {
			return nil;
		}
	}
	return self;
}

-(void)dealloc {
	close(server_socket);
	[super dealloc];
}

-(int)_initSocketWithAddress:(uint32_t)address port:(int)n {
    struct sockaddr_in addr;
		
	int sock = socket(AF_INET, SOCK_STREAM, 0) ;
	server_socket = sock;
	
	int namelen = sizeof(addr);
	
	if(sock <= 0) {
		return 1;
	}
	memset(&addr, 0, sizeof(addr));
	addr.sin_len = namelen;
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = htonl(address);
	addr.sin_port = htons(n);

	// Allow the kernel to choose a random port number by passing in 0 for the port.
	if (bind(sock, (struct sockaddr *)&addr, namelen) < 0) {
		close (sock);
		return 1;
	}
	/*
	// Find out what port number was chosen.
	if (getsockname(sock, (struct sockaddr *)&serverAddress, &namelen) < 0) {
	close(sock);
	return 2;
	}
	*/
	// Once we're here, we know bind must have returned, so we can start the listen
	if( listen(sock, 1) ) {
		close(sock);
		return 3;
	}

	
	NSFileHandle* fh = [[NSFileHandle alloc] initWithFileDescriptor:sock
													 closeOnDealloc:YES
	];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(observe:)
												 name:NSFileHandleConnectionAcceptedNotification
											   object:fh];
	[fh acceptConnectionInBackgroundAndNotify];

	return 0;
}
-(void)observe:(NSNotification*)notification {
	NSDictionary* info = [notification userInfo];
	NSFileHandle* fh = (NSFileHandle*)[info objectForKey:NSFileHandleNotificationFileHandleItem];
	
	NSData* data = [fh availableData];

	HttpdRequestParser *parser = [[[HttpdRequestParser alloc] initWithData:data] autorelease];
	NSMutableURLRequest *request = [parser parse];
	if (request) {
		[_delegate dispatchRequest:request withSocket:fh];
	} else {
		const char* res = "HTTP/1.0 400 Bad Request\r\n\r\n";
		NSData* response = [NSData dataWithBytes:res length:strlen(res)];
		[fh writeData:response];
	}
	[[notification object] acceptConnectionInBackgroundAndNotify];


}

@end
/*
cat ../console.html | perl -nle '/^\s*$/ or  s/\\/\\\\/g, s/"/\\"/g, print qq{"$_\\n"\\} ' >! html.h; echo  >> html.h
 */
