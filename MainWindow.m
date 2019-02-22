//
//  MainWindow.m
//  App Store PPC
//
//  Created by Administrator on 23/01/2019.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import "MainWindow.h"
//#import "PPC-WebWangers.h"
//#import "PPC-DirectoryWangers.h"
//#import "mgGenerateDictionary.h"

@implementation TaggableView

- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
	if (self != nil) {
		imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0,75,frame.size.width, frame.size.height - 75)];
		[self addSubview:imageView];
	}
	return self;
}

- (void)dealloc {
	[imageView release];
	imageView = nil;
	
	[super dealloc];
}

- (void)setImage:(NSImage*)image {
	[imageView setImage:image];
}

- (void)mouseDown:(NSEvent *)theEvent {
	NSDictionary* senderDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:tag],@"tag",nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AnimateToDetailView" object:self userInfo:senderDictionary];
}

- (void)setTag:(int)ltag {
	tag = ltag;
}

- (int)tag {
	return tag;
}

@end

@implementation refreshLibraryThread

-(void)dealloc {
	if (libraryArray) {
		[libraryArray release];
		libraryArray = nil;
	}
/*	if (detailPageDictionary) {
		[detailPageDictionary release];
		detailPageDictionary = nil;
	}*/
	[macGarden release];
	macGarden = nil;
	
	[super dealloc];
}

-(void)refreshLibrary:(id)object {
	if (!macGarden) {
		macGarden = [[mgGenerateDictionary alloc] init];
	}
	macGarden->terminate = NO;
	@synchronized(libraryArray) { //make sure that we have exclusive use of the macGarden class
		[macGarden getLibrary];
		libraryArray = [[NSArray alloc] initWithArray:[(macGarden->applicationLibrary) copy]];
	}
	NSDictionary* progressDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:100],@"Progress",[NSNumber numberWithBool:YES],@"Finished",nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateRefreshProgress" object:self userInfo:progressDictionary];
}

-(void)getDetailPage:(id)object {
	NSString* pageURL = [object objectForKey:@"Application URL"];
	
	if (!macGarden) {
		macGarden = [[mgGenerateDictionary alloc] init];
	}
	NSDictionary* detailPageDictionary = [[NSDictionary alloc] initWithDictionary:[macGarden getApplicationDetailsWithURL:pageURL]]; //pageURL
	//post notifcation to update window
	[[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateDetailView" object:self userInfo:detailPageDictionary];
	
	[detailPageDictionary release];
}

-(void)cancelThread:(BOOL)cancel {
	macGarden->terminate = cancel;
}

-(NSArray*)getLibraryArray {
	return libraryArray;
}

@end


@implementation MainWindow

-(void)awakeFromNib {
	//	macGarden = [[mgGenerateDictionary alloc] init];
	//	[macGarden getLibrary];
	
	//library = macGarden->applicationLibrary;
	//	[library writeToFile:@"/testLibrary.plist" atomically:YES];
	libraryArray = [[NSArray alloc] initWithContentsOfFile:@"/fullLibrary.plist"]; // need to fix this to load from the right place
	/*	if (libraryArray) {
	 NSLog(@"%ld",[libraryArray count]);
	 }*/
	
	[[collectionView contentView] setPostsBoundsChangedNotifications:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boundsDidChange:) name:NSViewBoundsDidChangeNotification object:[collectionView contentView]]; //need to register for notifications when scrollview changes.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animateToDetailView:) name:@"AnimateToDetailView" object:nil];
	
	[self buildCollectionView]; // need to populate the collectionview now that we've loaded.
}

- (void)windowDidResize:(NSNotification *)notification {
	[self buildCollectionView];
}

#pragma mark refresh library

-(IBAction)refreshLibrary:(id)sender {
	[NSApp beginSheet:refreshLibraryWindow modalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
	refreshThread = [[refreshLibraryThread alloc] init];
	[NSThread detachNewThreadSelector:@selector(refreshLibrary:) toTarget:refreshThread withObject:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress:) name:@"UpdateRefreshProgress" object:nil];
}

-(IBAction)endRefreshLibrary:(id)sender {
	[refreshThread cancelThread:YES];
	
	NSArray* library = [refreshThread getLibraryArray];
	NSLog(@"Array Count is %ld", [library count]);
	[library writeToFile:@"/fullLibrary.plist" atomically:YES]; //need to fix this to save to the right place
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateRefreshProgress" object:nil];
	[refreshLibraryWindow orderOut:sender];
	[NSApp endSheet:refreshLibraryWindow returnCode:1];
	
	[refreshThread release];
}

-(void)sheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo {
}

-(void)updateProgress:(id)object {
	NSNumber* progress = [[object userInfo] valueForKey:@"Progress"];
	NSNumber* finishing = [[object userInfo] valueForKey:@"Finished"];
	[refreshProgress setDoubleValue:[progress doubleValue]];
	
	if ([finishing boolValue]) {
		[self endRefreshLibrary:self];
	}
}

-(IBAction)dumpLibrary:(id)sender {
	//[macGarden->applicationLibrary writeToFile:@"/testLibrary.plist" atomically:YES];
	
	//NSArray* library = [refreshThread getLibraryArray];
	
	//NSLog(@"Array Count is %ld", [library count]);
	//[library writeToFile:@"/testLibrary.plist" atomically:YES];
	
	[self buildCollectionView];
}

#pragma mark Build ScrollView

-(void)updateImages:(id)object {
	NSRect visibleRect = [collectionView documentVisibleRect];
	
	NSArray* subviews = [collectionView.documentView subviews];
	for (int i = 0; i < [subviews count]; i++) {
		if (NSIntersectsRect(visibleRect, [[subviews objectAtIndex:i]frame])) {
			//might need to move this to separate thread.
			NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[[libraryArray objectAtIndex:i] objectForKey:@"Application Image"]]];
			[[subviews objectAtIndex:i] setImage:image];
			[image release];
		}		
	}
}

