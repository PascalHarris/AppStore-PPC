//
//  PPC-TaskWangers.h
//  App Store PPC
//
//  Created by Administrator on 23/01/2019.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PPC_TaskWangers : NSObject {
	NSTask *task;
	NSPipe *taskPipe;
	NSMutableData* dataBuffer;
	NSString* notificationName;
}

+(NSString*)runCommand:(NSString*)fullCommandLine;
-(void)asynchronouslyRunCommand:(NSString*)fullCommandLine withNotificationName:(NSString*)notName;

@end
