//
//  TwitJustice.h
//  TwitJustice
//
//  Created by Krist Menina on 4/16/11.
//  Copyright 2011 Hello Wala Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BWToolkitFramework/BWToolkitFramework.h>


//#import <Carbon/Carbon.h>
//#import <unistd.h>
//#import <sys/stat.h>
//#import <fcntl.h>

@interface TwitJustice : NSWindowController {
@private
	NSOperationQueue *queue;	
	NSMutableArray *favRecords;	
	NSStatusItem *_statusItem;	
    //NSWindow *window;

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

}


@property (assign) IBOutlet NSWindow *window;

- (IBAction) prefWindowController: (id) sender;
- (IBAction) openFavoritesSheet: (id) sender;
- (IBAction) addFavorite: (id) sender;
- (IBAction) removeFavorite: (id) sender;
- (IBAction) selectedTwitSource: (id) sender;
- (IBAction) setVoice:(id) sender;

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
- (int)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)getFavorites;
@end
