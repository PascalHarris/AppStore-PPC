//
//  mgGenerateDictionary.m
//  App Store PPC
//
//  Created by Administrator on 26/01/2019.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import "mgGenerateDictionary.h"
#import "PPC-WebWangers.h"
#import "PPC-DateWangers.h"
#import "PPC-StringWangers.h"

@implementation mgGenerateDictionary

-(void)releaseObjects {
	[applicationLibrary release];
	applicationLibrary = nil;
}

-(void)updateProgress:(NSNumber*)percentageProgress {
	NSDictionary* progressDictionary = [NSDictionary dictionaryWithObjectsAndKeys:percentageProgress,@"Progress",[NSNumber numberWithBool:NO],@"Finished",nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateRefreshProgress" object:self userInfo:progressDictionary];
}

#pragma mark get full application library

-(NSDictionary*)getNameAndVersionNumberForApp:(NSString*)appName withDescription:(NSString*)description {
	NSString* applicationName = [PPC_StringWangers removeDoubleSpacesFromString:appName]; //Parse headingString to extract application name and version number
	NSString* baseVersionNumber = @"1.0";
	NSString* versionString = baseVersionNumber;
	
	NSMutableArray* applicationNameArray = [[NSMutableArray alloc] initWithArray:[applicationName componentsSeparatedByString:@" "]];
	int versionIndex = 0;
	bool protected = FALSE;
	for (int i = 0; i < [applicationNameArray count]; i++) {
		NSString* namePart = [applicationNameArray objectAtIndex:i];
		
		protected = ((index == 0) && ([namePart isEqualToString:@"System"] || [namePart isEqualToString:@"MacOS"] || [namePart isEqualToString:@"Mac OS"]));
		
		int versionNumber = [namePart intValue];
		if ((versionNumber != 32) && (versionNumber < 100)) {
			NSMutableString* tempString = [[NSMutableString alloc] initWithString:namePart];
			[tempString replaceOccurrencesOfString:@"v" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
			[tempString replaceOccurrencesOfString:@"x" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
			[tempString replaceOccurrencesOfString:@"a" withString:@"." options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])]; //alpha
			[tempString replaceOccurrencesOfString:@"b" withString:@"." options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])]; //beta
			[tempString replaceOccurrencesOfString:@"f" withString:@"." options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])]; //final
			[tempString replaceOccurrencesOfString:@"-" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
			[tempString replaceOccurrencesOfString:@"," withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
			
			if ([PPC_StringWangers stringIsNumber:tempString]) {
				versionIndex = i;
				versionString = [tempString copy];
			}
			[tempString release];
		}
		if (versionIndex > 0 && !protected) {
			[applicationNameArray removeObjectAtIndex:versionIndex];
			applicationName = [[applicationNameArray componentsJoinedByString:@" "] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		} else {
			applicationName = appName;
		}
	}
	[applicationNameArray release];
	
	if ([versionString isEqualToString:baseVersionNumber]) { // have a look in the description for the version number
		NSString* applicationDesc = [PPC_StringWangers removeDoubleSpacesFromString:description]; //Parse headingString to extract application name and version number
		NSMutableArray* applicationDescriptionArray = [[NSMutableArray alloc] initWithArray:[applicationDesc componentsSeparatedByString:@" "]];
		for (int i = 0; i < [applicationDescriptionArray count]; i++) {
			NSString* namePart = [applicationDescriptionArray objectAtIndex:i];
			int versionNumber = [namePart intValue];
			if ((versionNumber != 32) && (versionNumber < 100)) {
				NSMutableString* tempString = [[NSMutableString alloc] initWithString:namePart];
				[tempString replaceOccurrencesOfString:@"v" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
				[tempString replaceOccurrencesOfString:@"x" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
				[tempString replaceOccurrencesOfString:@"a" withString:@"." options:NSLiteralSearch range:NSMakeRange(0, [tempString length])]; //alpha
				[tempString replaceOccurrencesOfString:@"b" withString:@"." options:NSLiteralSearch range:NSMakeRange(0, [tempString length])]; //beta
				[tempString replaceOccurrencesOfString:@"f" withString:@"." options:NSLiteralSearch range:NSMakeRange(0, [tempString length])]; //final
				[tempString replaceOccurrencesOfString:@"-" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempString length])];
				
				if ([PPC_StringWangers stringIsNumber:tempString]) {
					versionString = [tempString copy];
				}
				[tempString release];
			}
		}
		[applicationDescriptionArray release];
	}
	
	if ([versionString isEqualToString:@""] || [versionString characterAtIndex:0] == '.') {
		versionString = baseVersionNumber;
	}
	
	return [NSDictionary dictionaryWithObjectsAndKeys:applicationName,@"AppName",versionString,@"Version",nil];
}

