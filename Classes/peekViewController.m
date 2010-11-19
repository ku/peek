//
//  peekViewController.m
//  peek
//
//  Created by KUMAGAI Kentaro on 10/11/08.
//  Copyright 2010 GREE, inc. All rights reserved.
//

#import "peekViewController.h"
#import "PeekRequestDispatcher.h"
#import "MyMutableURLRequest.h"

#import "PeekRequestDispatcher.h"
#import "PeekLongPollDispatcher.h"

#include <ifaddrs.h>
#include <arpa/inet.h>
#import "Httpd.h"

@interface peekViewController (private)
- (uint32_t)localNetworkAddress;
-(void)startHttpdServer ;
@end

@implementation peekViewController

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	_webview = [[UIWebView alloc] init];
	self.view = _webview;
	_webview.multipleTouchEnabled = YES;
	_webview.scalesPageToFit = YES;
	_webview.delegate = self;

	NSString *filename = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
	
	NSURL *url = [NSURL fileURLWithPath:filename];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[_webview loadRequest:request];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[_httpd release];
    [super dealloc];
}

-(void)injectPeekScript {
#if USE_EXTERNAL_PEEKSCRIPT
	NSURL *u = [NSURL URLWithString:@"http://localhost/peekscript.js"];
	NSURLRequest *request = [NSURLRequest requestWithURL:u];
	NSURLResponse *response;
	NSError *error;
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
#else
	NSString* scriptfile = [NSString stringWithFormat:@"%@/peekscript.js",
						  [[NSBundle mainBundle] bundlePath]];
	NSData *data = [NSData dataWithContentsOfFile:scriptfile];
#endif
	if (data) {
		NSString *jscode = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
		NSString *r = [_webview stringByEvaluatingJavaScriptFromString:jscode];
		NSLog(@"script injected: %@", r);
	}
}


#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//	if ([request respondsToSelector:@selector(setValue:forHTTPHeaderField:)]) {
//	}
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self injectPeekScript];
//	[_webview stringByEvaluatingJavaScriptFromString:@"typeof window.$peekObject"];	
}

#pragma mark httpd
-(void)startHttpdServer {
	uint32_t ip_address = [self localNetworkAddress];
	int port = 8080;
	if ( ip_address == 0 ) {
	} else {
		unsigned char *ip = (unsigned char*)&ip_address;
		NSString *address = [NSString stringWithFormat:@"%d.%d.%d.%d", ip[3], ip[2], ip[1], ip[0]];
		NSLog(@"%@", address);
		
		UIAlertView *alert;
		_httpd = [[Httpd alloc] initWithAddress:ip_address port:port];
		if (_httpd) {
			alert = [[UIAlertView alloc] initWithTitle:@"Started" message:[NSString stringWithFormat:@"Peek server started on http://%@:%d/", address, port]
											  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			PeekRequestDispatcher *dispatcher = [[[PeekRequestDispatcher alloc] init] autorelease];
			dispatcher.delegate = self;
			_httpd.delegate = dispatcher;
		} else {

			alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:[NSString stringWithFormat:@"Port %d already in use.", port]
											  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			NSLog(@"x_x");
		}
		[alert show];
		[alert autorelease];
	}
	
}
- (uint32_t)localNetworkAddress
{
	struct ifaddrs *interfaces = NULL;
	struct ifaddrs *temp_addr = NULL;
	int success = 0;
	
	uint32_t ip_address;
	bzero(&ip_address, sizeof(uint32_t));
	
	// retrieve the current interfaces - returns 0 on success
	success = getifaddrs(&interfaces);
	if (success == 0)
	{
		// Loop through linked list of interfaces
		temp_addr = interfaces;
		while(temp_addr != NULL)
		{
			if(temp_addr->ifa_addr->sa_family == AF_INET)
			{
				ip_address = ntohl(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr.s_addr);
				unsigned char *ip = (unsigned char*)&ip_address;
				if ( ((ip[3] & 0xff) == 10 ) || // classA 10.0.0.0-10.255.255.255
					( (ip[3] & 0xff) == 172 && (ip[2] & 0xf0) == 16 ) || // classB 172.16.0.0-172.31.255.255
					( (ip[3] & 0xff) == 192 && (ip[2] & 0xff) == 168 ) // classC 192.168.0.0-192.168.255.255
					) {
					break;
				}
			}
			temp_addr = temp_addr->ifa_next;
		}
	}
	
	// Free memory
	freeifaddrs(interfaces);
	
	return ip_address;
}

-(void)setupPushserverWithAddress:(NSNumber*)address {
	uint32_t ip_address = [address unsignedLongValue];
	_httpd8081 = [[Httpd alloc] initWithAddress:ip_address port:8081];
	if (_httpd8081 == nil) {
		NSLog(@"x_x");
	}
	NSLock *lock = [[NSLock alloc] init];
	PeekRequestDispatcher *dispatcher = [[[PeekLongPollDispatcher alloc] initWithLock:lock] autorelease];
	[lock lock];
	//dispatcher.delegate = viewController;
	_httpd8081.delegate = dispatcher;
}


#pragma mark events
-(void)onRefresh:(id)sender {
	[_webview reload];
}
-(void)onBack:(id)sender {
	[_webview goBack];
}
-(void)onRadioTower:(id)sender {
	[self startHttpdServer];
}

#pragma mark PeekRequestDispatcherDelegate

-(NSString*)evaluateJavascript:(NSString *)jscode {
	NSString *s = [_webview stringByEvaluatingJavaScriptFromString:jscode];
	return s;
}


@end
