//
//  main.m
//  peek
//
//  Created by KUMAGAI Kentaro on 10/11/08.
//  Copyright 2010 GREE, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyMutableURLRequest.h"
int main(int argc, char *argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
[NSMutableURLRequest setupUserAgentOverwrite];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}
