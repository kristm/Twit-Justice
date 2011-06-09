//
//  TwitJustice.m
//  TwitJustice
//
//  This code is free software; you can redistribute it and/or modify it under
//  the terms of the new BSD License.
//
//  Created by Krist Menina on 4/16/11.
//  Copyright 2011 Hello Wala Studios. All rights reserved.
//

#import "TwitJustice.h"
#import "TwitReader.h"
#import "ImageFetcher.h"
#import "NSWindow_Flipr.h"

@interface TwitJustice(Private)
- (void) updateTwitSource:(NSArray *) favorites;
- (void) startTwitJustice:(NSString *)fpath;
- (BOOL) isValidVoice:(NSString *)voice;

@end

@implementation TwitJustice

@synthesize window;

- (id) init {	
	self = [super init];
	queue = [[NSOperationQueue alloc] init];	
	favRecords = [[NSMutableArray alloc] init];
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	NSLog(@"TwitJustice app loaded");
	
	NSNotificationCenter *center = [[NSWorkspace sharedWorkspace] notificationCenter];
	[center addObserver:self 
			   selector:@selector(machineDidWake:)
				   name:NSWorkspaceDidWakeNotification 
				 object:NULL];
	[center addObserver:self 
			   selector:@selector(machineWillSleep:)
				   name:NSWorkspaceWillSleepNotification 
				 object:NULL];	
	[center addObserver:self 
			   selector:@selector(machineWillShutDown:)
				   name:NSWorkspaceWillPowerOffNotification 
				 object:NULL];	
	
    [[ NSDistributedNotificationCenter defaultCenter ] addObserver: self
														  selector: @selector(twitNotification:)
															  name: nil
															object: @"TwitReader"
												suspensionBehavior: NSNotificationSuspensionBehaviorCoalesce
	 ];
	
	NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:10],@"tjInterval", 
							  [NSString stringWithString:@"Alex"],@"voice",nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults: defaults];	

	NSArray *voices = [NSSpeechSynthesizer availableVoices];
	NSString *shortname = [[NSString alloc] autorelease];
	if([voices count] > 0){
		for(NSString *voice in voices){
			shortname = [voice substringFromIndex:33];
			if([self isValidVoice:shortname]){
				[voicesSource addItemWithTitle:shortname];
				//NSLog(@"voice %@",[voice substringFromIndex:33]);
			}
				
		}
		[voicesSource selectItemWithTitle:[[NSUserDefaults standardUserDefaults] stringForKey:@"voice"]];
	}
	NSArray *favorites = [[[NSArray alloc] initWithArray:[self getFavorites]] autorelease]; 

	if([favorites count] > 0){
		[favRecords setArray:favorites];
		[favList reloadData];
		[self updateTwitSource:favorites];
		
		//get last used twit source
		if([[NSUserDefaults standardUserDefaults] stringForKey:@"twitSource"] != nil){
			[twitSource selectItemWithTitle:[[NSUserDefaults standardUserDefaults] stringForKey:@"twitSource"]];
			[self performSelector:@selector(updateMenuTwitSource:) withObject:[[NSUserDefaults standardUserDefaults] stringForKey:@"twitSource"]];			
		}

		
	}else if([self getFavorites] == nil){
		// use default twitter feeds
		NSLog(@"use default twitter feeds");		
		NSDictionary *default_twits = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"twitjustice-defaults" ofType:@"plist"]];
		NSArray *default_favorites = [default_twits valueForKey:@"defaults"];
		[favRecords setArray:default_favorites];
		[favList reloadData];
		[self updateTwitSource:default_favorites];
		
		NSLog(@"default firt value %@",[[default_favorites objectAtIndex:0] valueForKey:@"username"]);
		NSString *first_twit = [[NSString alloc] autorelease];
		first_twit = [[default_favorites objectAtIndex:0] valueForKey:@"username"];
		[twitSource selectItemWithTitle:first_twit];
		[self performSelector:@selector(updateMenuTwitSource:) withObject:first_twit];		
		[[NSUserDefaults standardUserDefaults] setValue:favRecords forKey:@"favorites"];
	}

	[NSWindow flippingWindow];
	[self startTwitJustice:@"starting"];

}

- (void) startTwitJustice:(NSString *)fpath{
	NSLog(@"starttwitjustice ");
	[queue cancelAllOperations];
	TwitReader* twitreader = [[TwitReader alloc] initWithData:@"meow" operationClass:nil queue:queue imageThumb:radioThumb];
	[queue addOperation: twitreader];
	NSLog(@"release twitreader %@",twitreader);
	[twitreader release];		
	if([[NSUserDefaults standardUserDefaults] stringForKey:@"lastTweet"] != nil){
		[radioTweet setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"lastTweet"]];
	}
} 


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    id theRecord, theValue;
	
    theRecord = [favRecords objectAtIndex:rowIndex];
    theValue = [theRecord objectForKey:[aTableColumn identifier]];

    return theValue;
	
}


- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [favRecords count];
}

