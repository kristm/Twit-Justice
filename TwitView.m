//
//  TwitView.m
//  TwitJustice
//
//  This code is free software; you can redistribute it and/or modify it under
//  the terms of the new BSD License.
//
//  Created by Krist Menina on 5/28/11.
//  Copyright 2011 Hello Wala Studios. All rights reserved.
//

#import "TwitView.h"


@implementation TwitView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	NSImage *radioImage = [NSImage imageNamed:@"twitui_front"];
	
	NSPoint backgroundCenter;
	backgroundCenter.x = [self bounds].size.width / 2;
	backgroundCenter.y = [self bounds].size.height / 2;
	
	NSPoint drawPoint = backgroundCenter;
	drawPoint.x -= [radioImage size].width / 2;
	drawPoint.y -= [radioImage size].height / 2;
	
	[radioImage drawAtPoint:drawPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}



@end