-(NSDictionary*)extractDataFromTable:(NSString*)HTMLTable {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//find metadata
	NSMutableDictionary* returnDictionary = [NSMutableDictionary new];
	NSRange metaRange;
	metaRange.location = 0;
	NSString* rating = @"0";
	while ((metaRange.location != NSNotFound)  && !terminate) { // look at, and fetch, all metadata for the app
		NSString* metaData = [HTMLTable substringWithRange:NSMakeRange(metaRange.location, [HTMLTable length] - metaRange.location)];
		
		NSRange subRange = [PPC_WebWangers getRangeInString:metaData forTag:@"tr"]; //gets a line of data
		if (subRange.location != NSNotFound) {
			NSString* metaDataItem = (subRange.location != NSNotFound)?[metaData substringWithRange:subRange]:@"";
			
			NSRange metaTagRange = [PPC_WebWangers getRangeInString:metaDataItem forTag:@"strong"]; 
			NSString* metaTag = (metaTagRange.location != NSNotFound)?[metaDataItem substringWithRange:NSMakeRange(metaTagRange.location, metaTagRange.length - 1)]:@"";// need to trim colon
			
			if ([metaTag isEqualToString:@"Rating"]) {
				NSRange ratingRange = [PPC_WebWangers getRangeInString:metaData forTag:@"span" withAttributeType:@"class" attribute:@"on"]; //gets a line of data
				if (ratingRange.location == NSNotFound) {
					ratingRange = [PPC_WebWangers getRangeInString:metaData forTag:@"span" withAttributeType:@"class" attribute:@"off"]; //gets a line of data
				}
				if (ratingRange.location != NSNotFound) {
					NSString* temprating = [metaData substringWithRange:ratingRange];
					if ([PPC_StringWangers stringIsNumber:temprating]) {
						rating = [temprating copy];
					}
				}
				[returnDictionary setObject:([rating length] > 0?rating:@"0") forKey:@"Rating"];
			}
			
			metaTagRange = [PPC_WebWangers getRangeInString:metaDataItem forTag:@"a" withAttributeType:@"href"];
			NSString* metaItem = (metaTagRange.location != NSNotFound)?[metaDataItem substringWithRange:metaTagRange]:@"";// need to trim colon
			
			if ([metaTag length] > 0) {
				[returnDictionary setObject:[PPC_WebWangers replaceMIMECharactersInString:metaItem] forKey:metaTag];
			}
			
			metaRange.location+=(subRange.location + subRange.length);
		} else {
			metaRange = subRange;
		}
	}
	
	return [returnDictionary autorelease];
	
	[pool release];
}

