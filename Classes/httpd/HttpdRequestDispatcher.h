//
//  HttpdRequestDispatcher.h
//  peek
//
//  Created by KUMAGAI Kentaro on 10/11/13.
//  Copyright 2010 GREE, inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HttpdRequestDispatcher : NSObject {
}
-(BOOL)sendContentOfFile:(NSString*)filename toSocket:(NSFileHandle*)fh;
-(id)dispatchRequest:(NSURLRequest*)request withSocket:(NSFileHandle*)fh;

@end
