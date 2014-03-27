//
//  PREAppDelegate.m
//  Presto
//
//  Created by JP Simard on 3/25/14
//  Copyright (c) 2014 Magnetic Bear Studios. All rights reserved.
//

#import "PREAppDelegate.h"
// View Controllers
#import "PRENavigationViewController.h"
#import "PRELoginViewController.h"
#import "PREMainViewController.h"
// Model
#import "FCModel.h"

@implementation PREAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupModel];
    [self setupAppearance];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[PRENavigationViewController alloc] initWithRootViewController:[[PRELoginViewController alloc] initWithLoginType:PRELoginFieldTypeUsername]];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)setupModel {
    NSString *dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"presto.sqlite3"];
    
    [FCModel openDatabaseAtPath:dbPath withSchemaBuilder:^(FMDatabase *db, int *schemaVersion) {
        [db setCrashOnErrors:YES];
        [db beginTransaction];
        
        void (^failedAt)(int statement) = ^(int statement){
            [db rollback];
        };
        
        if (*schemaVersion < 1) {
            if (![db executeUpdate:
                  @"CREATE TABLE PREUser ("
                  @"    cardNumber   TEXT PRIMARY KEY,"
                  @"    username     TEXT NOT NULL DEFAULT '',"
                  @"    password     TEXT NOT NULL DEFAULT '',"
                  @"    firstName    TEXT NOT NULL DEFAULT '',"
                  @"    lastName     TEXT NOT NULL DEFAULT '',"
                  @"    address1     TEXT NOT NULL DEFAULT '',"
                  @"    address2     TEXT NOT NULL DEFAULT '',"
                  @"    city         TEXT NOT NULL DEFAULT '',"
                  @"    province     TEXT NOT NULL DEFAULT '',"
                  @"    country      TEXT NOT NULL DEFAULT '',"
                  @"    postalCode   TEXT NOT NULL DEFAULT '',"
                  @"    phoneNumber  TEXT NOT NULL DEFAULT '',"
                  @"    email        TEXT NOT NULL DEFAULT '',"
                  @"    securityQuestion TEXT NOT NULL DEFAULT '',"
                  @"    securityAnswer   TEXT NOT NULL DEFAULT '',"
                  @"    createdTime  INTEGER NOT NULL,"
                  @"    modifiedTime INTEGER NOT NULL"
                  @");"
                  ]) failedAt(1);
            
            if (![db executeUpdate:@"CREATE UNIQUE INDEX IF NOT EXISTS name ON PREUser (username);"]) failedAt(2);
            
            if (![db executeUpdate:
                  @"CREATE TABLE PRECard ("
                  @"    number      TEXT PRIMARY KEY,"
                  @"    status      TEXT NOT NULL,"
                  @"    balance     TEXT NOT NULL,"
                  @"    updatedTime INTEGER NOT NULL"
                  @");"
                  ]) failedAt(3);
            
            if (![db executeUpdate:
                  @"CREATE TABLE PRECreditCard ("
                  @"    number      TEXT PRIMARY KEY,"
                  @"    name        TEXT NOT NULL,"
                  @"    expiryMonth TEXT NOT NULL,"
                  @"    expiryYear  TEXT NOT NULL"
                  @");"
                  ]) failedAt(4);
            
            *schemaVersion = 1;
        }
        
        [db commit];
    }];
}

- (void)setupAppearance {
    [[UIButton appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
}

@end
