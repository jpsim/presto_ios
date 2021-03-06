//
//  PRELoginViewController.h
//  Presto
//
//  Created by JP Simard on 2014-03-25.
//  Copyright (c) 2014 Magnetic Bear Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
// Classes
#import "PREBottomConstraintViewController.h"
#import "PRELoginField.h"

@interface PRELoginViewController : PREBottomConstraintViewController

- (instancetype)initWithLoginType:(PRELoginFieldType)type;

@end
