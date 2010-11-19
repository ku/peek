//
//  HttpdRequestParser.h
//  peek
//
//  Created by KUMAGAI Kentaro on 10/11/13.
//  Copyright 2010 GREE, inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HttpdRequestParser : NSObject {
	NSData *_data;
	const char *_parser_pointer;
	const char *_secondline;
	const char *_head_of_body;
}

-(id)initWithData:(NSData*)data;
-(NSMutableURLRequest*)parse;
@end
