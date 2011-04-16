//
//  TwitJusticeAppDelegate.m
//  TwitJustice
//
//  Created by Krist Menina on 4/16/11.
//  Copyright 2011 Hello Wala Studios. All rights reserved.
//

#import "TwitJustice.h"
#import "TwitReader.h"

@implementation TwitJustice

@synthesize window;

- (id) init {	
	self = [super init];
	queue = [[NSOperationQueue alloc] init];	
	
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	NSLog(@"Start TwitJustice");
	// Insert code here to initialize your application 
	NSNotificationCenter *center = [[NSWorkspace sharedWorkspace] notificationCenter];
	[center addObserver:self 
			   selector:@selector(machineDidWake:)
				   name:NSWorkspaceDidWakeNotification 
				 object:NULL];
	[center addObserver:self 
			   selector:@selector(machineWillSleep:)
				   name:NSWorkspaceWillSleepNotification 
				 object:NULL];		
	
	[queue cancelAllOperations];
	TwitReader* twitreader = [[TwitReader alloc] initWithRootPath:@"meow" operationClass:nil queue:queue];
	[queue addOperation: twitreader];
	[twitreader release];
	
}

- (void) machineWillSleep:(NSNotification *)notification{
	NSLog(@"TwitJustice sleep");
	/*[NSObject cancelPreviousPerformRequestsWithTarget: self
											 selector:@selector(startTwitJustice:)
											   object:fullPath];
	[queue cancelAllOperations];	
	[timer invalidate];
	[self setTimer:nil];*/	
}

- (void) machineDidWake:(NSNotification *)notification{
	NSLog(@"TwitJustice wake");
	
	/*[self performSelector: @selector(startTwitJustice:)
			   withObject:fullPath
			   afterDelay:[[NSUserDefaults standardUserDefaults] integerForKey:@"snapshotDelay"]];*/
}


- (id)statusItem
{
	if (_statusItem == nil)
	{
		
		NSImage *img;		
		
		img = [NSImage imageNamed:@"twitjustice"];
		_statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
		[_statusItem setImage:img];
		[_statusItem setHighlightMode:YES];
		[_statusItem setEnabled:YES];				
		[_statusItem setMenu:menuItemMenu];		
		//[img release];						
	}
	return _statusItem;
}

- (void) actionQuit:(id)sender {
	[NSApp terminate:sender];
}

@end
