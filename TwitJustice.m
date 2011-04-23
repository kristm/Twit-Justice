//
//  TwitJustice.m
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
	favRecords = [[NSMutableArray alloc] init];
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	NSLog(@"Start TwitJustice");
	//[favList setDataSource:self];
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
	[center addObserver:self 
			   selector:@selector(machineWillShutDown:)
				   name:NSWorkspaceWillPowerOffNotification 
				 object:NULL];	
	
	[self startTwitJustice:@"starting"];
}

- (void) startTwitJustice:(NSString *)fpath{
	NSLog(@"starttwitjustice %@",fpath);
	[queue cancelAllOperations];
	TwitReader* twitreader = [[TwitReader alloc] initWithData:@"meow" operationClass:nil queue:queue];
	[queue addOperation: twitreader];
	[twitreader release];		
}

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

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	NSLog(@"table v2 protocol %@",[favRecords objectAtIndex:rowIndex]);
    id theRecord, theValue;
	
    theRecord = [favRecords objectAtIndex:rowIndex];
    theValue = [theRecord objectForKey:[aTableColumn identifier]];
    NSLog(@"table view %@",theValue);
    return theValue;
	
}

/*
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	NSLog(@"table view protocol %@",[favRecords objectAtIndex:rowIndex]);
	NSLog(@"col identifier %@",[aTableColumn identifier]);
	
    id theRecord, theValue;

    theRecord = [favRecords objectAtIndex:rowIndex];
    theValue = [theRecord objectForKey:[aTableColumn identifier]];
    NSLog(@"table view %@",theValue);
    return theValue;
	 

	//return [favRecords objectAtIndex:rowIndex];
}*/

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [favRecords count];
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

- (IBAction) addToFavorites: (id) sender
{
	
	NSLog(@"save to fav %@",sheetController);
	NSLog(@"fav name %@",[favName stringValue]);
	NSDictionary *fav = [NSDictionary dictionaryWithObjectsAndKeys:
						  [favName stringValue], @"username",
						  [favDescription stringValue], @"description",nil];		

	[favRecords addObject:fav];
	[favList reloadData];
	[sheetController closeSheet:sender];

}

- (void) dealloc
{
	NSLog(@"dealloc");
	[[NSStatusBar systemStatusBar] removeStatusItem:_statusItem];
	[_statusItem release];
	[queue release];
	queue = nil;
	[super dealloc];	
}

@end
