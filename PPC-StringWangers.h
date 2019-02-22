//
//  PPC-StringWangers.h
//  App Store PPC
//
//  Created by Administrator on 30/01/2019.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PPC_StringWangers : NSObject {

}

+(NSString*)removeDoubleSpacesFromString:(NSString*)sourceString;
+(BOOL)stringIsNumber:(NSString*)sourceString;

@end
