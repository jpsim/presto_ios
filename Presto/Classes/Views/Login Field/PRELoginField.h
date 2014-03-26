//
//  PRELoginField.h
//  Presto
//
//  Created by JP Simard on 2014-03-25.
//  Copyright (c) 2014 Magnetic Bear Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, PRELoginFieldType) {
    PRELoginFieldTypeUsername = 0,
    PRELoginFieldTypePassword,
    PRELoginFieldTypeCard
};

@interface PRELoginField : UITextField

@property (nonatomic) PRELoginFieldType fieldType;

@end