- (id)statusItem
{
	if (_statusItem == nil)
	{
		NSImage *img,*alt_img;				
		img = [NSImage imageNamed:@"twitjustice"];
		alt_img = [NSImage imageNamed:@"twitjustice_alt"];
		_statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
		[_statusItem setImage:img];
		[_statusItem setAlternateImage:alt_img];
		[_statusItem setHighlightMode:YES];
		[_statusItem setEnabled:YES];				
		[_statusItem setMenu:menuItemMenu];		
	}
	return _statusItem;
}

- (IBAction) prefWindowController: (id) sender
{
	[prefWindow setLevel:NSStatusWindowLevel];
	[prefWindow makeKeyAndOrderFront:nil];
	[prefWindow center];	
}

- (IBAction) openFavoritesSheet: (id) sender
{
	[favName setStringValue:@""];
	[favDescription setStringValue:@""];	
	[sheetController openSheet:sender];
}

- (IBAction) addFavorite: (id) sender
{
	[favRecords addObject:[NSDictionary dictionaryWithObjectsAndKeys:
						   [favName stringValue], @"username",
						   [favDescription stringValue], @"description",nil]];
	[favList reloadData];
	[sheetController closeSheet:sender];
	[[NSUserDefaults standardUserDefaults] setValue:favRecords forKey:@"favorites"];
	[self updateTwitSource:favRecords];	

}

- (IBAction) removeFavorite: (id) sender
{
	NSInteger selectedRow = [favList selectedRow];
	
	if(selectedRow != -1){
		[favRecords removeObjectAtIndex:selectedRow];
		[favList reloadData];
		[[NSUserDefaults standardUserDefaults] setValue:favRecords forKey:@"favorites"];		
		[self updateTwitSource:favRecords];
	}
}


- (IBAction) selectedTwitSource: (id) sender
{
	NSString *listening_to_label = [[[NSString alloc] init] autorelease];
	listening_to_label = [[NSUserDefaults standardUserDefaults] stringForKey:@"twitSource"];

	[[NSUserDefaults standardUserDefaults] setValue:[sender titleOfSelectedItem] forKey:@"twitSource"];
	
	//update menu bar twit source label
	NSLog(@"update twit source in menu %@",[sender titleOfSelectedItem]);	
	[self performSelector:@selector(updateMenuTwitSource:) withObject:[sender titleOfSelectedItem]];
}

