
#import <Foundation/Foundation.h>
#import "PeekRequestDispatcher.h"

@interface PeekLongPollDispatcher : PeekRequestDispatcher <
	PeekRequestDispatcherDelegate
> {
	NSLock *_lock;
}
-(id)initWithLock:(NSLock*)lock ;


@end
