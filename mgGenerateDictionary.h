//
//  mgGenerateDictionary.h
//  App Store PPC
//  Generate Dictionary for Macintosh Garden
//
//  Created by Administrator on 26/01/2019.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface mgGenerateDictionary : NSObject {
	@public NSMutableArray* applicationLibrary;
	@public BOOL terminate;
}

-(void)releaseObjects;
-(void)getLibrary;
-(NSDictionary*)getApplicationDetailsWithURL:(NSString*)pageURL;

@end
