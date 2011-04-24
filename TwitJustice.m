//
//  TwitJustice.m
//  TwitJustice
//
//  Created by Krist Menina on 4/16/11.
//  Copyright 2011 Hello Wala Studios. All rights reserved.
//

#import "TwitJustice.h"
#import "TwitReader.h"

@interface TwitJustice(Private)
- (void) updateTwitSource:(NSArray *) favorites;
- (void) startTwitJustice:(NSString *)fpath;
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
	NSLog(@"Start TwitJustice");
	
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
	
	NSArray *favorites = [[NSArray alloc] initWithArray:[self getFavorites]];

	if([favorites count] > 0){
		[favRecords setArray:favorites];
		[favList reloadData];
		[self updateTwitSource:favorites];
	}
	
	if([[NSUserDefaults standardUserDefaults] stringForKey:@"twitSource"] != nil){
		[twitSource selectItemWithTitle:[[NSUserDefaults standardUserDefaults] stringForKey:@"twitSource"]];
	}
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

- (IBAction) addFavorite: (id) sender
{
	NSDictionary *fav = [NSDictionary dictionaryWithObjectsAndKeys:
						  [favName stringValue], @"username",
						  [favDescription stringValue], @"description",nil];		

	[favRecords addObject:fav];
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
	NSLog(@"set twit source %@",[sender titleOfSelectedItem]);
	[[NSUserDefaults standardUserDefaults] setValue:[sender titleOfSelectedItem] forKey:@"twitSource"];
}

- (void) selectedListeningTo: (id) sender
{
	NSLog(@"listen to %@",[sender title]);
	[[sender parentItem] setTitle:[sender title]];
	[sender setState:1];
}
- (id) getFavorites
{
	return [[NSUserDefaults standardUserDefaults] arrayForKey:@"favorites"];
}

- (void) updateTwitSource:(NSArray *) favorites
{
	NSLog(@"wti source %@",twitSource);
	[twitSource removeAllItems];		
	[twitSourceMenu removeAllItems];
	NSMutableString *twit_source = [[NSString alloc] init];
	for(int i=0; i<[favorites count]; i++){
		twit_source = [[favorites objectAtIndex:i] objectForKey:@"username"];
		NSLog(@"records %d %@",i,twit_source);
		[twitSource addItemWithTitle:twit_source];
		[twitSourceMenu addItemWithTitle:twit_source action:@selector(selectedListeningTo:) keyEquivalent:@""];
	}
	[twit_source release];
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
