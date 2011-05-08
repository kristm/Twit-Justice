//
//  TwitReader.h
//  TwitJustice
//
//  Created by Krist Menina on 4/16/11.
//  Copyright 2011 Hello Wala Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SystemConfiguration/SCNetwork.h>



@interface TwitReader : NSOperation {
@private
	NSMenuItem *menuLabel;
@public
	NSString*			twitData;
	NSOperationQueue*	queue;	
	int tjInterval;

}

- (id)initWithData:(NSString *)pp operationClass:(Class)cc queue:(NSOperationQueue *)qq statusLabel:(NSMenuItem *)menuLbl;

@end
