//
//  HttpdRequestDispatcher.m
//  peek
//
//  Created by KUMAGAI Kentaro on 10/11/13.
//  Copyright 2010 GREE, inc. All rights reserved.
//

#import "HttpdRequestDispatcher.h"


@implementation HttpdRequestDispatcher

-(BOOL)sendContentOfFile:(NSString*)filename toSocket:(NSFileHandle*)fh {
	const char* header = "HTTP/1.0 200 OK\r\n\r\n";
	
	//			const char* nl = "\n";
	NSMutableData* d = [NSMutableData dataWithBytes:header length:strlen(header)];
	NSString* htmlfile = [NSString stringWithFormat:@"%@/%@",
						  [[NSBundle mainBundle] bundlePath], filename];
	NSData* htmldata = [NSData dataWithContentsOfFile:htmlfile];
	if ( htmldata == nil) {
		return NO;
	}
	[d appendBytes:[htmldata bytes] length:[htmldata length]];
	[fh writeData:d];
	return YES;
}

-(id)dispatchRequest:(NSURLRequest*)request withSocket:(NSFileHandle*)fh {
	return nil;
}

@end