- (void) updateMenuTwitSource: (NSString *)username
{
	NSArray *favorites = [[[NSArray alloc] initWithArray:[self getFavorites]] autorelease];
	for(int i=0; i<[favorites count]; i++){
		[[twitSourceMenu itemWithTitle:[[favorites objectAtIndex:i] objectForKey:@"username"]] setState:0];
	}

	[twitSourceMenu setTitle:username];
	[[twitSourceMenu itemWithTitle:username] setState:1];
	[radioTweetSource setStringValue:username];
	
	//reset tweet message
	[radioTweet setStringValue:@"waiting for next tweet"];
	
	//update preferences control
	[[NSUserDefaults standardUserDefaults] setValue:username forKey:@"twitSource"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	NSLog(@"new source %@",[[NSUserDefaults standardUserDefaults] stringForKey:@"twitSource"]);
	
	ImageFetcher* imgFetch = [[ImageFetcher alloc] init:radioThumb];
	[queue addOperation:imgFetch];
	[imgFetch release];
	
	
}

- (void) selectedListeningTo:(id)sender
{
	//NSLog(@"update twitsource from menubar %@",sender);
	[self performSelector:@selector(updateMenuTwitSource:) withObject:[sender title]];
}

- (id) getFavorites
{
	return [[NSUserDefaults standardUserDefaults] arrayForKey:@"favorites"];
}

- (void) updateTwitSource:(NSArray *) favorites
{
	NSLog(@"update twit model");
	
	[twitSource removeAllItems];		
	[twitSourceMenu removeAllItems];
	NSMutableString *twit_source = [[NSString alloc] init];
	NSMenuItem *menuItem;
	NSLog(@"favorites total %d",[favorites count]);
	for(int i=0; i<[favorites count]; i++){
		twit_source = [[favorites objectAtIndex:i] objectForKey:@"username"];
		NSLog(@"add to favorites %@",twit_source);
		// add to dropdown in General Preferences
		[twitSource addItemWithTitle:twit_source];
		//add to Menubar dropdown
		menuItem = [twitSourceMenu addItemWithTitle:twit_source action:@selector(selectedListeningTo:) keyEquivalent:@""];

	}

}

- (IBAction) setVoice:(id) sender
{
	NSLog(@"set voice %@",[sender title]);
	[[NSUserDefaults standardUserDefaults] setValue:[sender titleOfSelectedItem] forKey:@"voice"];
}

- (BOOL) isValidVoice:(NSString *)voice
{
	//NSLog(@"is valid %@",voice);
	return [voice isEqualToString:@"Agnes"] || [voice isEqualToString:@"Alex"] || [voice isEqualToString:@"Bruce"] || 
			[voice isEqualToString:@"Fred"] || [voice isEqualToString:@"Kathy"] || [voice isEqualToString:@"Princess"] || 
			[voice isEqualToString:@"Ralph"] || [voice isEqualToString:@"Vicki"] || [voice isEqualToString:@"Victoria"];
}

- (void) dealloc
{
	NSLog(@"dealloc twitjustice %@",self);
	[[NSStatusBar systemStatusBar] removeStatusItem:_statusItem];
	[_statusItem release];
	[queue release];
	queue = nil;
	[favList release];
	[super dealloc];	
}

#pragma mark notifications

- (void) machineWillSleep:(NSNotification *)notification{
	NSLog(@"TwitJustice sleep");
	[queue cancelAllOperations];	
	
}

- (void) machineWillShutDown: (NSNotification *)notification{
	NSLog(@"shutdown detected");
	[queue cancelAllOperations];
}

- (void) machineDidWake:(NSNotification *)notification{
	NSLog(@"TwitJustice wake");	
	[self performSelector: @selector(startTwitJustice:)
			   withObject:@"start from wake"
			   afterDelay:[[NSUserDefaults standardUserDefaults] integerForKey:@"snapshotDelay"]];
}

-(void)twitNotification:(NSNotification*)aNotification
{
	NSLog(@"notification from twitreader %@",[aNotification name]);
	if ([[ aNotification name ] isEqualTo: @"NewTweet" ]) {
		NSLog(@"show new tweet");
		[radioTweet setStringValue:[[aNotification userInfo] objectForKey:@"message"]];
		[radioTweet display];
	}else if([[ aNotification name ] isEqualTo: @"TweetError" ]) {
		NSLog(@"error retrieving tweet");
		[radioTweet setStringValue:[[aNotification userInfo] objectForKey:@"message"]];		
		[radioTweet display];
	}else if ([[ aNotification name] isEqualTo:@"OkNet"]) {
		[statusInfo setTitle:[[aNotification userInfo] objectForKey:@"message"]];
	}else if ([[ aNotification name] isEqualTo:@"NoNet"]) {
		[statusInfo setTitle:[[aNotification userInfo] objectForKey:@"message"]];
	}
}

#pragma mark Flipping Delegates
// This action method is connected to the two "Flip" buttons.
// In order to capture the buttons in the unhighlighted state, we do a delayed perform on the appropriate method.

- (IBAction)flipAction:(id)sender {
	[self performSelector:[NSApp keyWindow]==window?@selector(flipForward):@selector(flipBackward) withObject:nil afterDelay:0.0];
}

// These flip forward and backward. In the nib file, window1 is set as visible at load time, window2 not.

- (void)flipForward {
	[window flipToShowWindow:radioBack forward:YES];
}

- (void)flipBackward {
	[radioBack flipToShowWindow:window forward:NO];
}

// window delegate
#pragma mark Window Delegates

- (BOOL)windowShouldClose:(id)sender
{
	NSLog(@" window should close");
	[NSApp terminate:sender];
	return YES;
}

- (void) awakeFromNib
{
	
	//[radioBack setBackgroundColor:[NSColor orangeColor]];
	NSSize backgroundSize = [radioBack frame].size; NSImage *backgroundImage = [[NSImage alloc] initWithSize:backgroundSize];		NSRect backgroundRect = NSMakeRect(0,0,[backgroundImage size].width, [backgroundImage size].height);
	// Load whatever object will be in the center into an NSImage.
	NSImage *objectImage = [NSImage imageNamed:@"twitui_back"];
	// Find the point at which to draw the object.
	NSPoint backgroundCenter; backgroundCenter.x = backgroundRect.size.width / 2; backgroundCenter.y = backgroundRect.size.height / 2;
	NSPoint drawPoint = backgroundCenter; drawPoint.x -= [objectImage size].width / 2; drawPoint.y -= [objectImage size].height / 2;
	// Fill the background with a color and draw the object on top of it.
	[backgroundImage lockFocus]; [[NSColor whiteColor] set]; NSRectFill(backgroundRect); [objectImage drawAtPoint:drawPoint
																										 fromRect:NSZeroRect operation:NSCompositeSourceOver
																										 fraction:1.0];			
	[backgroundImage unlockFocus];
	// Set our background image as the window's background color.
	[radioBack setBackgroundColor: [NSColor colorWithPatternImage:backgroundImage]];
	// Release the image.
	[backgroundImage release];
}

- (IBAction) aboutWindowController: (id) sender
{
	[aboutWindow setLevel:NSStatusWindowLevel];
	[aboutWindow makeKeyAndOrderFront:nil];
	[aboutWindow center];
}

- (NSString *)versionString
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSDictionary *infoDict = [mainBundle infoDictionary];
	
    NSString *subString = [infoDict valueForKey:@"CFBundleVersion"];
	return [NSString stringWithFormat:@"Version %@", subString];
}

- (NSString*)copyrightString
{
    return @"Copyright © 2011 \nKrist Menina\nkrist@hellowala.org";
}

- (float)appNameLabelFontSize
{
    return 16.0;
}

@end
