//
//  RVToolbarView.m
//  ResViewer
//
//  Created by Steven Troughton-Smith on 01/05/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "RVToolbarView.h"


@implementation RVToolbarView

- (void)drawRect:(NSRect)rect {	
	[[NSImage imageNamed:@"ToolbarGradient"] drawInRect:[self bounds] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

@end
