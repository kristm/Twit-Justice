//
//  TwitReader.h
//  TwitJustice
//
//  This code is free software; you can redistribute it and/or modify it under
//  the terms of the new BSD License.
//
//  Created by Krist Menina on 4/16/11.
//  Copyright 2011 Hello Wala Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SystemConfiguration/SCNetwork.h>
#import <YAJL/YAJL.h>


@interface TwitReader : NSOperation {
@private
	NSSpeechSynthesizer *speechSynth;
	//NSMutableString	*lastTweet;
	NSImageView *radioThumb;
@public
	NSString*			twitData;
	NSOperationQueue*	queue;	
	int tjInterval;

}

- (id)initWithData:(NSString *)pp operationClass:(Class)cc queue:(NSOperationQueue *)qq imageThumb:(NSImageView *)iThumb;

@end
