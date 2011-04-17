//
//  TwitReader.h
//  TwitJustice
//
//  Created by Krist Menina on 4/16/11.
//  Copyright 2011 Hello Wala Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TwitReader : NSOperation {
	NSString*			twitData;
	NSOperationQueue*	queue;	

}

- (id)initWithData:(NSString *)pp operationClass:(Class)cc queue:(NSOperationQueue *)qq;

@end
