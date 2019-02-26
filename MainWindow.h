//
//  MainWindow.h
//  App Store PPC
//
//  Created by Administrator on 23/01/2019.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "mgGenerateDictionary.h"

#define animationFrames 30
#define labelHeight 22
#define contentHeight 100
#define labelFontSize 17.0
#define contentFontSize 12.0

@interface UIHelpers : NSObject
{
	
}
+(NSTextField*)createLabelWithFrame:(NSRect)frame;
+(NSDictionary*)attributesWithFontSize:(float)size andColour:(NSColor*)colour;
+(void)setString:(NSString*)string forLabel:(NSTextField*)label withAttributes:(NSDictionary*)attrs;

@end


@interface DetailView : NSView
{
	NSRect scrollviewFrameSize;
	IBOutlet NSScrollView* detailScrollView;
	IBOutlet NSTextField* titleField;
	IBOutlet NSTextField* classField;
	IBOutlet NSTextField* publisherField;
	IBOutlet NSView* ratingView;
	IBOutlet NSBox* horizontalLine1;
	IBOutlet NSTextField* previewLabel;
	IBOutlet NSScrollView* previewView;
	IBOutlet NSTextField* descriptionField;
	IBOutlet NSBox* horizontalLine2;
	IBOutlet NSTextField* reviewsLabel;
	IBOutlet NSScrollView* reviewsView;
	IBOutlet NSBox* horizontalLine3;
	IBOutlet NSTextField* moreByLabel;
	IBOutlet NSScrollView* moreByView;
	
}

- (float)resize;
- (void)updateDetails:(NSDictionary*)details initialUpdate:(BOOL)fullUpdate;

@end

@interface TaggableView : NSView
{
	NSImageView* imageView;
@private int tag;
}

- (void)setImage:(NSImage*)image;
- (void)setTag:(int)tag;
- (int)tag;

@end

@interface refreshLibraryThread : NSObject
{
	NSArray *libraryArray;
	//NSDictionary* detailPageDictionary;
	mgGenerateDictionary* macGarden;
}

-(void)refreshLibrary:(id)object;
-(NSArray*)getLibraryArray;

@end

@interface MainWindow : NSObject {
	NSString* tempSaveURL;
	NSArray *libraryArray;
	NSDate* then;
	NSTimer* updateImageTimer;
	
//	mgGenerateDictionary* macGarden;
	refreshLibraryThread *refreshThread;
	
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSWindow *refreshLibraryWindow;	
	IBOutlet NSView* masterView;
	IBOutlet NSProgressIndicator* refreshProgress;
	IBOutlet NSScrollView* collectionView;
	
	IBOutlet DetailView* detailView;
	
	
	
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender;

-(IBAction)refreshLibrary:(id)sender;
-(IBAction)endRefreshLibrary:(id)sender;
-(void)sheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo;
-(void)updateProgress:(id)object;

-(IBAction)dumpLibrary:(id)sender;
//-(IBAction)showPreferences:(id)sender;
-(void)buildCollectionView;
-(DetailView*)buildContentViewForItem:(NSDictionary*)item withFrame:(NSRect)frame;

@end
