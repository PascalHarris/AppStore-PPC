//
//  PPC-WebWangers.m
//  App Store PPC
//
//  Created by Administrator on 23/01/2019.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import "PPC-WebWangers.h"
#import "PPC-TaskWangers.h"


@implementation PPC_WebWangers

+(NSString *)getStringFromUrl:(NSString *)url withAgent:(NSString *)agentString {
	 NSError *err = nil;  
	 NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
	 [request setValue:agentString forHTTPHeaderField:@"User-Agent"];
	 NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&err];
	 NSString *returnData = [[NSString alloc] initWithData:data	encoding:NSUTF8StringEncoding];
	 if (err != nil) {
		 NSLog(@"error message: %@", err.description);
	 }
	 return [returnData autorelease];
}

+(void)getStringFromUrl:(NSString *)url withAgent:(NSString *)agentString notificationName:(NSString *)notificationName {
	PPC_TaskWangers* taskTool = [[PPC_TaskWangers alloc] init];
	[taskTool asynchronouslyRunCommand:[NSString stringWithFormat:@"curl \"%@\"",url] withNotificationName:notificationName];
}

+(void)saveStringFromUrl:(NSString *)url toFile:(NSString *)saveStr withAgent:(NSString *)agentString notificationName:(NSString *)notificationName {
	PPC_TaskWangers* taskTool = [[PPC_TaskWangers alloc] init];
	[taskTool asynchronouslyRunCommand:[NSString stringWithFormat:@"curl \"%@\" > %@",url,saveStr] withNotificationName:notificationName];
}

+(NSRange)getRangeInString:(NSString *)sourceString forTag:(NSString *)tag withAttributeType:(NSString *)attributeType attribute:(NSString *)attrib {
	NSRange range;
	if (([attributeType length] > 0) && ([attrib length] == 0)) { 
		NSString* searchtag = [NSString stringWithFormat:@"<%@ %@",tag,attributeType];
		range = [sourceString rangeOfString:searchtag options:NSCaseInsensitiveSearch];
		if (range.location != NSNotFound) {
			NSString* substring = [sourceString substringWithRange:NSMakeRange(range.location, sourceString.length - range.location)];
			NSRange range2 = [substring rangeOfString:@">" options:NSCaseInsensitiveSearch];
			range = NSMakeRange(range.location + 1, range2.location);
		}
	} else {
		NSString* searchtag = [NSString stringWithFormat:@"<%@%@>",tag,[attributeType isEqualToString:@""]?@"":[NSString stringWithFormat:@" %@=\"%@\"",attributeType,attrib]];
		range = [sourceString rangeOfString:searchtag options:NSCaseInsensitiveSearch];
	}
	if (range.location == NSNotFound) {
		return range; //didn't find it
	}	
	
	unsigned long startLocation = range.location + range.length;
	unsigned long closingLocation = startLocation;
	unsigned long currentLocation = startLocation;
	unsigned int tagCount = 1; //set to 1 because we already have our opening.
	NSString* openingtag = [NSString stringWithFormat:@"<%@",tag];
	NSString* closingtag = [NSString stringWithFormat:@"</%@>",tag];
	NSString* substring = sourceString;
	while (range.location != NSNotFound) {
		range = NSMakeRange(currentLocation, substring.length - currentLocation); //may need to remove the openingtag length from the search
		substring = [substring substringWithRange:range];
		NSRange openingRange = [substring rangeOfString:openingtag options:NSCaseInsensitiveSearch];
		NSRange closingRange = [substring rangeOfString:closingtag options:NSCaseInsensitiveSearch];
		if ((openingRange.location != NSNotFound) && (openingRange.location < closingRange.location)) {
			tagCount++;
			currentLocation = openingRange.location + openingRange.length;
		} else {
			tagCount--;
			currentLocation = closingRange.location + closingRange.length;
		}
		
		closingLocation = closingLocation + (tagCount == 0?closingRange.location:currentLocation);
		
		if (tagCount == 0) { //all closed!
			break;
		}
	}
	
	if (closingLocation - startLocation > sourceString.length) { //need to return NSNotFound if length > length of document
		return NSMakeRange(NSNotFound, closingLocation - startLocation);;
	}
	
	return NSMakeRange(startLocation, closingLocation - startLocation);
}

+(NSRange)getRangeInString:(NSString *)sourceString forTag:(NSString *)tag withAttributeType:(NSString *)attributeType {
	return [PPC_WebWangers getRangeInString:sourceString forTag:tag withAttributeType:attributeType attribute:@""];
}

+(NSRange)getRangeInString:(NSString *)sourceString forTag:(NSString *)tag {
	return [PPC_WebWangers getRangeInString:sourceString forTag:tag withAttributeType:@"" attribute:@""];
}

+(NSString*)getLinkFromTag:(NSString*)tagString tagType:(NSString*)tagType { //valid tage types are src and href
	NSRange range;
	if ([tagType isEqualToString:@""]) {
		NSRange hrefrange = [tagString rangeOfString:@"href=\"" options:NSCaseInsensitiveSearch];
		NSRange srcrange = [tagString rangeOfString:@"src=\"" options:NSCaseInsensitiveSearch];
		range = (hrefrange.location == NSNotFound)?srcrange:hrefrange;
	} else {
		range = [tagString rangeOfString:[NSString stringWithFormat:@"%@=\"",tagType] options:NSCaseInsensitiveSearch];
	}
	if (range.location == NSNotFound) {
		return @""; //No link here!
	}
	
	NSString* linkString = [tagString substringWithRange:NSMakeRange(range.location + range.length, [tagString length] - range.location - range.length)];
	
	range = [linkString rangeOfString:@"\"" options:NSCaseInsensitiveSearch];
	linkString = [linkString substringWithRange:NSMakeRange(0, range.location)];
	
	return linkString;
}

+(NSString*)replaceMIMECharactersInString:(NSString*)sourceString {
	NSMutableString* tempString = [[NSMutableString alloc] initWithString:sourceString];
	[tempString replaceOccurrencesOfString:@"&amp;" withString:@"&" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
	[tempString replaceOccurrencesOfString:@"&#039;" withString:@"'" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
	return [tempString autorelease];
}

@end
