//
//  PPC-TaskWangers.m
//  App Store PPC
//
//  Created by Administrator on 23/01/2019.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import "PPC-TaskWangers.h"


@implementation PPC_TaskWangers

+(NSString*)runCommand:(NSString*)fullCommandLine {
	NSTask *task = [NSTask new];
	[task setLaunchPath:@"/bin/bash"];
	[task setArguments:[NSArray arrayWithObjects:@"-c", fullCommandLine,nil]];
	NSPipe *taskPipe = [NSPipe pipe];
	[task setStandardOutput:taskPipe];
	[task setStandardError:[task standardOutput]];
	NSFileHandle *taskFile = [taskPipe fileHandleForReading];
	[task launch];
	NSString *taskOutput = [[NSString alloc] initWithData:[taskFile readDataToEndOfFile] encoding:NSASCIIStringEncoding];
	return [taskOutput autorelease];
}

-(void)asynchronouslyRunCommand:(NSString*)fullCommandLine withNotificationName:(NSString*)notName {
	task = [[NSTask alloc] init];
	taskPipe = [[NSPipe alloc] init];
	dataBuffer = [[NSMutableData alloc] init];
	notificationName = [[NSString alloc] initWithString:notName];
	
	[task setLaunchPath:@"/bin/bash"];
	[task setArguments:[NSArray arrayWithObjects:@"-c", fullCommandLine,nil]];
	[task setStandardOutput:taskPipe];
	[task setStandardError:[task standardOutput]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReady:) name:NSFileHandleReadCompletionNotification object:[taskPipe fileHandleForReading]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskTerminated:) name:NSTaskDidTerminateNotification object:task];
	
	[task launch];
	
	[[taskPipe fileHandleForReading] readInBackgroundAndNotify];
}

-(void)dataReady:(NSNotification*)note {
	NSData* data = [[note userInfo] valueForKey:NSFileHandleNotificationDataItem];
	if (data) {
		[dataBuffer appendData:data];
	}
	[[taskPipe fileHandleForReading] readInBackgroundAndNotify];
}

-(void)taskTerminated:(NSNotification*)note {
	NSData* data = [[taskPipe fileHandleForReading] readDataToEndOfFile];
	if (data) {
		[dataBuffer appendData:data];
	}
	[task release];
	task = nil;
	[taskPipe release];
	taskPipe = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:notificationName	object:self userInfo:[NSDictionary dictionaryWithObject:dataBuffer forKey:[NSString stringWithFormat:@"%@DataItem",notificationName]]];
	[dataBuffer release];
	dataBuffer = nil;
	[notificationName release];
	notificationName = nil;
}

@end
