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

		
	}
	//[favorites release];
	//[voices release];
	//[defaults release];
	
	[self startTwitJustice:@"starting"];

}

- (void) startTwitJustice:(NSString *)fpath{
	NSLog(@"starttwitjustice ");
	[queue cancelAllOperations];
	TwitReader* twitreader = [[TwitReader alloc] initWithData:@"meow" operationClass:nil queue:queue];
	[queue addOperation: twitreader];
	NSLog(@"release twitreader %@",twitreader);
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

-(void)twitNotification:(NSNotification*)aNotification
{
	NSLog(@"notification from twitreader %@",[aNotification name]);
	if ([[ aNotification name ] isEqualTo: @"NewTweet" ]) {
		NSLog(@"show new tweet");
		[radioTweet setStringValue:[[aNotification userInfo] objectForKey:@"message"]];
	}else if([[ aNotification name ] isEqualTo: @"TweetError" ]) {
		NSLog(@"error retrieving tweet");
		[radioTweet setStringValue:[[aNotification userInfo] objectForKey:@"message"]];		
	}else if ([[ aNotification name] isEqualTo:@"OkNet"]) {
		[statusInfo setTitle:[[aNotification userInfo] objectForKey:@"message"]];
	}else if ([[ aNotification name] isEqualTo:@"NoNet"]) {
		[statusInfo setTitle:[[aNotification userInfo] objectForKey:@"message"]];
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

//	[[twitSourceMenu itemWithTitle:listening_to_label] setState:0];
//		
	[[NSUserDefaults standardUserDefaults] setValue:[sender titleOfSelectedItem] forKey:@"twitSource"];
//	[[twitSourceMenu itemWithTitle:[sender titleOfSelectedItem]] setState:1];
	
	//update menu bar twit source label
	NSLog(@"update twit source in menu %@",[sender titleOfSelectedItem]);	
	[self performSelector:@selector(updateMenuTwitSource:) withObject:[sender titleOfSelectedItem]];
	
//	[listening_to_label release];
}

- (void) updateMenuTwitSource: (NSString *)username
{
	NSArray *favorites = [[[NSArray alloc] initWithArray:[self getFavorites]] autorelease];
	for(int i=0; i<[favorites count]; i++){
		[[twitSourceMenu itemWithTitle:[[favorites objectAtIndex:i] objectForKey:@"username"]] setState:0];
	}

	[twitSourceMenu setTitle:username];
	[[twitSourceMenu itemWithTitle:username] setState:1];
	
	//update preferences control
	//[twitSource selectItemWithTitle:[sender title]];
	[[NSUserDefaults standardUserDefaults] setValue:username forKey:@"twitSource"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	NSLog(@"new source %@",[[NSUserDefaults standardUserDefaults] stringForKey:@"twitSource"]);
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
	//NSString *currentTwitSource = [NSString stringWithString:[[NSUserDefaults standardUserDefaults] stringForKey:@"twitSource"]];
	NSMenuItem *menuItem;
	NSLog(@"favorites total %d",[favorites count]);
	for(int i=0; i<[favorites count]; i++){
		twit_source = [[favorites objectAtIndex:i] objectForKey:@"username"];
		NSLog(@"add to favorites %@",twit_source);
		// add to dropdown in General Preferences
		[twitSource addItemWithTitle:twit_source];
		//add to Menubar dropdown
		menuItem = [twitSourceMenu addItemWithTitle:twit_source action:@selector(selectedListeningTo:) keyEquivalent:@""];
		/*if([currentTwitSource isEqualToString:[menuItem title]]){
			[menuItem setState:YES];
		}*/


	}

	//[twit_source release];
	//[currentTwitSource release];
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

// window delegate

- (BOOL)windowShouldClose:(id)sender
{
	NSLog(@" window should close");
	[NSApp terminate:sender];
	return YES;
}

@end
