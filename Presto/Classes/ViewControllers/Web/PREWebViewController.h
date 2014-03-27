//
//  PREWebViewController.h
//  Presto
//
//  Created by JP Simard on 2014-03-27.
//  Copyright (c) 2014 Magnetic Bear Studios. All rights reserved.
//

@import UIKit;

@interface PREWebViewController : UIViewController

+ (instancetype)webVCWithHTML:(NSString *)html javascript:(NSString *)javascript;

@end
