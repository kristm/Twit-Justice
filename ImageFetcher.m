//
//  ImageFetcher.m
//  TwitJustice
//
//  This code is free software; you can redistribute it and/or modify it under
//  the terms of the new BSD License.
//
//  Created by Krist Menina on 5/29/11.
//  Copyright 2011 Hello Wala Studios. All rights reserved.
//

#import "ImageFetcher.h"

@interface ImageFetcher(Private)
-(BOOL) isConnected;	

@end


@implementation ImageFetcher

- (id)init:(NSImageView *)iThumb{
	self = [super init];
	radioThumb = [iThumb retain];
	return self;
}

- (void)dealloc
{
	[radioThumb release];
	[super dealloc];
}

- (void)main
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if([self isConnected]){
		NSImage *twitSourceImg = [[NSImage alloc] initWithContentsOfURL:
								  [NSURL URLWithString:[NSString stringWithFormat:@"http://api.twitter.com/1/users/profile_image/%@.json?size=bigger",[[NSUserDefaults standardUserDefaults] stringForKey:@"twitSource"]]]];
		
		if (twitSourceImg != nil) {
			[radioThumb setImage:twitSourceImg];
		}		
	}else{
		NSBundle *bundle = [NSBundle mainBundle];
		NSImage *twitSourceImg = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:@"defaultpic"]];
		NSLog(@"no net image %@",twitSourceImg);
		[radioThumb setImage:twitSourceImg];
	}
	
	[pool release];
}

- (BOOL) isConnected
{
    Boolean success;
    BOOL connected;
    SCNetworkConnectionFlags status;
    
    success = SCNetworkCheckReachabilityByName("www.twitter.com", 
											   &status);
    
    connected = success && (status & kSCNetworkFlagsReachable) && !(status & 
																	kSCNetworkFlagsConnectionRequired);
    
    if (!connected)
    {   
        NSLog(@"No net");
    }else{
        NSLog(@"Net OK");
	}
	
	return connected;
}

@end