-(void)boundsDidChange:(id)object {
	NSDate* now = [NSDate date];
	if (then) {
		NSTimeInterval secondsElapsed = [now timeIntervalSinceDate:then];
		if (secondsElapsed < 0.5) {
			if (updateImageTimer) {
				[updateImageTimer invalidate];
				updateImageTimer = nil;
			}
		}
		updateImageTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
															target:self
														  selector:@selector(updateImages:)
														  userInfo:nil
														   repeats:NO]; 
	} else {
		[self updateImages:nil];
	}
	then = [now copy]; 
}

-(NSTextField*)createLabelWithFrame:(NSRect)frame attributedString:(NSAttributedString*)string {
	NSTextField* label = [[NSTextField alloc] initWithFrame:frame]; //24 height of the field.
	[label setEditable:NO];
	[label setSelectable:NO];
	[label setBordered:NO];
	[label setDrawsBackground:NO];
	[label setAttributedStringValue:string];
	return [label autorelease];
}

-(NSView*)buildViewForItem:(NSDictionary*)item withFrame:(NSRect)frame withTag:(int)tag {
	// need to tag the view with the index into the array
	TaggableView* itemView = [[TaggableView alloc] initWithFrame:frame];
	
	NSAttributedString *attrsString = [[NSAttributedString alloc] initWithString:[item objectForKey:@"Application Name"] 
																	  attributes:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSFont systemFontOfSize:17.0],[NSColor blackColor], nil]
																											 forKeys:[NSArray arrayWithObjects:NSFontAttributeName,NSForegroundColorAttributeName, nil]]];
	NSTextField* titleLabel = [self createLabelWithFrame:NSMakeRect(0,50,frame.size.width, 24) attributedString:attrsString];
	[attrsString release];
	
	NSAttributedString *descAttrsString = [[NSAttributedString alloc] initWithString:[item objectForKey:@"Description"] 
																		  attributes:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSFont systemFontOfSize:12.0],[NSColor grayColor], nil]
																												 forKeys:[NSArray arrayWithObjects:NSFontAttributeName,NSForegroundColorAttributeName, nil]]];	
	NSTextField* descLabel = [self createLabelWithFrame:NSMakeRect(0,0,frame.size.width, 50) attributedString:descAttrsString];
	[descAttrsString release];
	
	[itemView addSubview:titleLabel];
	[itemView addSubview:descLabel];
	
	[itemView setTag:tag];
	
	return [itemView autorelease];
}
-(void)emptyView:(id)view {
	NSArray *viewsToRemove = [view subviews];
	
	for (int i = 0; i < [viewsToRemove count]; i++) {
		[[viewsToRemove objectAtIndex:i] removeFromSuperview];
	}
}

