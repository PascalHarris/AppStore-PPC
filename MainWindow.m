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

@implementation UIHelpers

+(NSTextField*)createLabelWithFrame:(NSRect)frame {
	NSTextField* label = [[NSTextField alloc] initWithFrame:frame]; //24 height of the field.
	[label setEditable:NO];
	[label setSelectable:NO];
	[label setBordered:NO];
	[label setDrawsBackground:NO];
	return label;
}

+(NSDictionary*)attributesWithFontSize:(float)size andColour:(NSColor*)colour {
	return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSFont systemFontOfSize:size],colour, nil] 
									   forKeys:[NSArray arrayWithObjects:NSFontAttributeName,NSForegroundColorAttributeName, nil]];
}

+(void)setString:(NSString*)string forLabel:(NSTextField*)label withAttributes:(NSDictionary*)attrs {
	NSAttributedString* attrsString = [[NSAttributedString alloc] initWithString:string 
																	  attributes:attrs];
	[label setAttributedStringValue:attrsString];
	[attrsString release];
	attrsString = nil;
}

@end


@implementation DetailView

-(void)boundsDidChange:(id)object {
	NSRect detailViewSize = NSMakeRect(0, 0, [self frame].size.width, [detailScrollView.documentView frame].size.height);
	[detailScrollView.documentView setFrame:detailViewSize];
	[detailScrollView setNeedsDisplay:YES];
}

- (NSView*)createDetailView {
	NSRect detailViewSize = NSMakeRect(0, 0, scrollviewFrameSize.size.width, 2000); //will be shrinking the vertical size in due course
	NSView* returnView = [[NSView alloc] initWithFrame:detailViewSize];
	
	NSArray* fields = [NSArray arrayWithObjects:titleField = [UIHelpers createLabelWithFrame:NSMakeRect(20, 20, scrollviewFrameSize.size.width - 40, 30)],
					   classField = [UIHelpers createLabelWithFrame:NSMakeRect(20, 20, scrollviewFrameSize.size.width - 40, 17)],
					   publisherField = [UIHelpers createLabelWithFrame:NSMakeRect(20, 20, scrollviewFrameSize.size.width - 40, 17)],
					   previewLabel = [UIHelpers createLabelWithFrame:NSMakeRect(20, 20, scrollviewFrameSize.size.width - 40, labelHeight)],
					   descriptionField = [UIHelpers createLabelWithFrame:NSMakeRect(20, 20, scrollviewFrameSize.size.width - 40, contentHeight * 2)],
					   reviewsLabel = [UIHelpers createLabelWithFrame:NSMakeRect(20, 20, scrollviewFrameSize.size.width - 40, labelHeight)],
					   moreByLabel = [UIHelpers createLabelWithFrame:NSMakeRect(20, 20, scrollviewFrameSize.size.width - 40, labelHeight)],nil];
	for (int i = 0; i < [fields count]; i++) {
		[[fields objectAtIndex:i] setAutoresizingMask:NSViewWidthSizable];
		[returnView addSubview:[fields objectAtIndex:i]];			
	}
	
	NSArray* separators = [NSArray arrayWithObjects:horizontalLine1 = [[NSBox alloc] initWithFrame:NSMakeRect(10, 20, scrollviewFrameSize.size.width - 40, 1)],
						   horizontalLine2 = [[NSBox alloc] initWithFrame:NSMakeRect(10, 20, scrollviewFrameSize.size.width - 40, 1)],
						   horizontalLine3 = [[NSBox alloc] initWithFrame:NSMakeRect(10, 20, scrollviewFrameSize.size.width - 40, 1)],nil];
	for (int i = 0; i < [separators count]; i++) {
		[[separators objectAtIndex:i] setAutoresizingMask:NSViewWidthSizable];
		[[separators objectAtIndex:i] setBoxType:NSBoxSeparator];
		[returnView addSubview:[separators objectAtIndex:i]];
	}
	
	NSArray* scrollviews = [NSArray arrayWithObjects:previewView = [[NSScrollView alloc] initWithFrame:NSMakeRect(10, 20, scrollviewFrameSize.size.width - 40, contentHeight * 3)],
							reviewsView = [[NSScrollView alloc] initWithFrame:NSMakeRect(10, 20, scrollviewFrameSize.size.width - 40, contentHeight * 2)],
							moreByView = [[NSScrollView alloc] initWithFrame:NSMakeRect(10, 20, scrollviewFrameSize.size.width - 40, contentHeight * 2)],nil];
	for (int i = 0; i < [scrollviews count]; i++) {
		[[scrollviews objectAtIndex:i] setAutoresizingMask:NSViewWidthSizable|NSViewMinXMargin|NSViewMaxXMargin];
		[returnView addSubview:[scrollviews objectAtIndex:i]];
	}
	[previewView setHasHorizontalScroller:YES];
	[moreByView setHasHorizontalScroller:YES];
	[reviewsView setHasVerticalScroller:YES];
	
	ratingView = [[NSView alloc] initWithFrame:NSMakeRect(10, 20, scrollviewFrameSize.size.width - 40, labelHeight)];
	[returnView addSubview:ratingView];
	
	unsigned height = [self resize];
	detailViewSize = NSMakeRect(0, 0, scrollviewFrameSize.size.width, height + 10);
	[returnView setFrame:detailViewSize];
	
	return returnView;// autorelease];
	
}

- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
	if (self != nil) {
		[self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable|NSViewMinXMargin|NSViewMaxXMargin|NSViewMinYMargin|NSViewMaxYMargin];
		[self setAutoresizesSubviews:YES];
		
		scrollviewFrameSize = NSMakeRect(0, 0, frame.size.width, frame.size.height-50);
		detailScrollView = [[NSScrollView alloc] initWithFrame:scrollviewFrameSize];
		[detailScrollView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable|NSViewMinXMargin|NSViewMaxXMargin|NSViewMinYMargin];
		[detailScrollView setHasVerticalScroller:YES];
		[detailScrollView setDrawsBackground:NO];
		[[detailScrollView contentView] setPostsBoundsChangedNotifications:YES];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boundsDidChange:) name:NSViewBoundsDidChangeNotification object:[detailScrollView contentView]]; //need to register for notifications when scrollview changes.

		[self addSubview:detailScrollView];
		
		NSView* documentView = [self createDetailView];
		if (documentView) {
			[detailScrollView setDocumentView:documentView];
			NSPoint pt = NSMakePoint(0.0, [detailScrollView.documentView bounds].size.height);
			[detailScrollView.documentView scrollPoint:pt];
		}
		
	}
	return self;
}

- (void)dealloc {
	NSArray* fields = [NSArray arrayWithObjects:moreByView,moreByLabel,horizontalLine3,reviewsView,reviewsLabel,horizontalLine2,descriptionField,previewView,previewLabel,horizontalLine1,ratingView,publisherField,classField,titleField,nil];
	for (int i = 0; i < [fields count]; i++) {
		id field = [fields objectAtIndex:i];
		[field release];
		field = nil;
	}
	[super dealloc];
}

- (float)resize {
	float nextposition = 0;
	NSRect frame;
	
	NSArray* fields = [NSArray arrayWithObjects:moreByView,moreByLabel,horizontalLine3,reviewsView,reviewsLabel,horizontalLine2,descriptionField,previewView,previewLabel,horizontalLine1,ratingView,publisherField,classField,titleField,nil];
	for (int i = 0; i < [fields count]; i++) {
		id field = [fields objectAtIndex:i];
		if (field) {

			nextposition = nextposition + frame.size.height + 10;
			frame = [field frame];
			if ([field isKindOfClass:[NSBox class]]) {
				nextposition = nextposition + 5;
			}
			frame.size.width = [self frame].size.width - 40;
			frame.origin.y = nextposition;
			[field setFrame:frame];
		}
	}
	nextposition = nextposition + frame.size.height + 10;
	
	return nextposition;
}

-(void)displayDescriptionFieldString:(id)object {
	NSAttributedString* descriptionString = [[NSAttributedString alloc] initWithHTML:[object dataUsingEncoding:NSUnicodeStringEncoding] documentAttributes:nil];
	[descriptionField setAttributedStringValue:descriptionString];
	[descriptionString release];
}

-(void)populatePreviewView:(id)object {
	int imageViewLocation = 10;
	NSView* imageView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 2000, [previewView frame].size.height)];
	for (int i = 0; i < [object count]; i++) {
		NSURL* imgURL = [[NSURL alloc] initWithString:[object objectAtIndex:i]];
		NSImage *thisImage = [[NSImage alloc] initWithContentsOfURL:imgURL];
		if (thisImage && [thisImage size].width > 10) {
			NSImageView* previewImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(imageViewLocation,10,[imageView frame].size.height * 1.25, [imageView frame].size.height - 30)];
			[previewImageView setImage:[thisImage copy]];
			[imageView addSubview:previewImageView];
			imageViewLocation+=([previewImageView frame].size.width + 10);
			[previewImageView release];
			[thisImage release];
		}
		[imgURL release];
	}
	[imageView setFrame:NSMakeRect(0, 0, imageViewLocation+10, [previewView frame].size.height)];
	[previewView setDocumentView:imageView];
}

