//
//  ImageFetcher.h
//  TwitJustice
//
//  This code is free software; you can redistribute it and/or modify it under
//  the terms of the new BSD License.
//
//  Created by Krist Menina on 5/29/11.
//  Copyright 2011 Hello Wala Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SystemConfiguration/SCNetwork.h>

@interface ImageFetcher : NSOperation {
	NSImageView *radioThumb;
}

- (id)init:(NSImageView *)iThumb;
@end
