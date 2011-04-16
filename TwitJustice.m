//
//  TwitJusticeAppDelegate.m
//  TwitJustice
//
//  Created by Krist Menina on 4/16/11.
//  Copyright 2011 Hello Wala Studios. All rights reserved.
//

#import "TwitJustice.h"

@implementation TwitJustice

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
}


- (id)statusItem
{
	if (_statusItem == nil)
	{
		
		NSImage *img;		
		
		img = [NSImage imageNamed:@"smile"];
		_statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
		[_statusItem setImage:img];
		[_statusItem setHighlightMode:YES];
		[_statusItem setEnabled:YES];
		
		
		[_statusItem setMenu:menuItemMenu];
		
		[img release];
		
		
		
	}
	return _statusItem;
}

- (void) actionQuit:(id)sender {
	[NSApp terminate:sender];
}

@end
