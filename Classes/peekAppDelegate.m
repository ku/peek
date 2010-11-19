//
//  peekAppDelegate.m
//  peek
//
//  Created by KUMAGAI Kentaro on 10/11/08.
//  Copyright 2010 GREE, inc. All rights reserved.
//

#import "peekAppDelegate.h"
#import "peekViewController.h"

@implementation peekAppDelegate

@synthesize window;
@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.

    // Add the view controller's view to the window and display.
    [window addSubview:viewController.view];

    [window makeKeyAndVisible];
	CGRect frame = window.frame;
	frame.origin.y += 20;
	frame.size.height -= 20 + 44;
	viewController.view.frame = frame;
	
	frame = window.frame;
	frame.origin.y = frame.size.height - 44;
	frame.size.height = 44;
	_toolbar = [[UIToolbar alloc] initWithFrame:frame];
	_toolbar.items = [NSArray arrayWithObjects:
		[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:viewController action:@selector(onBack:)] autorelease],
		[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace  target:nil action:nil] autorelease],
		[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"radio-tower.png"] style:UIBarButtonItemStylePlain target:viewController action:@selector(onRadioTower:)] autorelease],
		[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:viewController action:@selector(onRefresh:)] autorelease],
	 nil
	];
	[window addSubview:_toolbar];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
