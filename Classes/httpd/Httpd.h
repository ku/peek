
#import <Foundation/Foundation.h>
#import "HttpdRequestDispatcher.h"


@interface Httpd : NSObject  {
	int server_socket;
	HttpdRequestDispatcher* _delegate;
}
-(id)initWithAddress:(uint32_t)address port:(int)n ;

@property(readwrite, retain) HttpdRequestDispatcher* delegate;
@end