-(void)buildCollectionView {
	int viewWidth = 200, viewHeight = 200, spacing = 10, itemCount = 8;
	int columns = [collectionView frame].size.width / viewWidth;
	int rows = itemCount / columns;
	
	[self emptyView:collectionView.documentView];
	
	NSView* replacementView = [[NSView alloc] initWithFrame:NSMakeRect(0,0,[collectionView frame].size.width, rows*viewHeight)];
	
	for (int i = itemCount; i >= 0; --i) { //item count needs to be taken from the collectionview
		int itemColumn = i % columns;
		int itemRow = i / columns;
		int index = itemCount - i;
		
		NSDictionary* item = [libraryArray objectAtIndex:index];
		
		[replacementView addSubview:[self buildViewForItem:item 
												 withFrame:NSMakeRect((itemColumn * viewWidth) + (spacing / 2), 
																	  (itemRow * viewHeight) + (spacing / 2), 
																	  viewWidth - spacing, 
																	  viewHeight - spacing)
												   withTag:index]];
	}
	if (replacementView) {
		collectionView.documentView = replacementView;
	}
}

#pragma mark Build Content View

-(IBAction)returnToMainView:(id)sender {
	[masterView setFrame:NSMakeRect(-[[mainWindow contentView] frame].size.width, 0, [masterView frame].size.width, [masterView frame].size.height)];
	[masterView setHidden:NO];
	
	for (int i = 0; i <= [masterView frame].size.width; i+=[masterView frame].size.width / animationFrames) {
		[masterView setFrame:NSMakeRect(-[masterView frame].size.width + i, 0, [masterView frame].size.width, [masterView frame].size.height)];
		[detailView setFrame:NSMakeRect(i, 0, [masterView frame].size.width, [masterView frame].size.height)];
		[[mainWindow contentView] display];
		[masterView display];
		[detailView display];
	}
	[detailView removeFromSuperview];
	[detailView release];
}

-(void)animateToDetailView:(id)object {
	int tag = [[[object userInfo] valueForKey:@"tag"] intValue];
	NSLog(@"%@",[libraryArray objectAtIndex:tag]);
	
	detailView = [self buildContentViewForItem:[libraryArray objectAtIndex:tag] 
									 withFrame:NSMakeRect([masterView frame].size.width, 
														  0, 
														  [masterView frame].size.width, 
														  [masterView frame].size.height)]; //put dictionary into Item
	[[mainWindow contentView] addSubview:detailView];
	
	for (int i = 0; i <= [masterView frame].size.width; i+=[masterView frame].size.width / animationFrames) {
		[masterView setFrame:NSMakeRect(-i, 0, [masterView frame].size.width, [masterView frame].size.height)];
		[detailView setFrame:NSMakeRect([masterView frame].size.width - i, 0, [masterView frame].size.width, [masterView frame].size.height)];
		[[mainWindow contentView] display];
		[masterView display];
		[detailView display];
	}
	[masterView setHidden:YES];	
}

-(void)updateDetailView:(id)object {
	NSLog(@"Updating Detail View");
	
	[refreshThread release];
	refreshThread = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateDetailView" object:nil];
}

-(NSView*)buildContentViewForItem:(NSDictionary*)item withFrame:(NSRect)frame { //build item view here.
	
	refreshThread = [[refreshLibraryThread alloc] init];
	[NSThread detachNewThreadSelector:@selector(getDetailPage:) toTarget:refreshThread withObject:item];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDetailView:) name:@"UpdateDetailView" object:nil];
	
	NSView* newView = [[NSView alloc] initWithFrame:[[mainWindow contentView] frame]]; // may want to have a globally accessible view here.
	[newView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable|NSViewMinXMargin|NSViewMaxXMargin|NSViewMinYMargin|NSViewMaxYMargin];
	[newView setAutoresizesSubviews:YES];
	
	NSButton* backButton = [[NSButton alloc] initWithFrame:NSMakeRect(10, [newView frame].size.height - 30, 84, 27)];
	[backButton setAutoresizingMask:NSViewMinYMargin|NSViewMaxXMargin];
	[backButton setImage:[NSImage imageNamed:@"Back Button.png"]];
	[backButton setBordered:NO];
	[backButton setTarget:self];
    [backButton setAction:@selector(returnToMainView:)];
	[newView addSubview:backButton];
	
	[backButton release];
	
	//create ivars for images, description, download, ratings and reviews.  Add the ivars to the contentview here.
	
	return newView;
}

#pragma mark Experimentation
/*
-(IBAction)testAnimate:(id)sender {
	[self animateToDetailView:nil];
}*/

@end
