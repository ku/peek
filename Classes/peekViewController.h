//
//  peekViewController.h
//  peek
//
//  Created by KUMAGAI Kentaro on 10/11/08.
//  Copyright 2010 GREE, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Httpd.h" 

#import "PeekRequestDispatcher.h"

@class Httpd;
@interface peekViewController : UIViewController <
UIWebViewDelegate, PeekRequestDispatcherDelegate> {
	UIWebView *_webview;
	Httpd *_httpd;
	Httpd *_httpd8081;
}

@end

