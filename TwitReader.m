//
//  TwitReader.m
//  TwitJustice
//
//  Created by Krist Menina on 4/16/11.
//  Copyright 2011 Hello Wala Studios. All rights reserved.
//

#import "TwitReader.h"

@implementation TwitReader

- (id)initWithData:(NSString *)pp operationClass:(Class)cc queue:(NSOperationQueue *)qq
{
    self = [super init];	
	twitData = [pp retain];
	return self;
}

- (void)dealloc
{
	NSLog(@"********** dealloc twitreader");
    [twitData release];
    [super dealloc];
}

- (void)main
{
	NSLog(@"twit reader main");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	while (TRUE) {
		if([self isCancelled]) break;
		tjInterval = [[NSUserDefaults standardUserDefaults] integerForKey:@"tjInterval"];
		NSLog(@"twit loop %@ %d",self,tjInterval);
		sleep(tjInterval);
	}
	[pool release];	
}

@end
