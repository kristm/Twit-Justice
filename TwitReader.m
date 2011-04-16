//
//  TwitReader.m
//  TwitJustice
//
//  Created by Krist Menina on 4/16/11.
//  Copyright 2011 Hello Wala Studios. All rights reserved.
//

#import "TwitReader.h"


@implementation TwitReader

- (id)initWithRootPath:(NSString *)pp operationClass:(Class)cc queue:(NSOperationQueue *)qq
{
    self = [super init];	
	rootPath = [pp retain];
	return self;
}

- (void)dealloc
{
	NSLog(@"********** dealloc twitreader");
    [rootPath release];
    [super dealloc];
}

- (void)main
{
	NSLog(@"twit reader main");
	while (TRUE) {
		NSLog(@"twit loop");
		sleep(5);
	}
}

@end
