//
//  TwitReader.m
//  TwitJustice
//
//  Created by Krist Menina on 4/16/11.
//  Copyright 2011 Hello Wala Studios. All rights reserved.
//

#import "TwitReader.h"
#import "JSON.h"

@interface TwitReader(Private)
- (BOOL) isConnected;
- (void) readTweet:(NSString *)twitSource;
@end


@implementation TwitReader

- (id)initWithData:(NSString *)pp operationClass:(Class)cc queue:(NSOperationQueue *)qq statusLabel:(NSMenuItem *)menuLbl
{
    self = [super init];	
	twitData = [pp retain];
	//menuLabel = menuLbl; // whats the difference between [menuLbl retail]?
	menuLabel = [menuLbl retain];
	return self;
}

- (void)dealloc
{
	NSLog(@"********** dealloc twitreader");
    [twitData release];
	[menuLabel release];
    [super dealloc];
}

- (void)main
{
	NSLog(@"twit reader main");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	while (TRUE) {
		if([self isCancelled]) break;
		tjInterval = [[NSUserDefaults standardUserDefaults] integerForKey:@"tjInterval"] * 60;
		NSLog(@"twit loop %@ %d %@",self,tjInterval,[[NSUserDefaults standardUserDefaults] stringForKey:@"twitSource"]);
		NSLog(@"connection status %d",[self isConnected]);
		NSLog(@"use voice %@",[[NSUserDefaults standardUserDefaults] stringForKey:@"voice"]);
		if([self isConnected]){
			[menuLabel setTitle:@"Listening to"];
			[self readTweet:[[NSUserDefaults standardUserDefaults] stringForKey:@"twitSource"]];
		}else{
			[menuLabel setTitle:@"Not Connected"];
		}
		NSLog(@"interval %d",tjInterval);
		sleep(tjInterval);
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

- (void) readTweet:(NSString *)twitSource
{
	SBJsonParser *parser = [[SBJsonParser alloc] init];

	//twit url: http://api.twitter.com/1/statuses/user_timeline.json?screen_name=lovipoe
	NSURLRequest *request = [NSURLRequest requestWithURL:
							 [NSURL URLWithString:[NSString stringWithFormat:@"http://api.twitter.com/1/statuses/user_timeline.json?screen_name=%@",[NSString stringWithString:@"lovipoe"]]]];
	
	NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	
	NSArray *statuses = [parser objectWithString:json_string error:nil];
	int scount = [statuses count];
	//NSLog("status length %ld",scount);

	//NSLog(@"statuses %@",statuses);
	for (NSDictionary *status in statuses) {
		// You can retrieve individual values using objectForKey on the status NSDictionary // This will print the tweet and username to the console 
		NSLog(@"%@ - %@", [status objectForKey:@"text"], [[status objectForKey:@"user"]objectForKey:@"screen_name"]); 
	}
	
}
@end
