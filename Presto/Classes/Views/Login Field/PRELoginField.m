//
//  PRELoginField.m
//  Presto
//
//  Created by JP Simard on 2014-03-25.
//  Copyright (c) 2014 Magnetic Bear Studios. All rights reserved.
//

#import "PRELoginField.h"
@import CoreGraphics;

@interface PRELoginField ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation PRELoginField

- (instancetype)init {
    self = [super init];
    
    if (!self) return nil;
    
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 6.0f;
    self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.layer.borderWidth = 0.5f;
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 5, 33, 33)];
    [self addSubview:self.imageView];
    
    self.clearButtonMode = UITextFieldViewModeAlways;
    self.enablesReturnKeyAutomatically = YES;
    return self;
}

- (void)setFieldType:(PRELoginFieldType)fieldType {
    _fieldType = fieldType;
    if (fieldType == PRELoginFieldTypeUsername) {
        [self.imageView setImage:[UIImage imageNamed:@"icon_username"]];
        self.keyboardType = UIKeyboardTypeEmailAddress;
        self.placeholder = @"username";
        self.returnKeyType = UIReturnKeyNext;
    } else if (fieldType == PRELoginFieldTypePassword) {
        [self.imageView setImage:[UIImage imageNamed:@"icon_password"]];
        self.placeholder = @"password";
        self.secureTextEntry = YES;
        self.returnKeyType = UIReturnKeyGo;
    } else if (fieldType == PRELoginFieldTypeCard) {
        [self.imageView setImage:[UIImage imageNamed:@"icon_card"]];
        self.keyboardType = UIKeyboardTypeNumberPad;
        self.placeholder = @"card number";
        self.returnKeyType = UIReturnKeyGo;
    }
    self.accessibilityLabel = self.placeholder;
}

// Placeholder Position
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 40, 0);
}

// Text Position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 40, 0);
}

@end
