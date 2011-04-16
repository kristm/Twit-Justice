//
//  TwitJusticeAppDelegate.h
//  TwitJustice
//
//  Created by Krist Menina on 4/16/11.
//  Copyright 2011 Hello Wala Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TwitJustice : NSObject {
    NSWindow *window;
	NSStatusItem *_statusItem;
	IBOutlet NSMenu	*menuItemMenu;
}

@property (assign) IBOutlet NSWindow *window;
- (void)actionQuit:(id)sender;

@end
