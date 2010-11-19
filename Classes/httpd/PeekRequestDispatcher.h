
#import <Foundation/Foundation.h>
#import "HttpdRequestDispatcher.h"

 @protocol PeekRequestDispatcherDelegate
 -(NSString*)evaluateJavascript:(NSString*)jscode;
 @end


@interface PeekRequestDispatcher :HttpdRequestDispatcher <
	PeekRequestDispatcherDelegate
> {
	NSObject<PeekRequestDispatcherDelegate>* _delegate;
}

@property (readwrite, retain) NSObject<PeekRequestDispatcherDelegate>* delegate;

@end