-(void)extractDataFromPage:(NSString*)pageSource withYear:(int)currentYear {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSRange appRange;
	appRange.location = 0;
	while ((appRange.location != NSNotFound) && !terminate) { // look at, and fetch, all the apps on the page
		pageSource = [pageSource substringWithRange:NSMakeRange(appRange.location, [pageSource length] - appRange.location)];
		appRange = [PPC_WebWangers getRangeInString:pageSource forTag:@"div" withAttributeType:@"class" attribute:@"game-preview"];
		if (appRange.location != NSNotFound) {
			NSMutableDictionary* appDictionary = [[NSMutableDictionary alloc] init];
			NSString* currentApp = [pageSource substringWithRange:appRange];
			[appDictionary setObject:[NSNumber numberWithInt:currentYear] forKey:@"Year"];
			
			NSRange range = [PPC_WebWangers getRangeInString:currentApp forTag:@"a" withAttributeType:@"href"];
			NSString* headingString = (range.location != NSNotFound)?[currentApp substringWithRange:range]:@"";
			
			range = [PPC_WebWangers getRangeInString:currentApp forTag:@"p"];
			NSString* descString = (range.location != NSNotFound)?[currentApp substringWithRange:range]:@"";
			[appDictionary setObject:[PPC_WebWangers replaceMIMECharactersInString:descString] forKey:@"Description"];
			
			//Parse headingString to extract application name and version number
			NSDictionary* nameAndVersion = [self getNameAndVersionNumberForApp:headingString withDescription:descString];
			
			[appDictionary setObject:[PPC_WebWangers replaceMIMECharactersInString:[nameAndVersion objectForKey:@"AppName"]] forKey:@"Application Name"];
			[appDictionary setObject:[nameAndVersion objectForKey:@"Version"] forKey:@"Version Number"];
			
			range = [PPC_WebWangers getRangeInString:currentApp forTag:@"div" withAttributeType:@"class" attribute:@"images"];
			NSString* appLink = (range.location != NSNotFound)?[PPC_WebWangers getLinkFromTag:[currentApp substringWithRange:range] tagType:@"href"]:@"";
			if ([appLink rangeOfString:@"macintoshgarden.org" options:NSCaseInsensitiveSearch].location == NSNotFound) {
				appLink = [NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] localizedStringForKey:@"store website" value:@"" table:@"Resources"],appLink];
			}
			[appDictionary setObject:appLink forKey:@"Application URL"]; // May want to ensure the URL is complete before storing it.
			
			range = [PPC_WebWangers getRangeInString:currentApp forTag:@"div" withAttributeType:@"class" attribute:@"images"];
			NSString* imgLink = (range.location != NSNotFound)?[PPC_WebWangers getLinkFromTag:[currentApp substringWithRange:range] tagType:@"src"]:@"";
			if ([imgLink rangeOfString:[[NSBundle mainBundle] localizedStringForKey:@"store website" value:@"" table:@"Resources"] options:NSCaseInsensitiveSearch].location == NSNotFound) {
				imgLink = [NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] localizedStringForKey:@"store website" value:@"" table:@"Resources"],imgLink];
			}
			[appDictionary setObject:imgLink forKey:@"Application Image"]; // May want to ensure the URL is complete before storing it.
			
			NSDictionary* tempDictionary = [self extractDataFromTable:currentApp];
			if (tempDictionary && [[tempDictionary allKeys] count] > 0) {
				[appDictionary addEntriesFromDictionary:tempDictionary];
			}
			
			[applicationLibrary addObject:[appDictionary copy]];
			[appDictionary release];
		} else {
			break;
		}
		
		appRange.location+=appRange.length;
	}
	
	[pool release];
}

