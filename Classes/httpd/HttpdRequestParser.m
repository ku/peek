//
//  HttpdRequest.m
//  peek
//
//  Created by KUMAGAI Kentaro on 10/11/13.
//  Copyright 2010 GREE, inc. All rights reserved.
//

#import "HttpdRequestParser.h"

@interface HttpdRequestParser (private)
-(NSMutableDictionary*)parseFirstLine;
-(NSMutableDictionary*)parseHttpHeaders;
@end

@implementation HttpdRequestParser

-(id)initWithData:(NSData*)data {
	if ( self = [super init] ) {
		_data = [data retain];
		_head_of_body = NULL;
	}
	return self;
}

-(void)dealloc {
	[_data release];
	[super dealloc];
}
#define LINETERMINATOR "\r\n"
#define OBJC_LINETERMINATOR @"\r\n"
#define BODYSERATOR (LINETERMINATOR""LINETERMINATOR)

-(int)remainingBufferSize {
	return [_data length] - (_parser_pointer  - (const char*)[_data bytes]);
}

-(NSMutableDictionary*)parseHttpHeaders {
	NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithCapacity:4];

	const char* eoh = strnstr(_parser_pointer, BODYSERATOR, [self remainingBufferSize]);
	if (eoh == NULL) {
		return headers;
	}
	NSString *headers_chunk = [[NSString alloc] initWithBytes:_parser_pointer length:eoh - _parser_pointer encoding:NSUTF8StringEncoding];
	NSArray *header_lines = [headers_chunk componentsSeparatedByString:OBJC_LINETERMINATOR];
	
	for (NSString *line in header_lines) {
		NSArray *components = [line componentsSeparatedByString:@":"];
		if ([components count] > 1) {
			NSString *left_side = [components objectAtIndex:0];
			NSMutableArray *right_side_components = [NSMutableArray arrayWithArray:components];
			[right_side_components removeObjectAtIndex:0];
			NSString *right_side = [right_side_components componentsJoinedByString:@":"];
			right_side = [right_side stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			[headers setObject:right_side forKey:[left_side lowercaseString]];
		}
	}
	_head_of_body = eoh + strlen(BODYSERATOR);
	_parser_pointer = _head_of_body;
	return headers;
}


-(NSMutableDictionary*)parseFirstLine {
	const char* end_of_firstline = strnstr(_parser_pointer, LINETERMINATOR, [self remainingBufferSize]);
	if (end_of_firstline == NULL) {
		return nil;
	}
	
	const char *p = _parser_pointer;
	
	NSString *methodName = nil;
	const char *method = p;
	while (p < end_of_firstline) {
		if (isspace(*++p)) {
			methodName = [[NSString alloc] initWithBytes:method length:p - method encoding:NSASCIIStringEncoding];
			break;
		}
	}
	if (methodName == nil) {
		return nil;
	}
	
	while (p < end_of_firstline) {
		if (!isspace(*++p)) {
			break;
		}
	}
	
	NSString *pathName = nil;
	const char *path = p;
	while (p < end_of_firstline) {
		if (isspace(*++p)) {
			pathName = [[NSString alloc] initWithBytes:path length:p - path encoding:NSASCIIStringEncoding];
			break;
		}
	}
	if (pathName == nil) {
		return nil;
	}

	_secondline = end_of_firstline + strlen(LINETERMINATOR);

	return [NSMutableDictionary dictionaryWithObjectsAndKeys:
				methodName, @"method",
				pathName, @"path",
			nil];
}

-(NSMutableURLRequest*)parse {
	_parser_pointer = [_data bytes];
	NSMutableDictionary *requestParameters = [self parseFirstLine];
	if (requestParameters == nil) {
		return nil;
	}

	NSMutableDictionary *headers = [self parseHttpHeaders];
	NSString *host = [headers objectForKey:@"host"];
	int port = 80;
	if (host) {
		NSArray *host_components = [host componentsSeparatedByString:@":"];
		if ([host_components count] > 1) {
			port = atoi([[host_components objectAtIndex:1] cString]);
		}
	} else {
		host = @"localhost";
	}
	NSString *u = [NSString stringWithFormat:@"http://%@%@", host, [requestParameters objectForKey:@"path"]];
	NSURL *url = [NSURL URLWithString:u];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:[requestParameters objectForKey:@"method"]];
	[request setAllHTTPHeaderFields:headers];
	if ([[requestParameters objectForKey:@"method"] caseInsensitiveCompare:@"post"] == NSOrderedSame ) {
		int remaining = [self remainingBufferSize];
		if (remaining > 0) {
			if ( _head_of_body) {
				NSData *data = [[[NSData alloc] initWithBytes:_head_of_body length:remaining] autorelease];
				[request setHTTPBody:data];
			}
		}
	}
	return request;
 }

@end