- (void)updateDetails:(NSDictionary*)details initialUpdate:(BOOL)fullUpdate {
	if (fullUpdate) {
		[UIHelpers setString:[details objectForKey:@"Application Name"] 
					forLabel:titleField 
			  withAttributes:[UIHelpers attributesWithFontSize:22.0 andColour:[NSColor blackColor]]];
		
		[UIHelpers setString:[details objectForKey:@"Category"] 
					forLabel:classField 
			  withAttributes:[UIHelpers attributesWithFontSize:contentFontSize andColour:[NSColor grayColor]]];
		
		[UIHelpers setString:[details objectForKey:@"Author"] 
					forLabel:publisherField 
			  withAttributes:[UIHelpers attributesWithFontSize:contentFontSize andColour:[NSColor blueColor]]];
		
		[UIHelpers setString:@"Preview" 
					forLabel:previewLabel 
			  withAttributes:[UIHelpers attributesWithFontSize:labelFontSize andColour:[NSColor blackColor]]];
		
		[UIHelpers setString:@"Reviews" 
					forLabel:reviewsLabel 
			  withAttributes:[UIHelpers attributesWithFontSize:labelFontSize andColour:[NSColor blackColor]]];
		
		[UIHelpers setString:[NSString stringWithFormat:@"More By %@", [details objectForKey:@"Author"]]
					forLabel:moreByLabel 
			  withAttributes:[UIHelpers attributesWithFontSize:labelFontSize andColour:[NSColor blackColor]]];
	}
	
	if ([details objectForKey:@"Description"] && [[details objectForKey:@"Description"] length] > 0) {
		[self performSelectorOnMainThread:@selector(displayDescriptionFieldString:) withObject:[details objectForKey:@"Description"] waitUntilDone:YES];
	}
	
	if ([details objectForKey:@"Image Links"] && [[details objectForKey:@"Image Links"] count] > 0) {
		[self performSelectorOnMainThread:@selector(populatePreviewView:) withObject:[details objectForKey:@"Image Links"] waitUntilDone:YES];
	}
}

@end


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
	NSPoint pt = NSMakePoint(0.0, [collectionView.documentView bounds].size.height);
	[collectionView.documentView scrollPoint:pt];
}

