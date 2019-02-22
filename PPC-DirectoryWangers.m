//
//  PPC-DirectoryWangers.m
//  App Store PPC
//
//  Created by Administrator on 23/01/2019.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import "PPC-DirectoryWangers.h"


@implementation PPC_DirectoryWangers

+(NSString*)tempDirectory {
	NSString * tempDir = NSTemporaryDirectory();
	if (tempDir == nil) {
		tempDir = @"/tmp";
	}
	return tempDir;
}

@end
