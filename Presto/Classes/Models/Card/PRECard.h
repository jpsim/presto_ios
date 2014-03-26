//
//  PRECard.h
//  Presto
//
//  Created by JP Simard on 2014-03-26.
//  Copyright (c) 2014 Magnetic Bear Studios. All rights reserved.
//

#import "FCModel.h"

@interface PRECard : FCModel

// database columns
@property (nonatomic, copy) NSString *number;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *balance;
@property (nonatomic) NSDate *updatedTime;

@end
