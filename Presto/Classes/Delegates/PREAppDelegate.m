//
//  PREAppDelegate.m
//  Presto
//
//  Created by JP Simard on 3/25/14
//  Copyright (c) 2014 Magnetic Bear Studios. All rights reserved.
//

#import "PREAppDelegate.h"
#import "PRENavigationViewController.h"
#import "PRELoginViewController.h"

@implementation PREAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[PRENavigationViewController alloc] initWithRootViewController:[[PRELoginViewController alloc] initWithLoginType:PRELoginFieldTypeUsername]];
    [self setupAppearance];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)setupAppearance {
    [[UIButton appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
}

@end
