//
//  TwitJustice.h
//  TwitJustice
//
//  This code is free software; you can redistribute it and/or modify it under
//  the terms of the new BSD License.
//
//  Created by Krist Menina on 4/16/11.
//  Copyright 2011 Hello Wala Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BWToolkitFramework/BWToolkitFramework.h>


@interface TwitJustice : NSWindowController {
@private
	NSOperationQueue *queue;	
	NSMutableArray *favRecords;	
	NSStatusItem *_statusItem;	
    NSWindow *window;

@public
	IBOutlet BWSheetController *sheetController;	
	IBOutlet BWSelectableToolbar *prefToolbar;	
	IBOutlet NSMenu	*menuItemMenu;
	IBOutlet NSWindow *prefWindow;
	IBOutlet NSTextField *favName;
	IBOutlet NSTextField *favDescription;
	IBOutlet NSTableView *favList;
	IBOutlet NSPopUpButton *twitSource;
	IBOutlet NSPopUpButton *voicesSource;
	IBOutlet NSMenu *twitSourceMenu;
	IBOutlet NSMenuItem *statusInfo;	
	IBOutlet NSButton *noRepeat;
	IBOutlet NSButton *sayTweetSource;
	IBOutlet NSTextField *radioTweet;
	IBOutlet NSTextField *radioTweetSource;
	IBOutlet NSImageView *radioThumb;
	IBOutlet NSWindow *radioBack;
	IBOutlet NSWindow *aboutWindow;

}


@property (assign) IBOutlet NSWindow *window;

- (IBAction) prefWindowController: (id) sender;
- (IBAction) openFavoritesSheet: (id) sender;
- (IBAction) addFavorite: (id) sender;
- (IBAction) removeFavorite: (id) sender;
- (IBAction) selectedTwitSource: (id) sender;
- (IBAction) setVoice:(id) sender;
- (IBAction) aboutWindowController: (id) sender;

- (void)twitNotification:(NSNotification*)aNotification;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
- (int)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)getFavorites;
- (NSString*)copyrightString;
- (NSString *)versionString;
- (float)appNameLabelFontSize;

@end
