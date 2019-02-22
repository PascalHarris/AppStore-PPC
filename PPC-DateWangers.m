//
//  PPC-DateWangers.m
//  App Store PPC
//
//  Created by Administrator on 26/01/2019.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import "PPC-DateWangers.h"


@implementation PPC_DateWangers

+(int)getCurrentYear {
	NSCalendarDate *today = [NSCalendarDate date];
	return [today yearOfCommonEra];
}

@end
