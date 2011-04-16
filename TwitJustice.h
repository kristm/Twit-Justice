//
//  TwitJustice.h
//  TwitJustice
//
//  Created by Krist Menina on 4/16/11.
//  Copyright 2011 Hello Wala Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TwitJustice : NSObject {
	NSOperationQueue *queue;	
    NSWindow *window;
	NSStatusItem *_statusItem;
	IBOutlet NSMenu	*menuItemMenu;
	IBOutlet NSWindow *prefWindow;
}

@property (assign) IBOutlet NSWindow *window;
- (IBAction) prefWindowController: (id) sender;

@end
