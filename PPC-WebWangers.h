//
//  PPC-WebWangers.h
//  App Store PPC
//
//  Created by Administrator on 23/01/2019.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PPC_WebWangers : NSObject {
	
}
+(NSString *)getStringFromUrl:(NSString *)url withAgent:(NSString *)agentString;
+(void)getStringFromUrl:(NSString *)url withAgent:(NSString *)agentString notificationName:(NSString *)notificationName;
+(void)saveStringFromUrl:(NSString *)url toFile:(NSString *)saveStr withAgent:(NSString *)agentString notificationName:(NSString *)notificationName;
+(NSRange)getRangeInString:(NSString *)sourceString forTag:(NSString *)tag withAttributeType:(NSString *)attributeType attribute:(NSString *)attrib;
+(NSRange)getRangeInString:(NSString *)sourceString forTag:(NSString *)tag withAttributeType:(NSString *)attributeType;
+(NSRange)getRangeInString:(NSString *)sourceString forTag:(NSString *)tag;
+(NSString*)getLinkFromTag:(NSString*)tagString tagType:(NSString*)tagType;
+(NSString*)replaceMIMECharactersInString:(NSString*)sourceString;

@end
