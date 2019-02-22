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

#define animationFrames 20

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
	IBOutlet NSView* detailView;
//	IBOutlet NSView* animateView2;
	IBOutlet NSProgressIndicator* refreshProgress;
	IBOutlet NSScrollView* collectionView;
	
}

-(IBAction)testAnimate:(id)sender;

-(IBAction)refreshLibrary:(id)sender;
-(IBAction)endRefreshLibrary:(id)sender;
-(void)sheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo;
-(void)updateProgress:(id)object;

-(IBAction)dumpLibrary:(id)sender;
//-(IBAction)showPreferences:(id)sender;
-(void)buildCollectionView;
-(NSView*)buildContentViewForItem:(NSDictionary*)item withFrame:(NSRect)frame;

@end
