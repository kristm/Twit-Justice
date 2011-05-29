//
//  TwitReader.m
//  TwitJustice
//
//  Created by Krist Menina on 4/16/11.
//  Copyright 2011 Hello Wala Studios. All rights reserved.
//

#import "TwitReader.h"


@interface TwitReader(Private)
- (BOOL) isConnected;
- (NSString *) getVoiceIdentifier;
- (void) readTweet:(NSString *)twitSource;
@end


@implementation TwitReader

- (id)initWithData:(NSString *)pp operationClass:(Class)cc queue:(NSOperationQueue *)qq imageThumb:(NSImageView *)iThumb
{
    self = [super init];	
	twitData = [pp retain];
	radioThumb = [iThumb retain];
	speechSynth = [[NSSpeechSynthesizer alloc] initWithVoice:[self getVoiceIdentifier]];
	return self;
}

- (void)dealloc
{
	NSLog(@"********** dealloc twitreader %@",self);
    [twitData release];
	[speechSynth release];
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
		NSLog(@"twit source: %@",[[NSUserDefaults standardUserDefaults] stringForKey:@"twitSource"]);	
		NSLog(@"interval: %d",tjInterval);
		//NSLog(@"last tweet %d",lastTweet == nil);
		if([self isConnected]){
			NSDictionary *menuTitle = [NSDictionary dictionaryWithObject:@"Listening to" forKey:@"message"];
			[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"OkNet" object:@"TwitReader" userInfo:menuTitle];
			[self readTweet:[[NSUserDefaults standardUserDefaults] stringForKey:@"twitSource"]];
		}else{
			NSDictionary *menuTitle = [NSDictionary dictionaryWithObject:@"Not Connected" forKey:@"message"];
			[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"NoNet" object:@"TwitReader" userInfo:menuTitle];

		}
		
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

- (NSString *) getVoiceIdentifier{
	NSLog(@"use voice %@",[NSString stringWithFormat:@"com.apple.speech.synthesis.voice.%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"voice"]]);
	return [NSString stringWithFormat:@"com.apple.speech.synthesis.voice.%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"voice"]];
}

- (void) readTweet:(NSString *)twitSource
{
    //get profile pic of user: http://api.twitter.com/1/users/profile_image/lovipoe.json?size=reasonably_small
    //size for reasonably_small is undocumented though
	// add try catch here
	NSImage *twitSourceImg = [[NSImage alloc] initWithContentsOfURL:
							  [NSURL URLWithString:[NSString stringWithFormat:@"http://api.twitter.com/1/users/profile_image/%@.json?size=bigger",[[NSUserDefaults standardUserDefaults] stringForKey:@"twitSource"]]]];
	
	NSLog(@"image %@ %@",[NSURL URLWithString:[NSString stringWithFormat:@"http://api.twitter.com/1/users/profile_image/%@.json?size=bigger",[[NSUserDefaults standardUserDefaults] stringForKey:@"twitSource"]]],twitSourceImg);
	if (twitSourceImg != nil) {
		[radioThumb setImage:twitSourceImg];
	}
	
	NSURLRequest *request = [NSURLRequest requestWithURL:
							 [NSURL URLWithString:[NSString stringWithFormat:@"http://api.twitter.com/1/statuses/user_timeline.json?screen_name=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"twitSource"]]]];
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSArray *status = [data yajl_JSON];
	NSString *lastTweet = [[[NSString alloc] init] autorelease];
	lastTweet = [[NSUserDefaults standardUserDefaults] stringForKey:@"lastTweet"];
	int status_count = [status count];
	NSLog(@"total %d",status_count);
	NSLog(@"classname %@",[status className]); 
	NSLog(@"error class %@",[[status valueForKey:@"error"] className]); // should be string if error, array if not
	[speechSynth setVoice:[self getVoiceIdentifier]];
	NSString *status_class = [status className];
	if([status_class isEqualToString:@"NSCFDictionary"] || status_count == 0){ // this is a cheap ass version of error checking, i wonder if there's a better way
		NSLog(@"proabably an error");
		NSLog(@"%@",[status valueForKey:@"error"]);
		[speechSynth startSpeakingString:[NSString stringWithFormat:@"%@:%@",@"error",[status valueForKey:@"error"]]];
		NSDictionary *twitObject = [NSDictionary dictionaryWithObject:@"error getting tweet" forKey:@"message"];
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"TweetError" object:@"TwitReader" userInfo:twitObject];

	}else{
		if([[status objectAtIndex:0] objectForKey:@"text"] != nil){			
			NSLog(@"status 1 %@",[[status objectAtIndex:0] objectForKey:@"text"] );
			NSLog(@"say source %d",[[NSUserDefaults standardUserDefaults] boolForKey:@"sayTweetSource"] );	
			NSLog(@"dont repeat? %d",[[NSUserDefaults standardUserDefaults] boolForKey:@"noRepeat"]);
			NSLog(@"lasttweet %@",lastTweet);
			if([[NSUserDefaults standardUserDefaults] boolForKey:@"noRepeat"] == YES){
				if([[[status objectAtIndex:0] objectForKey:@"text"] isEqualToString:lastTweet]) {
					NSLog(@"skipping same tweet");
					return;
				}				
			}
			NSString *justMessage = [[NSString alloc] autorelease];
			NSString *twitMessage = [[[[status objectAtIndex:0] objectForKey:@"text"] stringByReplacingOccurrencesOfString:@"(cont)" withString:@"continued"] stringByReplacingOccurrencesOfString:@"#" withString:@"hash tag"];
			if([[NSUserDefaults standardUserDefaults] boolForKey:@"sayTweetSource"] == YES){
				justMessage = [NSString stringWithFormat:@"%@ says %@",[[[status objectAtIndex:0] objectForKey:@"user"] objectForKey:@"name"],
							  twitMessage];
			}else{
				justMessage = [[status objectAtIndex:0] objectForKey:@"text"];
			}
			[speechSynth startSpeakingString:justMessage];
			[[NSUserDefaults standardUserDefaults] setValue:[[status objectAtIndex:0] objectForKey:@"text"] forKey:@"lastTweet"];
			NSDictionary *twitObject = [NSDictionary dictionaryWithObject:[[status objectAtIndex:0] objectForKey:@"text"] forKey:@"message"];
			[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"NewTweet" object:@"TwitReader" userInfo:twitObject];

			
		}
	}
	//[data release];
	//[status release];
	
}

@end
