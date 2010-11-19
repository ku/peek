//
//  peekAppDelegate.h
//  peek
//
//  Created by KUMAGAI Kentaro on 10/11/08.
//  Copyright 2010 GREE, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class peekViewController;
@class Httpd;
@interface peekAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    peekViewController *viewController;
    UIToolbar *_toolbar;
	NSLock *_lock;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet peekViewController *viewController;

@end

