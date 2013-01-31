//
//  AppDelegate.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 07.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "AppDelegate.h"

#import "StolpersteineNetworkService.h"

#ifdef DEBUG
@interface NSURLRequest (HTTPS)
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString *)host;
@end
#endif

static NSString * const BASE_URL = @"https://stolpersteine-optionu.rhcloud.com/api/";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSURL *url = [NSURL URLWithString:BASE_URL];
    self.networkService = [[StolpersteineNetworkService alloc] initWithURL:url clientUser:nil clientPassword:nil];
#ifdef DEBUG
    // This allows invalid certificates so that proxies can decrypt the traffic.
    [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:url.host];
#endif
    
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}

+ (StolpersteineNetworkService *)networkService
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.networkService;
}
							
@end
