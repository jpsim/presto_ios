//
//  PRECreditCard.h
//  Presto
//
//  Created by JP Simard on 2014-03-26.
//  Copyright (c) 2014 Magnetic Bear Studios. All rights reserved.
//

#import "FCModel.h"

@interface PRECreditCard : FCModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *number;
@property (nonatomic, copy) NSString *expiryMonth;
@property (nonatomic, copy) NSString *expiryYear;

@end