-(void)getLibrary {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	int startYear = 1984; // will eventually decide the start year intelligently otherwise 1984
	int year = startYear; // got to start somewhere!
	int thisYear = [PPC_DateWangers getCurrentYear]; //	thisYear = 1991; //for debugging
	
	if (applicationLibrary != nil) {
		[self releaseObjects];
	} 
	
	applicationLibrary = [[NSMutableArray alloc] init];
	
	while ((year <= thisYear) && !terminate) {
		
		[self performSelectorOnMainThread: @selector(updateProgress:)
							   withObject: [NSNumber numberWithInt:(100/(thisYear - startYear)) * (year - startYear)]
							waitUntilDone: NO];
		
		int page = 0, currentYear = year++;
		NSString* yearURL = [NSString stringWithFormat:@"/year/%d",currentYear];
		NSRange pageRange;
		pageRange.location = NSNotFound;
		while ((pageRange.location == NSNotFound) && !terminate) {
			NSString* pageURL = [NSString stringWithFormat:@"/?page=%d",page++];
			NSString* fullURL = [NSString stringWithFormat:@"%@%@%@",[[NSBundle mainBundle] localizedStringForKey:@"store website" value:@"" table:@"Resources"],yearURL,pageURL];
			NSString* pageSource = [PPC_WebWangers getStringFromUrl:fullURL 
														  withAgent:[[NSBundle mainBundle] localizedStringForKey:@"agent string" value:@"" table:@"Resources"]]; //get web page
			
			pageRange = [PPC_WebWangers getRangeInString:pageSource forTag:@"li" withAttributeType:@"class" attribute:@"pager-current last"]; // check to see if this is the last page
			
			if ([pageSource rangeOfString:[[NSBundle mainBundle] localizedStringForKey:@"page not found" value:@"" table:@"Resources"] options:NSCaseInsensitiveSearch].location != NSNotFound) {
				NSLog(@"Whoops - Bad Page for year %d", currentYear);
				break;
			}
			
			[self extractDataFromPage:pageSource withYear:currentYear];
			
		}
	}
	
	if (terminate) {
		NSLog(@"Terminating Early");
		[applicationLibrary removeAllObjects];
	} 
	
	[pool release];
}

#pragma mark Get details for application

