//
//  PPC-StringWangers.m
//  App Store PPC
//
//  Created by Administrator on 30/01/2019.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import "PPC-StringWangers.h"


@implementation PPC_StringWangers

+(NSString*)removeDoubleSpacesFromString:(NSString*)sourceString {
	NSMutableString* tempString = [[NSMutableString alloc] initWithString:sourceString];
	while ([tempString rangeOfString:@"  "].location != NSNotFound) {
        [tempString replaceOccurrencesOfString:@"  " withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
    }
	
	NSString* returnString = [tempString copy];
	[tempString release];
	return [returnString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

/*+(NSString*)removeCharactersInSet:(NSCharacterSet*)characterSet {
	
}*/

+(BOOL)stringIsNumber:(NSString*)sourceString {
	NSCharacterSet* nonNumbers = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890.xX"] invertedSet];
    NSRange r = [sourceString rangeOfCharacterFromSet:nonNumbers];
    return r.location == NSNotFound;
}

@end