- (void)windowDidResize:(NSNotification *)notification {
	[self buildCollectionView];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender {
	return YES;
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

-(NSView*)buildViewForItem:(NSDictionary*)item withFrame:(NSRect)frame withTag:(int)tag {
	// need to tag the view with the index into the array
	TaggableView* itemView = [[TaggableView alloc] initWithFrame:frame];
	
	NSTextField* titleLabel = [UIHelpers createLabelWithFrame:NSMakeRect(0,50,frame.size.width, 24)];
	[UIHelpers setString:[item objectForKey:@"Application Name"] 
				forLabel:titleLabel 
		  withAttributes:[UIHelpers attributesWithFontSize:labelFontSize andColour:[NSColor blackColor]]];
	
	NSTextField* descLabel = [UIHelpers createLabelWithFrame:NSMakeRect(0,0,frame.size.width, 50)];
	[UIHelpers setString:[item objectForKey:@"Description"] 
				forLabel:descLabel 
		  withAttributes:[UIHelpers attributesWithFontSize:contentFontSize andColour:[NSColor grayColor]]];
	
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
	int rows = ceil(itemCount / columns);
	int collectionViewHeight = rows * viewHeight;
	collectionViewHeight = collectionViewHeight > [collectionView frame].size.height?collectionViewHeight:[collectionView frame].size.height;
	
	[self emptyView:collectionView.documentView];	
	NSView* replacementView = [[NSView alloc] initWithFrame:NSMakeRect(0,0,[collectionView frame].size.width, collectionViewHeight)];
	
	for (int i = 0; i < itemCount; i++) { //item count needs to be taken from the collectionview
		int itemColumn = i % columns;
		int itemRow = (i / columns) + 1;
		
		NSDictionary* item = [libraryArray objectAtIndex:i];
		
		[replacementView addSubview:[self buildViewForItem:item 
												 withFrame:NSMakeRect((itemColumn * viewWidth) + (spacing / 2), 
																	  collectionViewHeight - ((itemRow * viewHeight) + (spacing / 2)), 
																	  viewWidth - spacing, 
																	  viewHeight - spacing)
												   withTag:i]];
	}
	if (replacementView) {
		collectionView.documentView = replacementView;
		[replacementView release];
	}
	
}

#pragma mark Build Content View

-(void)swapView:(NSView*)oldView toView:(NSView*)newView movingIn:(BOOL)movingIn {
	NSImageView* oldImageView = [[NSImageView alloc] initWithFrame:[oldView frame]];
	[oldView lockFocus];
	NSBitmapImageRep * oldViewBitmap = [[[NSBitmapImageRep alloc] initWithFocusedViewRect:[oldView bounds]] autorelease];
	NSImage *oldViewImage = [[[NSImage alloc] init] autorelease];
	[oldViewImage addRepresentation:oldViewBitmap];
	[oldImageView setImage:oldViewImage];
	[oldView unlockFocus];
	[[mainWindow contentView] addSubview:oldImageView];
	[oldView setHidden:YES];
	
	NSImageView* newImageView = [[NSImageView alloc] initWithFrame:[newView frame]];
	[newView lockFocus];
	NSImage *newViewImage = [[NSImage alloc] initWithData:[newView dataWithPDFInsideRect:[newView bounds]]];
	
	[newImageView setImage:newViewImage];
	[newView unlockFocus];
	[[mainWindow contentView] addSubview:newImageView];
	[newView setHidden:YES];
	
	for (int i = 0; i <= [oldImageView frame].size.width; i+=[oldImageView frame].size.width / animationFrames) {
		int newViewMove = movingIn?[oldImageView frame].size.width - i:0 - [oldImageView frame].size.width + i;
		int oldViewMove = movingIn?0 - i:i;
		[oldImageView setFrame:NSMakeRect(oldViewMove, 0, [oldImageView frame].size.width, [oldImageView frame].size.height)];
		[newImageView setFrame:NSMakeRect(newViewMove, 0, [oldImageView frame].size.width, [oldImageView frame].size.height)];
		[[mainWindow contentView] display];
		[oldImageView display];
		[newImageView display];
	}
	[newView setFrame:[oldView frame]];
	[newView setHidden:NO];
	[oldImageView removeFromSuperview];
	[oldImageView release];
	[newImageView removeFromSuperview];
	[newImageView release];	
}

-(IBAction)returnToMainView:(id)sender {
	[masterView setFrame:NSMakeRect(-[[mainWindow contentView] frame].size.width, 0, [masterView frame].size.width, [masterView frame].size.height)];
	[masterView setHidden:NO];
	
	[self swapView:detailView toView:masterView movingIn:NO];
	
	[detailView removeFromSuperview];
	[detailView release];
}

-(void)animateToDetailView:(id)object {
	int tag = [[[object userInfo] valueForKey:@"tag"] intValue];
	
	detailView = [self buildContentViewForItem:[libraryArray objectAtIndex:tag] 
									 withFrame:NSMakeRect([masterView frame].size.width, 
														  0, 
														  [masterView frame].size.width, 
														  [masterView frame].size.height)]; //put dictionary into Item
	[detailView updateDetails:[libraryArray objectAtIndex:tag] initialUpdate:YES];
	[[mainWindow contentView] addSubview:detailView];
	
	[self swapView:masterView toView:detailView movingIn:YES];
}

-(void)updateDetailView:(id)object {
	[refreshThread release];
	refreshThread = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateDetailView" object:nil];
	
	[detailView updateDetails:[object userInfo] initialUpdate:NO];
//	NSLog(@"%@",[object userInfo]);
}

-(DetailView*)buildContentViewForItem:(NSDictionary*)item withFrame:(NSRect)frame { //build item view here.
	
	refreshThread = [[refreshLibraryThread alloc] init];
	[NSThread detachNewThreadSelector:@selector(getDetailPage:) toTarget:refreshThread withObject:item];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDetailView:) name:@"UpdateDetailView" object:nil];
	
	DetailView* newView = [[DetailView alloc] initWithFrame:[[mainWindow contentView] frame]]; // may want to have a globally accessible view here.
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

@end