-(NSDictionary*)getApplicationDetailsWithURL:(NSString*)pageURL {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableDictionary* returnDictionary = [NSMutableDictionary new];
	if (pageURL && [pageURL length] > 0) {
		NSString* pageSource = [PPC_WebWangers getStringFromUrl:pageURL 
													  withAgent:[[NSBundle mainBundle] localizedStringForKey:@"agent string" value:@"" table:@"Resources"]]; //get web page
		
		NSRange pageRange = [PPC_WebWangers getRangeInString:pageSource forTag:@"div" withAttributeType:@"id" attribute:@"paper"];
		if (pageRange.location != NSNotFound) {
			pageSource = [pageSource substringWithRange:pageRange];			
			pageRange = [PPC_WebWangers getRangeInString:pageSource forTag:@"h1"];
			
			NSString *applicationName = (pageRange.location != NSNotFound)?[pageSource substringWithRange:pageRange]:@"";
			[returnDictionary setObject:applicationName forKey:@"Application Name"];
			
			pageRange = [PPC_WebWangers getRangeInString:pageSource forTag:@"div" withAttributeType:@"class" attribute:@"images"];
			NSString* imageLinks = (pageRange.location != NSNotFound)?[pageSource substringWithRange:pageRange]:@"";
			NSMutableArray* imageLinkArray = [NSMutableArray new];
			while (pageRange.location != NSNotFound) {
				pageRange = [PPC_WebWangers getRangeInString:imageLinks forTag:@"a" withAttributeType:@"href"];
				NSString* imgLink = (pageRange.location != NSNotFound)?[PPC_WebWangers getLinkFromTag:imageLinks tagType:@"href"]:@"";
				if ([imgLink length] > 1) {
					NSRange rootURLLocation = [imgLink rangeOfString:[[NSBundle mainBundle] localizedStringForKey:@"store website" value:@"" table:@"Resources"]];
					imgLink = [NSString stringWithFormat:@"%@%@",
							   [[NSBundle mainBundle] localizedStringForKey:@"store website" value:@"" table:@"Resources"], 
							   (rootURLLocation.location == NSNotFound)?imgLink:[imgLink substringWithRange:NSMakeRange(rootURLLocation.length, [imgLink length] - rootURLLocation.length)]];
					
/*					NSURL* imgURL = [[NSURL alloc] initWithString:imgLink];
					NSLog(@"%@",imgURL);
					NSImage *image = [[NSImage alloc] initWithContentsOfURL:imgURL];
					[imageLinkArray addObject:[image copy]]; // Put actual image data here.
					[image release];
					[imgURL release];*/
					[imageLinkArray addObject:imgLink];
				}
				if (pageRange.location != NSNotFound && [imageLinks length] >= pageRange.location + pageRange.length) {
					imageLinks = [imageLinks substringWithRange:NSMakeRange(pageRange.location + pageRange.length, [imageLinks length] - (pageRange.location + pageRange.length))];
				} else if ([imageLinks length] >= pageRange.length) {
					pageRange.location = NSNotFound;
				}
			}
			[returnDictionary setObject:[imageLinkArray copy] forKey:@"Image Links"];
			[imageLinkArray release];
			
			//Need download links - (need to implement a download manager too)
			pageRange = [PPC_WebWangers getRangeInString:pageSource forTag:@"div" withAttributeType:@"class" attribute:@"note download"];
			NSString* downloadLinks = (pageRange.location != NSNotFound)?[pageSource substringWithRange:pageRange]:@"";
			NSMutableArray* downloadLinkArray = [NSMutableArray new];
			while (pageRange.location != NSNotFound) {
				pageRange = [PPC_WebWangers getRangeInString:downloadLinks forTag:@"a" withAttributeType:@"href"];
				NSString* downloadLink = (pageRange.location != NSNotFound)?[PPC_WebWangers getLinkFromTag:downloadLinks tagType:@"href"]:@"";
				if ([downloadLink length] > 1) {
					if (([downloadLink rangeOfString:@"ftp://"].location == NSNotFound) && 
						([downloadLink rangeOfString:@"http://"].location == NSNotFound) && 
						([downloadLink rangeOfString:@"https://"].location == NSNotFound) && 
						([downloadLink rangeOfString:@"ftps://"].location == NSNotFound) && 
						([downloadLink rangeOfString:@"sftp://"].location == NSNotFound)) {
						NSRange rootURLLocation = [downloadLink rangeOfString:[[NSBundle mainBundle] localizedStringForKey:@"store website" value:@"" table:@"Resources"]];
						downloadLink = [NSString stringWithFormat:@"%@%@",
										[[NSBundle mainBundle] localizedStringForKey:@"store website" value:@"" table:@"Resources"], 
										(rootURLLocation.location == NSNotFound)?downloadLink:[downloadLink substringWithRange:NSMakeRange(rootURLLocation.length, [downloadLink length] - rootURLLocation.length)]];
					}
					[downloadLinkArray addObject:downloadLink]; 
				}
				if (pageRange.location != NSNotFound && [downloadLinks length] >= pageRange.location + pageRange.length) {
					downloadLinks = [downloadLinks substringWithRange:NSMakeRange(pageRange.location + pageRange.length, [downloadLinks length] - (pageRange.location + pageRange.length))];
				} else if ([downloadLinks length] >= pageRange.length) {
					pageRange.location = NSNotFound;
				}
			}
			[returnDictionary setObject:[downloadLinkArray copy] forKey:@"Download Links"];
			[downloadLinkArray release];
			
			pageRange = [PPC_WebWangers getRangeInString:pageSource forTag:@"table"];
			NSString* tableData = (pageRange.location != NSNotFound)?[pageSource substringWithRange:pageRange]:@"";
			NSDictionary* tempDictionary = [self extractDataFromTable:tableData];
			if (tempDictionary && [[tempDictionary allKeys] count] > 0) {
				[returnDictionary addEntriesFromDictionary:tempDictionary];
			}
			
			pageRange = [PPC_WebWangers getRangeInString:pageSource forTag:@"div" withAttributeType:@"class" attribute:@"game-preview"];
			unsigned int start = pageRange.location + pageRange.length;
			if (pageRange.location != NSNotFound && [pageSource length] - start > 0) { // Need to turn HTML tags to NSAttributedString
				pageRange = NSMakeRange(start, [pageSource length] - start);
				NSString* descriptionData = [pageSource substringWithRange:pageRange];
				
				pageRange = [descriptionData rangeOfString:@"<strong>Compatibility</strong>" options:NSCaseInsensitiveSearch];
				descriptionData = (pageRange.location != NSNotFound)?[descriptionData substringWithRange:NSMakeRange(0, pageRange.location)]:descriptionData;
				
				[returnDictionary setObject:descriptionData forKey:@"Description"];
			}
			
			pageRange = [pageSource rangeOfString:@"<strong>Compatibility</strong>" options:NSCaseInsensitiveSearch]; //Should probably limit this to comments.
			NSMutableDictionary* compatibilityDictionary = [NSMutableDictionary new];
			NSMutableArray* cpuArray = [NSMutableArray new];
			NSString* versionNumber = @"";
			BOOL xCompatible = NO, classicCompatible = NO;
			if (pageRange.location != NSNotFound) {
				NSString* compatibilityData = [pageSource substringWithRange:NSMakeRange(pageRange.location, [pageSource length] - pageRange.location)];
				NSArray* processorTags = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"PowerPC",@"PPC",@"Power PC", nil],
										  [NSArray arrayWithObjects:@"68k",@"68000",@"68020",@"68030",@"68040", nil],
										  [NSArray arrayWithObjects:@"Intel",@"x64",@"x86", nil],
										  nil];
				NSArray* OSTags = [NSArray arrayWithObjects:@"System",@"MacOSX",@"Mac OS X",@"Mac OS",@"MacOS",@"OS X",@"OSX",@"Hypercard", nil ]; //check for number after MacOSX or System or MacOS
				for (int i = 0; i < [processorTags count]; i++) {
					for (int j = 0; j < [[processorTags objectAtIndex:i] count]; j++) {
						if ([compatibilityData rangeOfString:[[processorTags objectAtIndex:i] objectAtIndex:j]  options:NSCaseInsensitiveSearch].location != NSNotFound) {
							if (![cpuArray containsObject:[[processorTags objectAtIndex:i] objectAtIndex:0]]) {
								[cpuArray addObject:[[processorTags objectAtIndex:i] objectAtIndex:0]];
							}
						}
					}
				}
				
				for (int i = 0; i < [OSTags count]; i++) {
					NSRange osRange = [compatibilityData rangeOfString:[OSTags objectAtIndex:i] options:NSCaseInsensitiveSearch];
					if ((osRange.location != NSNotFound) && !versionNumber) {
						xCompatible = ([[OSTags objectAtIndex:i] rangeOfString:@"X" options:NSCaseInsensitiveSearch].location != NSNotFound)?YES:xCompatible;
						classicCompatible = ([[OSTags objectAtIndex:i] rangeOfString:@"X" options:NSCaseInsensitiveSearch].location == NSNotFound)?YES:classicCompatible;
						
						NSString* versionNumber = [compatibilityData substringWithRange:NSMakeRange(osRange.location + osRange.length + 1, [compatibilityData length] - (osRange.location + osRange.length + 1))]; // get version number
						NSRange osRange = [versionNumber rangeOfString:@" " options:NSCaseInsensitiveSearch];
						versionNumber = (osRange.location != NSNotFound)?[versionNumber substringWithRange:NSMakeRange(0, osRange.location)]:versionNumber;
						versionNumber = ([PPC_StringWangers stringIsNumber:versionNumber])?versionNumber:@"";
						
					}
				}
			}
			classicCompatible = (!classicCompatible && !xCompatible)?YES:classicCompatible; //dirty hack fix - if we aren't X compatible and we aren't classic compatible we must be classic compatible.
			[compatibilityDictionary setObject:[NSNumber numberWithBool:classicCompatible] forKey:@"Classic Compatible"];
			[compatibilityDictionary setObject:[NSNumber numberWithBool:xCompatible] forKey:@"X Compatible"];
			[compatibilityDictionary setObject:versionNumber forKey:@"Minimum Version"];
			[compatibilityDictionary setObject:[cpuArray copy] forKey:@"Supported Architectures"];
			
			[returnDictionary setObject:[compatibilityDictionary copy] forKey:@"Compatibility"];
			[cpuArray release];
			[compatibilityDictionary release];
		}
	}
	
	return [returnDictionary autorelease];
	[pool release];
}

@end
